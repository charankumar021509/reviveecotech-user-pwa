import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/widgets/pending_pickup_card.dart';
import 'package:revive_eco_tech_app/widgets/completed_pickup_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'pickup_details_page.dart'; // Import the details page

// ==== Constants (Ensure these match your app's theme) ====
const kPrimaryColor = Color(0xFF003049); // From your original AppBar
const kCreamColor = Color(0xFFFCF3E9); // From your original background
const kAccentColor = Color(0xFFa7cd47); // From your original tab button

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Use late initialization for controllers if disposed properly
  late PageController _pageController;
  int _selectedIndex = 0;

  bool _isLoading = true;
  List<DocumentSnapshot> _pendingPickups = [];
  List<DocumentSnapshot> _completedOrCancelledPickups = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex); // Initialize here
    _fetchHistory();
  }

  // ✅ Dispose controller
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  // Fetch data including Cancelled
  Future<void> _fetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Reset lists and set loading state correctly
    if (mounted) {
      setState(() {
        _isLoading = true;
        _pendingPickups = [];
        _completedOrCancelledPickups = [];
      });
    }


    try {
      final pickupsRef = FirebaseFirestore.instance.collection('pickups');
      final now = Timestamp.now(); // Get current time for filtering if needed

      // Get Pending/Upcoming Pickups
      final pendingSnapshot = await pickupsRef
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['Pending', 'Confirmed', 'Out-for-Pickup'])
      // Optional: Only show pickups scheduled for today or later?
      // .where('pickupDate', isGreaterThanOrEqualTo: now)
          .orderBy('pickupDate', descending: true) // Show soonest upcoming last, or latest first? Let's keep latest first for now.
          .get();

      // Get Completed & Cancelled Pickups
      final completedSnapshot = await pickupsRef
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['Completed', 'Cancelled'])
          .orderBy('pickupDate', descending: true) // Show most recent past first
          .get();

      if (mounted) {
        setState(() {
          _pendingPickups = pendingSnapshot.docs;
          _completedOrCancelledPickups = completedSnapshot.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error fetching history: $e");
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Animate page view when tab is tapped
  void _onTabTap(int index) {
    if (!_pageController.hasClients) return; // Check if controller is ready
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    // Update state directly here too for instant UI feedback
    // setState(() => _selectedIndex = index); // No, let onPageChanged handle state
  }

  // Update selected index when page is swiped
  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  // Navigate to details page and refresh on return
  void _navigateToDetails(String pickupId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupDetailsPage(pickupId: pickupId),
      ),
    ).then((_) {
      // Re-fetch history when returning
      _fetchHistory();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // --- Tab Buttons ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTabButton(0, "Upcoming"),
                const SizedBox(width: 10),
                _buildTabButton(1, "Past"),
              ],
            ),
          ),
          // --- Page View ---
          Expanded(
            // Ensure PageView takes remaining space
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
                : PageView(
              controller: _pageController, // Linked
              onPageChanged: _onPageChanged, // Linked
              children: [
                // --- Upcoming Pickups Page ---
                _buildHistoryView(
                  // Use a unique key if needed, but usually not for PageView children
                  // key: const PageStorageKey('upcomingList'),
                  data: _pendingPickups,
                  imagePath: 'assets/images/home/history/pending.png',
                  emptyMessage: 'No upcoming pickups found!',
                  cardBuilder: (doc) {
                    return GestureDetector(
                        onTap: () => _navigateToDetails(doc.id),
                        child: PendingPickupCard(pickupDoc: doc)
                    );
                  },
                ),
                // --- Past Pickups Page ---
                _buildHistoryView(
                  // key: const PageStorageKey('pastList'),
                  data: _completedOrCancelledPickups,
                  imagePath: 'assets/images/home/history/completed.png',
                  emptyMessage: 'No past pickups found!',
                  cardBuilder: (doc) {
                    return GestureDetector(
                        onTap: () => _navigateToDetails(doc.id),
                        child: CompletedPickupCard(pickupDoc: doc)
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTabButton(int index, String label) {
    bool isActive = _selectedIndex == index;
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () => _onTabTap(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? kAccentColor : Colors.white,
            foregroundColor: Colors.black,
            elevation: isActive ? 3 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isActive ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHistoryView({
    // Key? key, // Pass key if needed
    required List<DocumentSnapshot> data,
    required String imagePath,
    required String emptyMessage,
    required Widget Function(DocumentSnapshot) cardBuilder,
  }) {
    if (data.isEmpty) {
      // Using your original empty state
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 130),
            Image.asset(imagePath, width: 300),
            const SizedBox(height: 16),
            const Text(
              'OOPS!!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              emptyMessage,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      );
    }

    // Use ListView.separated for better spacing control
    return ListView.separated(
      // key: key, // Pass key if needed for state preservation
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return cardBuilder(data[index]);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12), // Consistent spacing
    );
  }
}