import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/Add_Address.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✨ NEW
import 'package:cloud_firestore/cloud_firestore.dart'; // ✨ NEW

class SchedulePickup extends StatefulWidget {
  @override
  State<SchedulePickup> createState() => _SchedulePickupState();
}

TextEditingController dateController = TextEditingController();

class _SchedulePickupState extends State<SchedulePickup> {
  Map<String, bool> scrapTypes = {
    'Paper': false,
    'Glass': false,
    'Plastic': false,
    'Metal': false,
    // 'E-Waste': false,
    'Others': false,
  };
  double _currentWeight = 250.0; // default mid-value for range 0–500
  late TextEditingController _controller;
  final TextEditingController _descriptionController = TextEditingController();

  // ✨ NEW State Variables
  List<DocumentSnapshot> _addresses = [];
  DocumentSnapshot? _selectedAddress;
  bool _isLoadingAddresses = true;
  String? _selectedTimeSlot;
  bool _isSubmitting = false;

  void showCustomPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        int? selectedIndex;
        List<String> slots = [
          '09:00AM - 11:00AM',
          '11:00AM - 01:00PM',
          '03:00PM - 05:00PM',
          '05:00PM - 07:00PM',
        ];

        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add time slot',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 16),
                  ...List.generate(slots.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() { // This is the dialog's setState
                            selectedIndex = index;
                          });
                          // ✨ UPDATED: Store the value and close the dialog
                          Navigator.of(context).pop(); // Close the dialog
                          _onTimeSlotSelected(slots[index]); // Call main widget function
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedIndex == index
                                ? Color(0xFFA6CB4E)
                                : Colors.transparent,
                            border: Border.all(width: 1, color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                slots[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedIndex == index
                                      ? Colors.black
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ✨ NEW: Function to handle time slot selection
  void _onTimeSlotSelected(String slot) {
    setState(() {
      _selectedTimeSlot = slot;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _currentWeight.round().toString());
    _fetchAddresses(); // ✨ NEW: Fetch addresses on init
  }

  // ✨ NEW: Function to fetch user's addresses
  Future<void> _fetchAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoadingAddresses = false);
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .orderBy('createdAt', descending: true) // Show newest first
          .get();

      if (mounted) {
        setState(() {
          _addresses = querySnapshot.docs;
          _isLoadingAddresses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAddresses = false);
        _showSnackBar("Failed to load addresses: $e", isError: true);
      }
    }
  }

  void _updateWeightFromInput(String input) {
    final parsed = double.tryParse(input);
    if (parsed != null && parsed >= 0 && parsed <= 500) {
      setState(() {
        _currentWeight = parsed;
      });
    }
  }

  // ✨ NEW: Function to show a snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Color(0xFFA6CB4E),
      ),
    );
  }

  // ✨ NEW: Function to handle the submit logic
  Future<void> _submitPickup() async {
    final user = FirebaseAuth.instance.currentUser;

    // 1. Validations
    if (user == null) {
      _showSnackBar("You must be logged in.", isError: true);
      return;
    }
    if (_selectedAddress == null) {
      _showSnackBar("Please select a pickup address.", isError: true);
      return;
    }
    if (dateController.text.isEmpty) {
      _showSnackBar("Please select a pickup date.", isError: true);
      return;
    }
    if (_selectedTimeSlot == null) {
      _showSnackBar("Please select a time slot.", isError: true);
      return;
    }
    final selectedScraps =
    scrapTypes.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selectedScraps.isEmpty) {
      _showSnackBar("Please select at least one scrap type.", isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 2. Prepare Data
      final pickupDate = DateTime.parse(dateController.text);
      final addressData = _selectedAddress!.data() as Map<String, dynamic>;

      // 3. Save to 'pickups' collection
      await FirebaseFirestore.instance.collection('pickups').add({
        'userId': user.uid,
        'addressId': _selectedAddress!.id,
        'addressDetails': addressData, // Store a copy for easy access
        'pickupDate': Timestamp.fromDate(pickupDate),
        'pickupTimeSlot': _selectedTimeSlot,
        'scrapTypes': selectedScraps,
        'estimatedWeight': _currentWeight.round(),
        'description': _descriptionController.text.trim(),
        'status': 'Pending', // Initial status
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Pickup scheduled successfully!");
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Failed to schedule pickup: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCF3E3),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Schedule Pickup',
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
            color: Color(0xFFFCF3E3),
          ),
        ),
        backgroundColor: Color(0xFF013D5A),
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.57, // 180 degrees in radians
            child: Icon(
              Icons.u_turn_left,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: [
                            Icon(Icons.location_on),
                            Text(
                              "Pickup Location",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ✨ UPDATED: Address Dropdown
                      _isLoadingAddresses
                          ? Center(child: CircularProgressIndicator())
                          : _addresses.isEmpty
                          ? Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: Colors.black)),
                        child: Center(
                            child: Padding(
                              padding:
                              const EdgeInsets.fromLTRB(5, 5, 0, 5),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'No addresses found. Add one below.',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  )),
                            )),
                      )
                          : DropdownButtonFormField<DocumentSnapshot>(
                        value: _selectedAddress,
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 10),
                        ),
                        hint: Text('Select Address'),
                        items: _addresses.map((doc) {
                          final data =
                          doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem<DocumentSnapshot>(
                            value: doc,
                            child: Text(
                              '${data['addressType']}: ${data['line1']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAddress = value;
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: () async {
                          // ✨ UPDATED: Refresh list on return
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddAddress()),
                          );
                          // Refresh addresses after coming back
                          setState(() => _isLoadingAddresses = true);
                          _fetchAddresses();
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '+Add new address',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF013D5A)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month),
                            Text(
                              "Date & Time",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.black)),
                                child: Center(
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: TextFormField(
                                            controller: dateController,
                                            decoration: InputDecoration(
                                              labelText: "Select Date",
                                            ),
                                            readOnly: true,
                                            onTap: () {
                                              _selectDate();
                                            },
                                          )),
                                    )),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: GestureDetector(
                                onTap: () => showCustomPopup(context),
                                child: Container(
                                  height: 60, // Match TextFormField height
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.black)),
                                  child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 5, 5, 5),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              // ✨ UPDATED: Show selected slot
                                              _selectedTimeSlot ?? 'Select Time Slot',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: [
                            Icon(Icons.recycling),
                            Text(
                              "Type of Scrap",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 0,
                              children: scrapTypes.entries.map((entry) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 0),
                                      child: Checkbox(
                                        value: entry.value,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            scrapTypes[entry.key] =
                                                newValue ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    Text(entry.key),
                                  ],
                                );
                              }).toList(),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Add Description(Optional)',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: 'Write here...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: [
                            Icon(Icons.monitor_weight_outlined),
                            Text(
                              "Estimated weight",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.green.shade700,
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: Colors.green.shade800,
                          overlayColor: Colors.green.withOpacity(0.2),
                          valueIndicatorTextStyle:
                          TextStyle(color: Colors.white),
                        ),
                        child: Slider(
                          value: _currentWeight,
                          min: 0,
                          max: 500,
                          divisions: 500,
                          label: '${_currentWeight.round()} kg',
                          onChanged: (value) {
                            setState(() {
                              _currentWeight = value;
                              _controller.text = value.round().toString();
                            });
                          },
                        ),
                      ),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter weight (kg)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                        onSubmitted: _updateWeightFromInput,
                        onChanged: (text) {
                          final parsed = double.tryParse(text);
                          if (parsed != null && parsed >= 0 && parsed <= 500) {
                            setState(() {
                              _currentWeight = parsed;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${_currentWeight.round()} kg selected',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ✨ UPDATED: Submit Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: GestureDetector(
                onTap: _isSubmitting ? null : _submitPickup,
                child: Container(
                  height: 60, // Give it a fixed height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xFFA6CB4E),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFFCF3E3)),
                    )
                        : Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'RedHatDisplay',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFCF3E3),
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // User cannot select a past date
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        // Format as YYYY-MM-DD
        dateController.text = pickedDate.toLocal().toString().split(" ")[0];
      });
    }
  }
}