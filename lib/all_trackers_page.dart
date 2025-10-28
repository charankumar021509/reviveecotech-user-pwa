// lib/all_trackers_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:revive_eco_tech_app/widgets/pickup_tracker.dart';
import 'pickup_details_page.dart'; // ✅ 1. Import details page if not already done

// Constants
const kPrimaryColor = Color(0xFF013856);
const kCreamColor = Color(0xFFfcf3e2);
const kAccentColor = Color(0xFFa7cd47); // Added accent color just in case

class AllTrackersPage extends StatefulWidget {
  const AllTrackersPage({super.key});

  @override
  State<AllTrackersPage> createState() => _AllTrackersPageState();
}

class _AllTrackersPageState extends State<AllTrackersPage> {
  // Helper function to map status to step
  int _mapStatusToStep(String? status) {
    switch (status) {
      case 'Pending': return 1;
      case 'Confirmed': return 2;
      case 'Out-for-Pickup': return 3;
    // Note: Completed/Cancelled won't be fetched by the stream query
      default: return 0;
    }
  }

  // ✅ 2. Function to get the STREAM of pending/active pickups
  Stream<QuerySnapshot> _getPendingPickupsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty(); // Return empty stream if no user
    }

    return FirebaseFirestore.instance
        .collection('pickups')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereIn: ['Pending', 'Confirmed', 'Out-for-Pickup']) // Only fetch active ones
        .orderBy('pickupDate') // Order by date
        .snapshots(); // Use snapshots() for real-time stream
  }

  // ✅ Helper to navigate to details (optional but good practice)
  void _navigateToDetails(String pickupId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupDetailsPage(pickupId: pickupId),
      ),
    );
    // No need to call refresh here, StreamBuilder handles it
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamColor,
      appBar: AppBar(
        title: const Text('All Upcoming Pickups'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        leading: IconButton( // Added standard back button
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // ✅ 3. Changed FutureBuilder to StreamBuilder
      body: StreamBuilder<QuerySnapshot>(
        stream: _getPendingPickupsStream(), // Use the stream function
        builder: (context, snapshot) {
          // --- Handle Loading State ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          // --- Handle Error State ---
          if (snapshot.hasError) {
            print("Error in StreamBuilder: ${snapshot.error}"); // Log the error
            return Center(child: Text("Something went wrong! Error: ${snapshot.error}"));
          }

          // --- Handle No Data State ---
          // Access docs via snapshot.data!.docs
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column( // Improved empty state
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "You have no upcoming pickups.",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // --- Display Data ---
          // Access docs via snapshot.data!.docs
          final pickups = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Add padding around list
            itemCount: pickups.length,
            itemBuilder: (context, index) {
              final pickupDoc = pickups[index];
              final data = pickupDoc.data() as Map<String, dynamic>;
              final pickupDate = (data['pickupDate'] as Timestamp?)?.toDate(); // Handle potential null

              // ✅ 4. Wrap PickupTracker in GestureDetector
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjusted padding
                child: GestureDetector( // Make the tracker tappable
                  onTap: () => _navigateToDetails(pickupDoc.id),
                  child: PickupTracker(
                    currentStep: _mapStatusToStep(data['status']),
                    pickupDate: pickupDate,
                    pickupId: pickupDoc.id, // Pass the ID
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}