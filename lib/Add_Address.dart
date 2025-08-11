import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package

class AddAddress extends StatefulWidget {
  const AddAddress({super.key});

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
  final ValueNotifier<double>_sheetExtent = ValueNotifier<double>(0.3);
  static double _minSheetSize = 0.15;
  static double _initialSheetSize = 0.35;
  static double _maxSheetSize = 0.8;
  Marker? _llMarker;
  StreamSubscription<Position>? _pss;
  BitmapDescriptor? _llIcon;

  @override
  void initState() {
    super.initState();
    _mapCenter = const LatLng(20.5937, 78.9629);
    _getAddress(_mapCenter!);
    _LllIcon();
    _sltll();
  }

  @override
  void dispose() {
    _bName.dispose();
    _sheetExtent.dispose();
    googleMapController.dispose();
    _pss?.cancel();
    super.dispose();
  }

  Future<void> _LllIcon() async {
    final double size = 60;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()
      ..color = Colors.teal;
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
    final img = await pictureRecorder.endRecording().toImage(
        size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    if (data != null) {
      _llIcon = BitmapDescriptor.fromBytes(data.buffer.asUint8List());
      setState(() {});
    }
  }

  Future<void> _sltll() async {
    try {
      await currentPosition();
    }
    catch (e) {
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
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );
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
          ].where((element) => element != null && element.isNotEmpty).join(
              ', ');
          isLoading = false;
        });
      }
      else {
        setState(() {
          _sAddress = "No address found for this Location";
          isLoading = false;
        });
      }
    }

    catch (e) {
      setState(() {
        _sAddress = "Error getting address: ${e.toString()}";
        isLoading = false;
      });
      print("Error in _getAddress:$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3E3),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Address',
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
            color: Color(0xFFFCF3E3),
          ),
        ),
        backgroundColor: const Color(0xFF013D5A),
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.57, // 90 degrees in radians (for a right turn icon)
            child: const Icon(Icons.u_turn_left, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _sheetExtent,
            builder: (context, currentExtent, child) {
              double mapH = MediaQuery
                  .of(context)
                  .size
                  .height * (1.0 - currentExtent);
              return Container(
                height: mapH,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    googleMapController = controller;
                    _mapCenter = const LatLng(20.5937, 78.9629);
                    _getAddress(_mapCenter!);
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(20.5937, 78.9629),
                    zoom: 5,
                  ),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: {
                    if(_llMarker != null)_llMarker!,
                  },
                  onCameraMove: (CameraPosition position) {
                    _mapCenter = position.target;
                    if (_sheetExtent.value != _minSheetSize) {
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
            child: Icon(
              Icons.location_on_sharp,
              size: 40,
              color: Colors.redAccent,
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
                          child: Row(
                              children: [
                                const Icon(Icons.location_on,
                                  color: Color(0xFF013D5A),
                                ),
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
                              ]
                          ),
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
                              borderSide: const BorderSide(
                                  color: Color(0xFF013D5A)),
                            ),
                            labelStyle: const TextStyle(
                                color: Color(0xFF013D5A)),
                          ),
                          style: const TextStyle(color: Colors.black87),
                        ),
                        SizedBox(height: 16),
                        const Text("Save This Address as",
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
                        const SizedBox(height: 24,),
                        ElevatedButton(
                          onPressed: () {
                            if (_mapCenter != null) {
                              final cLatitude = _mapCenter!.latitude;
                              final cLongitude = _mapCenter!.longitude;
                              final cFullAddress = _sAddress;
                              final cBname = _bName.text;
                              final cAddressType = _sAddressType ??
                                  "Not Specified";
                              print('--- Confirmed Address Details ---');
                              print('Latitude: $cLatitude');
                              print('Longitude: $cLongitude');
                              print('Full Address: $cFullAddress');
                              print('Building/House No: $cBname');
                              print('Address Type: $cAddressType');
                              print('---------------------------------');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(
                                  "Location Confirmed: $cFullAddress\nType:$cAddressType",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                  backgroundColor: Color(0xFFA6CB4E),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please select a location on the map."),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA6CB4E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                          ),
                          child: Center(
                            child: Text(
                              "Confirm Address",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: "RedHatDisplay",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery
                            .of(context)
                            .padding
                            .bottom + 16,),
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
              double fabBottomPosition = (MediaQuery
                  .of(context)
                  .size
                  .height * currentExtent) + 16.0;
              final double maxFabBottom = MediaQuery
                  .of(context)
                  .size
                  .height - AppBar().preferredSize.height - 80;
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
                      LatLng pos = LatLng(
                          position.latitude, position.longitude);
                      await googleMapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: pos,
                            zoom: 17,
                          ),
                        ),
                      );
                      _mapCenter = pos;
                      _getAddress(pos);
                      print('Current Location fetched and map centered');
                      _sheetExtent.value = _initialSheetSize;
                    }
                    catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Error getting location:${e.toString()}",
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      print('Location error: $e');
                    }
                    finally {
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
          if(isLoading && _sAddress == "fetching address...")
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
  Future<Position> currentPosition() async{
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled=await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }
    permission=await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission=await Geolocator.requestPermission();
      if(permission==LocationPermission.denied){
        throw Exception('Location permissions are denied.');
      }
    }
    if(permission==LocationPermission.deniedForever){
      throw Exception('Location permissions are permanently denied ,we cannot request permissions. ');
    }
    try{
      return await Geolocator.getCurrentPosition();
    }
    catch(e){
      Position?lastKnown=await Geolocator.getLastKnownPosition();
      if(lastKnown!=null){
        print('Could not get current position,returning last known position.');
        return lastKnown;
      }
      throw Exception('Failed to get current or last known location:$e');
    }
  }
}