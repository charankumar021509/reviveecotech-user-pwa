import 'package:flutter/material.dart';

class PickupTracker extends StatelessWidget {
  final int currentStep;

  const PickupTracker({super.key, required this.currentStep});

  final List<String> stepLabels = const [
    "Pickup\nscheduled",
    "On the way",
    "Reached your\nLocation",
    "Estimated & Paid",
    "Pickup\ncompleted",
  ];

  final List<IconData> stepIcons = const [
    Icons.event,        // Pickup scheduled timer
    Icons.local_shipping, // On the way
    Icons.location_on,  // Reached location
    Icons.payment,      // Estimated & Paid
    Icons.check_circle, // Pickup completed
  ];

  // final List<String> iconAssets = const [
  //   'assets/icons/pickup.png',
  //   'assets/icons/truck.png',
  //   'assets/icons/location.png',
  //   'assets/icons/payment.png',
  //   'assets/icons/completed.png',
  // ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16),
          child: Text(
            "Pickup Tracker",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (index) {
              bool isCompleted = index < currentStep;
              bool isActive = index == currentStep;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index != 0)
                          Expanded(
                            child: Container(
                              height: 4,
                              color: isCompleted
                                  ? const Color(0xFFa9c855)
                                  : Colors.grey[300],
                            ),
                          ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted || isActive
                                ? const Color(0xFFa9c855)
                                : Colors.grey[300],
                            border: index == 4
                                ? Border.all(
                              color: Colors.grey,
                              width: 2,
                            )
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              stepIcons[index],
                              color: isCompleted || isActive
                                  ? Colors.white
                                  : Colors.grey,
                              //size: 28,
                            ),
                          ),
                        ),
                        if (index != 4)
                          Expanded(
                            child: Container(
                              height: 4,
                              color: index < currentStep - 1
                                  ? const Color(0xFFa9c855)
                                  : Colors.grey[300],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stepLabels[index],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
