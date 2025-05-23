import 'package:flutter/material.dart';

class CompletedPickupCard extends StatelessWidget {
  final Map<String, dynamic> info;

  const CompletedPickupCard({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String imagePath = info['imagePath'] ?? 'assets/sample.jpg';
    final String date = info['date'] ?? '';
    final String time = info['time'] ?? '';
    final String items = info['items'] ?? '';
    final String orderNumber = info['orderNumber']?.toString() ?? 'N/A';
    final String amount = info['amount']?.toString() ?? '0';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (date.isNotEmpty)
                    Text(
                      date,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  if (time.isNotEmpty) const SizedBox(height: 4),
                  if (time.isNotEmpty) Text(time),
                  if (items.isNotEmpty)
                    Text(
                      items,
                      style: const TextStyle(fontSize: 13),
                    ),
                  Text(
                    'Order No #$orderNumber',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Text(
              'Rs. $amount',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFFa7cd47),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
