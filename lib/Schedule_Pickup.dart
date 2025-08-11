import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                          setState(() {
                            selectedIndex = index;
                          });
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
                  // ElevatedButton(
                  //   onPressed: () => Navigator.of(context).pop(),
                  //   style: ElevatedButton.styleFrom(
                  //     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  //     backgroundColor: Color(0xFFA6CB4E),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(30),
                  //     ),
                  //   ),
                  //   child: Text('OK'),
                  // )
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _currentWeight.round().toString());
  }

  void _updateWeightFromInput(String input) {
    final parsed = double.tryParse(input);
    if (parsed != null && parsed >= 0 && parsed <= 500) {
      setState(() {
        _currentWeight = parsed;
      });
    }
  }
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCF3E3),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Schedule Pickup',
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
            child: Icon(Icons.u_turn_left,
              color: Colors.white,),
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
            // Handle back button press
          },
        ),

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                // height: 150,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: [
                            Icon(Icons.location_on),
                            Text("Pickup Location",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black)
                        ),
                        child: Center(child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Select Address',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('+Add new address',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                // height: 150,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month),
                            Text("Date & Time",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
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
                                    border: Border.all(width: 1, color: Colors.black)
                                ),
                                child: Center(child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: TextFormField(
                                        controller: dateController,
                                        decoration: InputDecoration(
                                          labelText: "Select Date",
                                          // filled: true,
                                        ),
                                        readOnly: true,
                                        onTap: (){
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
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1, color: Colors.black)
                                  ),
                                  child: Center(child: Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Text('Select Time Slot',
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
                // height: 150,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: [
                            Icon(Icons.recycling),
                            Text("Type of Scrap",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
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
                                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Checkbox(
                                        value: entry.value,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            scrapTypes[entry.key] = newValue ?? false;
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
                                  child: Text('Add Description(Optional)',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
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
                // height: 150,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: [
                            Icon(Icons.monitor_weight_outlined),
                            Text("Estimated weight",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
                          ],
                        ),
                      ),
                      SliderTheme(data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.green.shade700,
                            inactiveTrackColor: Colors.grey.shade300,
                            thumbColor: Colors.green.shade800,
                            overlayColor: Colors.green.withOpacity(0.2),
                            valueIndicatorTextStyle: TextStyle(color: Colors.white),
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
                      ),),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Center(
                    child: Text(
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
            SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }
  Future <void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text = pickedDate.toString().split(" ")[0];
      });
    }
  }
}