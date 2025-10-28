import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class AddAddress extends StatefulWidget {
  // ✅ 1. ADD THIS to accept an existing address for editing
  final DocumentSnapshot? existingAddress;

  const AddAddress({super.key, this.existingAddress});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  late GoogleMapController googleMapController;
  bool isLoading = false;
  LatLng? _mapCenter;
  String _sAddress = "Drag map to select location";
  final TextEditingController _bName = TextEditingController();
  String? _sAddressType;
  final ValueNotifier<double> _sheetExtent = ValueNotifier<double>(0.3);
  static double _minSheetSize = 0.15;
  static double _initialSheetSize = 0.35;
  static double _maxSheetSize = 0.8;
  Marker? _llMarker;
  StreamSubscription<Position>? _pss;
  BitmapDescriptor? _llIcon;
  bool _isSaving = false;

  // ✅ 2. ADD THIS to track if we are in "Edit" mode
  bool _isEditMode = false;

  final TextEditingController _searchController = TextEditingController();
  final String _apiKey = "AIzaSyBWsNBsKAaal3gEegLMh9EFE-QSgn01L9M"; // ⚠️ Replace

  @override
  void initState() {
    super.initState();

    // ✅ 3. MODIFY initState to handle edit mode
    if (widget.existingAddress != null) {
      // We are in EDIT mode
      _isEditMode = true;
      final data = widget.existingAddress!.data() as Map<String, dynamic>;
      _bName.text = data['line1'] ?? '';
      _sAddress = data['fullAddress'] ?? 'Drag map to select';
      _sAddressType = data['addressType'];
      _mapCenter = LatLng(data['latitude'], data['longitude']);
    } else {
      // We are in ADD mode
      _isEditMode = false;
      _mapCenter = const LatLng(20.5937, 78.9629); // Default for new
      _getAddress(_mapCenter!);
    }

    _LllIcon();
    _sltll();
  }

  @override
  void dispose() {
    _bName.dispose();
    _searchController.dispose();
    _sheetExtent.dispose();
    googleMapController.dispose();
    _pss?.cancel();
    super.dispose();
  }

  // ... (Your methods _LllIcon, _sltll, _getAddress, _showSnackBar remain unchanged) ...
  Future<void> _LllIcon() async {
    final double size = 60;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.teal;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 3, paint);
    final Paint arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.fill;

    final Path arrowPath = Path();
    double arrowSize = size * 0.15;
    arrowPath.moveTo(size / 2, size / 2 - arrowSize * 1.5);
    arrowPath.lineTo(size / 2 - arrowSize, size / 2 + arrowSize * 0.5);
    arrowPath.lineTo(size / 2 + arrowSize, size / 2 + arrowSize * 0.5);
    arrowPath.close();
    canvas.drawPath(arrowPath, arrowPaint);
    final img =
    await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    if (data != null) {
      _llIcon = BitmapDescriptor.fromBytes(data.buffer.asUint8List());
      setState(() {});
    }
  }

  Future<void> _sltll() async {
    try {
      await currentPosition();
    } catch (e) {
      print(
          "Live Location Listening not started due to permission/service issues:$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Live location tracking disabled:${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    _pss = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      if (mounted && _llIcon != null) {
        setState(() {
          _llMarker = Marker(
            markerId: const MarkerId('Live Location Marker'),
            position: LatLng(position.latitude, position.longitude),
            icon: _llIcon!,
            rotation: position.heading,
            anchor: const Offset(0.5, 0.5),
            flat: true,
            zIndex: 5,
          );
        });
      }
    });
  }

  Future<void> _getAddress(LatLng position) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      _sAddress = "Fetching address...";
    });
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _sAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode,
            place.country
          ].where((element) => element != null && element.isNotEmpty).join(', ');
          isLoading = false;
        });
      } else {
        setState(() {
          _sAddress = "No address found for this Location";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _sAddress = "Error getting address: ${e.toString()}";
        isLoading = false;
      });
      print("Error in _getAddress:$e");
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Color(0xFFA6CB4E),
      ),
    );
  }

  // ✅ 4. MODIFY _saveAddress to handle both Add and Update
  Future<void> _saveAddress() async {
    if (_mapCenter == null) {
      _showSnackBar("Please select a location on the map.", isError: true);
      return;
    }
    if (_bName.text.trim().isEmpty) {
      _showSnackBar("Please enter a Building Name or House No.", isError: true);
      return;
    }
    if (_sAddressType == null) {
      _showSnackBar("Please select an address type (Home, Office, etc.).",
          isError: true);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("You must be logged in to save an address.", isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // This data structure is the same for both add and update
      final addressData = {
        'line1': _bName.text.trim(),
        'fullAddress': _sAddress,
        'latitude': _mapCenter!.latitude,
        'longitude': _mapCenter!.longitude,
        'addressType': _sAddressType,
        'createdAt': FieldValue.serverTimestamp(), // Will be set on create, ignored on update
      };

      final collectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses');

      if (_isEditMode) {
        // UPDATE existing document
        await collectionRef.doc(widget.existingAddress!.id).update(addressData);
        _showSnackBar("Address updated successfully!");
      } else {
        // ADD new document
        await collectionRef.add(addressData);
        _showSnackBar("Address saved successfully!");
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Failed to save address: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3E3),
      appBar: AppBar(
        centerTitle: true,
        // ✅ 5. Make title dynamic
        title: Text(
          _isEditMode ? 'Edit Address' : 'Add Address',
          style: const TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
            color: Color(0xFFFCF3E3),
          ),
        ),
        backgroundColor: const Color(0xFF013D5A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white), // Use a standard back icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _sheetExtent,
            builder: (context, currentExtent, child) {
              double mapH =
                  MediaQuery.of(context).size.height * (1.0 - currentExtent);
              return SizedBox(
                height: mapH,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    googleMapController = controller;
                  },
                  // ✅ 6. Set initial camera based on edit or add mode
                  initialCameraPosition: CameraPosition(
                    target: _mapCenter!,
                    zoom: _isEditMode ? 17 : 5, // Zoom in if editing
                  ),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  markers: {
                    if (_llMarker != null) _llMarker!,
                  },
                  onCameraMove: (CameraPosition position) {
                    _mapCenter = position.target;
                    if (_sheetExtent.value > _minSheetSize + 0.1) {
                      _sheetExtent.value = _minSheetSize;
                    }
                  },
                  onCameraIdle: () {
                    if (_mapCenter != null) {
                      _getAddress(_mapCenter!);
                    }
                  },
                ),
              );
            },
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 50.0),
              child: Icon(
                Icons.location_on_sharp,
                size: 40,
                color: Colors.redAccent,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: _searchController,
                googleAPIKey: _apiKey,
                inputDecoration: InputDecoration(
                  hintText: "Search for a location",
                  prefixIcon:
                  const Icon(Icons.search, color: Color(0xFF013D5A)),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                debounceTime: 400,
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (Prediction prediction) async {
                  if (prediction.lat != null && prediction.lng != null) {
                    LatLng newPos = LatLng(
                      double.parse(prediction.lat!),
                      double.parse(prediction.lng!),
                    );
                    googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: newPos, zoom: 17),
                      ),
                    );
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  }
                },
                itemClick: (Prediction prediction) {
                  _searchController.text = prediction.description ?? "";
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: prediction.description?.length ?? 0),
                  );
                },
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: _initialSheetSize,
            minChildSize: _minSheetSize,
            maxChildSize: _maxSheetSize,
            expand: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  _sheetExtent.value = notification.extent;
                  return false;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade100,
                          ),
                          child: Row(children: [
                            const Icon(Icons.location_on,
                                color: Color(0xFF013D5A)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: isLoading
                                  ? const LinearProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF013D5A)),
                              )
                                  : Text(
                                _sAddress,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bName,
                          decoration: InputDecoration(
                            labelText: 'Building Name/House No.',
                            hintText: 'e.g.,252,Sapphire Residency',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                              const BorderSide(color: Color(0xFF013D5A)),
                            ),
                            labelStyle:
                            const TextStyle(color: Color(0xFF013D5A)),
                          ),
                          style: const TextStyle(color: Colors.black87),
                        ),
                        SizedBox(height: 16),
                        const Text(
                          "Save This Address as",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RedHatDisplay',
                            color: Color(0xFF013D5A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildAddressTypeButton("Home"),
                            SizedBox(width: 8),
                            _buildAddressTypeButton("Office"),
                            SizedBox(width: 8),
                            _buildAddressTypeButton("Others"),
                            SizedBox(width: 8),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA6CB4E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                          ),
                          child: Center(
                            child: _isSaving
                                ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            )
                            // ✅ 7. Make button text dynamic
                                : Text(
                              _isEditMode
                                  ? "Update Address"
                                  : "Confirm Address",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: "RedHatDisplay",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder<double>(
            valueListenable: _sheetExtent,
            builder: (context, currentExtent, child) {
              double fabBottomPosition =
                  (MediaQuery.of(context).size.height * currentExtent) + 16.0;
              final double maxFabBottom = MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  80;
              fabBottomPosition = fabBottomPosition.clamp(16.0, maxFabBottom);
              return Positioned(
                right: 16.0,
                bottom: fabBottomPosition,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() => isLoading = true);
                    try {
                      Position position = await currentPosition();
                      LatLng pos =
                      LatLng(position.latitude, position.longitude);
                      await googleMapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: pos,
                            zoom: 17,
                          ),
                        ),
                      );
                      _mapCenter = pos;
                    } catch (e) {
                      _showSnackBar("Error getting location: ${e.toString()}",
                          isError: true);
                      print('Location error: $e');
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
                  child: const Icon(
                    Icons.my_location,
                    size: 30,
                    color: Color(0xFF013D5A),
                  ),
                ),
              );
            },
          ),
          if (isLoading && _sAddress == "fetching address...")
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF013D5A)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressTypeButton(String type) {
    final bool isSelected = _sAddressType == type;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _sAddressType = type;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF013D5A) : Colors.white,
          foregroundColor: isSelected ? Colors.white : const Color(0xFF013D5A),
          side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
          elevation: isSelected ? 3 : 0,
        ),
        child: Text(
          type,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<Position> currentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied ,we cannot request permissions. ');
    }
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        print('Could not get current position,returning last known position.');
        return lastKnown;
      }
      throw Exception('Failed to get current or last known location:$e');
    }
  }
}