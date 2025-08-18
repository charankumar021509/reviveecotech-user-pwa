import 'package:flutter/material.dart';

class PendingPickupCard extends StatelessWidget {
  final Map<String, dynamic> info;

  const PendingPickupCard({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String imagePath = info['imagePath'] ?? 'assets/images/home/scraps/metal.png';
    final String title = info['title'] ?? 'Upcoming Pickup';
    final String date = info['date'] ?? '';
    final String time = info['time'] ?? '';
    final String items = info['items'] ?? '';
    final int daysLeft = info['daysLeft'] is int ? info['daysLeft'] : 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (date.isNotEmpty) Text(date),
                      if (time.isNotEmpty) Text(time),
                      if (items.isNotEmpty)
                        Text(items, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "$daysLeft",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFa7cd47),
                        ),
                      ),
                      const Text("days to go", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: OutlinedButton(
                      onPressed: () {
                        // Optional: expose this as a callback parameter
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),
                // const SizedBox(width: 36),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Optional: expose this as a callback parameter
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA8CF45),
                        padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit Pickup', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
