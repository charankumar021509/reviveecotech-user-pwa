import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:revive_eco_tech_app/widgets/drive_model.dart';
import 'package:revive_eco_tech_app/widgets/drive_card.dart'; // Re-use the card
import 'package:revive_eco_tech_app/drive_details_page.dart';
import 'package:revive_eco_tech_app/society_campaign_page.dart';

// --- Constants (copied from home.dart) ---
const kPrimaryColor = Color(0xFF013856);
const kAccentColor = Color(0xFFa7cd47);
const kCreamColor = Color(0xFFfcf3e2);

class AllDrivesPage extends StatelessWidget {
  const AllDrivesPage({super.key});

  void _goToDriveDetails(BuildContext context, Drive drive) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriveDetailsPage(drive: drive),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamColor,
      appBar: AppBar(
        title: const Text(
          "Upcoming Drives",
          style: TextStyle(color: kCreamColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kCreamColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query Firestore for all drives from today onwards
        stream: FirebaseFirestore.instance
            .collection('drives')
            .where('date', isGreaterThanOrEqualTo: Timestamp.now())
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          // --- Loading State ---
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Error State ---
          if (snapshot.hasError) {
            return const Center(
                child: Text("Could not load drives. Please try again later."));
          }

          final driveDocs = snapshot.data!.docs;

          // --- Empty State ---
          if (driveDocs.isEmpty) {
            return _buildEmptyState(context);
          }

          // --- Data State ---
          final drives =
          driveDocs.map((doc) => Drive.fromFirestore(doc)).toList();

          // We use a GridView here instead of a ListView
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cards per row
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: (200 / 220), // Aspect ratio from our DriveCard
            ),
            itemCount: drives.length,
            itemBuilder: (context, index) {
              final drive = drives[index];
              return DriveCard(
                drive: drive,
                onTap: () => _goToDriveDetails(context, drive),
              );
            },
          );
        },
      ),
    );
  }

  // Your requested empty state with a link to Society Campaign
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              "No Drives Scheduled Yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Check back soon for events in your area, or start your own!",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.campaign, color: kPrimaryColor),
              label: const Text(
                "Start a Society Campaign",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SocietyCampaignPage()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
