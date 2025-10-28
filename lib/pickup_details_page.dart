import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'widgets/pickup_tracker.dart'; // Import the tracker widget
import 'schedule_pickup.dart'; // IMPORT SchedulePickup

// Constants from your theme
const kPrimaryColor = Color(0xFF013D5A);
const kCreamColor = Color(0xFFFCF3E3);
const kAccentColor = Color(0xFFA6CB4E);

class PickupDetailsPage extends StatefulWidget {
  final String pickupId;

  const PickupDetailsPage({super.key, required this.pickupId});

  @override
  State<PickupDetailsPage> createState() => _PickupDetailsPageState();
}

class _PickupDetailsPageState extends State<PickupDetailsPage> {
  bool _isCancelling = false;

  // Function to show confirmation before cancelling
  Future<void> _confirmCancellation(BuildContext context, DocumentReference pickupRef) async {
    // ... (no changes here) ...
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Pickup?'),
          content: const Text('Are you sure you want to cancel this pickup request?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _cancelPickup(pickupRef);
    }
  }

  // Function to update status to Cancelled
  Future<void> _cancelPickup(DocumentReference pickupRef) async {
    // ... (no changes here) ...
    setState(() => _isCancelling = true);
    try {
      await pickupRef.update({'status': 'Cancelled'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back after cancellation
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel pickup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  // Helper to map status string to tracker step integer
  int _mapStatusToStep(String? status) {
    // ... (no changes here) ...
    switch (status) {
      case 'Pending': return 1;
      case 'Confirmed': return 2;
      case 'Out-for-Pickup': return 3;
      case 'Completed': return 4;
      case 'Cancelled': return 0;
      default: return 0;
    }
  }

  // ✅ 2. HELPER to check if editing is allowed (before cutoff time)
  bool _canEditPickup(DateTime? pickupDate, String? timeSlot) {
    if (pickupDate == null || timeSlot == null) return false;

    // Define the cutoff duration (e.g., 24 hours before)
    const Duration cutoffDuration = Duration(hours: 24);

    // Parse the start hour from the time slot string (e.g., "09:00AM - 11:00AM")
    int startHour = 0;
    try {
      final timeOnly = timeSlot.split(' ')[0]; // Get "09:00" from "09:00AM"
      final hourMinute = timeOnly.split(':');
      startHour = int.parse(hourMinute[0]);
      // Handle PM if necessary
      if (timeSlot.toLowerCase().contains('pm') && startHour != 12) {
        startHour += 12;
      }
      // Handle 12 AM
      if (timeSlot.toLowerCase().contains('am') && startHour == 12) {
        startHour = 0;
      }
    } catch (e) {
      print("Error parsing time slot start hour '$timeSlot': $e");
      return false; // Cannot determine cutoff if time slot is invalid
    }

    // Combine date and start hour
    DateTime pickupStartTime;
    try {
      pickupStartTime = DateTime(pickupDate.year, pickupDate.month, pickupDate.day, startHour);
    } catch (e) {
      print("Error creating pickup start time: $e");
      return false; // Invalid date components
    }

    // Calculate the cutoff time
    final DateTime cutoffTime = pickupStartTime.subtract(cutoffDuration);

    // Check if current time is before the cutoff time
    return DateTime.now().isBefore(cutoffTime);
  }


  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final pickupRef = FirebaseFirestore.instance.collection('pickups').doc(widget.pickupId);

    return Scaffold(
      backgroundColor: kCreamColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Pickup Details',
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
            color: kCreamColor,
          ),
        ),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: pickupRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading pickup details.'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Pickup not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final addressDetails = data['addressDetails'] as Map<String, dynamic>? ?? {};
          // final scrapWeights = data['scrapWeights'] as Map<String, dynamic>? ?? {}; // Not used anymore here
          final pickupDate = (data['pickupDate'] as Timestamp?)?.toDate();
          final timeSlot = data['pickupTimeSlot'] as String?; // Get time slot
          final status = data['status'] as String? ?? 'Unknown';

          // --- Determine State ---
          final bool isEditableStatus = ['Pending', 'Confirmed'].contains(status);
          // ✅ 3. Calculate canEdit using helper
          final bool canEdit = isEditableStatus && _canEditPickup(pickupDate, timeSlot);
          final bool canCancel = ['Pending', 'Confirmed', 'Out-for-Pickup'].contains(status);
          // ✅ 4. Check if Overdue
          bool isOverdue = false;
          if (pickupDate != null && ['Pending', 'Confirmed', 'Out-for-Pickup'].contains(status)) {
            final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
            final pickupDay = DateTime(pickupDate.year, pickupDate.month, pickupDate.day);
            isOverdue = pickupDay.isBefore(today);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ✅ 5. Conditionally display Overdue Chip
                if(isOverdue)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Chip(
                      label: Text('Pickup Overdue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.red.shade700,
                      avatar: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                    ),
                  ),

                // --- Status Tracker ---
                Text("Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                SizedBox(height: 10),
                PickupTracker(
                  currentStep: _mapStatusToStep(status),
                  pickupDate: pickupDate,
                ),
                Divider(height: 30, thickness: 1),

                // --- Pickup Address ---
                Text("Pickup Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                SizedBox(height: 8),
                Text(addressDetails['addressType'] ?? 'N/A', style: TextStyle(fontWeight: FontWeight.w500)),
                Text(addressDetails['line1'] ?? 'N/A'),
                Text(addressDetails['fullAddress'] ?? 'N/A'),
                Divider(height: 30, thickness: 1),

                // --- Date & Time ---
                Text("Date & Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                SizedBox(height: 8),
                Text("Date: ${pickupDate != null ? DateFormat('MMMM d, yyyy').format(pickupDate) : 'N/A'}"),
                Text("Time Slot: ${timeSlot ?? 'N/A'}"), // Use timeSlot
                Divider(height: 30, thickness: 1),

                // --- Items & Estimated Value ---
                Text("Items & Estimated Value", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                SizedBox(height: 8),

                Builder(builder: (context) {
                  final scrapItemsRaw = data['scrapItems'];
                  if (scrapItemsRaw == null || scrapItemsRaw is! List || scrapItemsRaw.isEmpty) {
                    return Text("No items recorded.");
                  }
                  List<Widget> itemWidgets = [];
                  for (var itemRaw in scrapItemsRaw) {
                    if (itemRaw is Map<String, dynamic>) {
                      final Map<String, dynamic> item = itemRaw;
                      final String itemName = item['itemName'] ?? 'Unknown Item';
                      final num amountNum = item['amount'] ?? 0;
                      final String unit = item['unit'] ?? 'unit';
                      final double itemCost = (item['calculatedCost'] as num?)?.toDouble() ?? 0.0;
                      String displayAmount = (unit.toLowerCase() == 'kg')
                          ? amountNum.toStringAsFixed(1)
                          : amountNum.round().toString();

                      // ✅ FIXED ROW:
                      itemWidgets.add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start, // Handles text wrapping
                            children: [
                              Expanded(
                                child: Text(
                                  "$itemName ($displayAmount $unit)",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                currencyFormatter.format(itemCost),
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                  return Column(children: itemWidgets);
                }),

                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),

                // ✅ 6. Display Total Estimated Weight
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Total Estimated Weight (kg):",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)
                    ),
                    Text(
                      // Read from the correct field name used in schedule_pickup
                        "${(data['totalEstimatedWeight_kg'] as num?)?.toStringAsFixed(1) ?? '0.0'} kg",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)
                    ),
                  ],
                ),
                SizedBox(height: 6), // Space between weight and value

                // Display Total Estimated Value
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Total Estimated Value:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16) // Make it bolder
                    ),
                    Text(
                      // Read from the estimatedCost field
                      currencyFormatter.format((data['estimatedCost'] as num?)?.toDouble() ?? 0.0),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: kPrimaryColor // Use theme color for emphasis
                      ),
                    ),
                  ],
                ),

                // Show Final Weight/Amount if completed
                if(status == 'Completed') ...[ /* ... Final Weight/Amount ... */ ],

                Divider(height: 30, thickness: 1),

                // --- Description ---
                Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                SizedBox(height: 8),
                Text(data['description']?.isNotEmpty ?? false ? data['description'] : 'No description provided.'),
                SizedBox(height: 40),


                // --- Action Buttons ---
                // ✅ 7. Use Row for Edit and Cancel buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space out buttons
                  children: [
                    // --- Edit Button (Conditional) ---
                    if (canEdit)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // Pass pickupId to SchedulePickup for edit mode
                              builder: (context) => SchedulePickup(pickupId: widget.pickupId),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit_outlined, size: 18), // Slightly smaller icon
                        label: Text('Edit Pickup'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor, // Or another suitable color like Colors.blue.shade700
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjusted padding
                            textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold) // Adjusted font size
                        ),
                      ),

                    // --- Cancel Button (Conditional) ---
                    if (canCancel)
                      ElevatedButton.icon(
                        onPressed: _isCancelling ? null : () => _confirmCancellation(context, pickupRef),
                        icon: _isCancelling
                            ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) // Smaller indicator
                            : Icon(Icons.cancel_outlined, size: 18),
                        label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Pickup'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjusted padding
                            textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold) // Adjusted font size
                        ),
                      ),
                  ],
                ),


                // --- Show Cancelled Status ---
                if (status == 'Cancelled')
                  Padding( // Add padding around chip
                    padding: const EdgeInsets.only(top: 20.0), // Space above chip if buttons are hidden
                    child: Center(
                      child: Chip(
                        label: Text('Pickup Cancelled', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.red.shade700,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),

                SizedBox(height: 20), // Add bottom padding

              ],
            ),
          );
        },
      ),
    );
  }
}