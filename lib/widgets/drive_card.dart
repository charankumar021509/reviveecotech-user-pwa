import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/widgets/drive_model.dart';
import 'package:intl/intl.dart';

// --- Constants (copied from home.dart) ---
const kPrimaryColor = Color(0xFF013856);
const kAccentColor = Color(0xFFa7cd47);

class DriveCard extends StatelessWidget {
  final Drive drive;
  final VoidCallback onTap;

  const DriveCard({
    super.key,
    required this.drive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 1. 'Hero' WIDGET IS MOVED!
    // It is no longer wrapping the whole Container.
    return Container(
      width: 200, // Fixed width for horizontal scroller
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // --- Card Content ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                Expanded(
                  flex: 3,
                  // ✅ 2. 'Hero' WIDGET NOW WRAPS THE IMAGE
                  // This matches the Hero on the details page.
                  child: Hero(
                    tag: 'drive_image_${drive.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.asset(
                        drive.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Center(
                            child: Icon(Icons.image, color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
                // Text Details
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drive.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          // Format date: e.g., "Sat, Nov 8"
                          drive.isPlaceholder
                              ? drive.location // Show "Your Society..."
                              : DateFormat('EEE, MMM d').format(drive.date),
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- "Coming Soon" Tag (if placeholder) ---
            if (drive.isPlaceholder)
              Positioned(
                top: 8,
                left: 0,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "COMING SOON",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

