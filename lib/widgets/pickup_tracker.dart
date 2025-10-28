// lib/widgets/pickup_tracker.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pickup_details_page.dart'; // ✅ 1. IMPORT THE DETAILS PAGE

// Constants
const kPrimaryColor = Color(0xFF013856);
const kAccentColor = Color(0xFFa7cd47);

class PickupTracker extends StatelessWidget {
  final int currentStep;
  final DateTime? pickupDate;
  final bool showUpcomingTag;
  final String? pickupId; // ✅ 2. ADD PICKUP ID

  const PickupTracker({
    super.key,
    required this.currentStep,
    this.pickupDate,
    this.showUpcomingTag = false,
    this.pickupId, // ✅ 2. ADD TO CONSTRUCTOR
  });

  static const List<IconData> _stepIcons = [
    Icons.inventory_2_outlined,
    Icons.thumb_up_alt_outlined,
    Icons.local_shipping_outlined,
    Icons.check_circle_outline,
  ];

  static const List<String> _stepLabels = [
    "Pending",
    "Confirmed",
    "Out for\nPickup",
    "Completed",
  ];

  @override
  Widget build(BuildContext context) {
    final String formattedDate = pickupDate != null
        ? DateFormat('MMMM d, yyyy').format(pickupDate!)
        : '';

    // ✅ 3. WRAP THE STACK IN A GESTURE DETECTOR
    return GestureDetector(
      onTap: () {
        // Navigate only if we have an ID
        if (pickupId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PickupDetailsPage(pickupId: pickupId!),
            ),
          );
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // This is the main tracker card (Container)
          Container(
            // ... rest of the Container setup remains the same ...
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Row
                if (pickupDate != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            color: kPrimaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Pickup on: $formattedDate",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Steps Row
                Row(
                  children: [
                    for (var i = 0; i < _stepLabels.length; i++) ...[
                      if (i > 0)
                        _buildConnector(isActive: i < currentStep),
                      _buildStep(
                        context: context,
                        icon: _stepIcons[i],
                        label: _stepLabels[i],
                        isActive: (i + 1) == currentStep,
                        isCompleted: (i + 1) < currentStep,
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),

          // Upcoming Tag
          if (showUpcomingTag)
            Positioned(
              // ... rest of the Positioned setup remains the same ...
              top: 10,
              right: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kAccentColor,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: const RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    "UPCOMING",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // _buildConnector and _buildStep methods remain exactly the same
  Widget _buildConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? kAccentColor : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    final Color circleColor = (isActive || isCompleted) ? kAccentColor : const Color(0xFFE0E0E0);
    final Color iconAndTextColor = (isActive || isCompleted) ? kPrimaryColor : Colors.grey.shade600;

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: circleColor, width: 2),
            color: (isActive) ? kAccentColor.withOpacity(0.2) : Colors.transparent,
          ),
          child: Icon(icon, color: iconAndTextColor, size: 22),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 65,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: iconAndTextColor,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}