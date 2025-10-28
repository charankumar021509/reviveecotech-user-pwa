import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl

// Constants
const kAccentColor = Color(0xFFa7cd47);

class CompletedPickupCard extends StatelessWidget {
  // ✅ Accept DocumentSnapshot instead of Map
  final DocumentSnapshot pickupDoc;

  const CompletedPickupCard({Key? key, required this.pickupDoc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Extract data from snapshot
    final data = pickupDoc.data() as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'Completed'; // Get status
    final pickupDate = (data['pickupDate'] as Timestamp?)?.toDate();
    final timeSlot = data['pickupTimeSlot'] as String? ?? '';
    final itemsList = data['scrapTypes'] as List<dynamic>? ?? [];
    final items = itemsList.join(', ');
    final orderNumber = pickupDoc.id; // Use document ID
    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0; // Handle potential null amount

    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final formattedDate = pickupDate != null ? DateFormat('d MMMM yyyy').format(pickupDate) : 'N/A';
    final formattedAmount = currencyFormatter.format(amount);

    // ✅ Placeholder image logic (you might want to customize this)
    String imagePath = 'assets/images/home/scraps/bottle.png'; // Default
    if (itemsList.isNotEmpty) {
      // Basic logic: use an icon based on the first item
      String firstItem = itemsList.first.toString().toLowerCase();
      if (firstItem.contains('paper')) imagePath = 'assets/images/home/scraps/newspaper.png';
      else if (firstItem.contains('metal')) imagePath = 'assets/images/home/scraps/metal.png';
      // Add more conditions if needed
    }


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 0), // Removed default margin for consistency in ListView
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      // ✅ Conditionally change background for cancelled orders
      color: status == 'Cancelled' ? Colors.grey.shade200 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath, // Use dynamic image path
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                // Optional: Add error handling for image loading
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 70, height: 70, color: Colors.grey.shade300, child: Icon(Icons.image_not_supported)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (timeSlot.isNotEmpty) const SizedBox(height: 4),
                  if (timeSlot.isNotEmpty) Text(timeSlot),
                  if (items.isNotEmpty)
                    Text(
                      items,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      maxLines: 1, // Prevent long item lists from overflowing
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    'Order No #${orderNumber.substring(0, 6)}...', // Show partial ID
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            // ✅ Display Status or Amount
            if (status == 'Cancelled')
              Chip(
                label: Text('Cancelled', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.red.shade700,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                visualDensity: VisualDensity.compact, // Make chip smaller
              )
            else
              Text(
                formattedAmount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: kAccentColor, // Use constant
                ),
              ),
          ],
        ),
      ),
    );
  }
}