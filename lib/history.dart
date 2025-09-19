import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/widgets/pending_pickup_card.dart';
import 'package:revive_eco_tech_app/widgets/completed_pickup_card.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✨ NEW
import 'package:cloud_firestore/cloud_firestore.dart'; // ✨ NEW
import 'package:intl/intl.dart'; // ✨ NEW (for date formatting)

// void main() { // You can remove this main, as history is not the main entry point
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: HistoryScreen(),
//   ));
// }

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  // ✨ NEW: State variables for live data
  bool _isLoading = true;
  List<DocumentSnapshot> _pendingPickups = [];
  List<DocumentSnapshot> _completedPickups = [];

  // ✨ REMOVED: Dummy data
  // List<Map<String, dynamic>> pendingHistory = [...];
  // List<Map<String, dynamic>> completedHistory = [...];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // ✨ NEW: Function to fetch data from Firestore
  Future<void> _fetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final pickupsRef = FirebaseFirestore.instance.collection('pickups');

      // Get Pending Pickups
      final pendingSnapshot = await pickupsRef
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Pending') // Or any non-completed statuses
          .orderBy('pickupDate', descending: true)
          .get();

      // Get Completed Pickups
      final completedSnapshot = await pickupsRef
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Completed')
          .orderBy('pickupDate', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _pendingPickups = pendingSnapshot.docs;
          _completedPickups = completedSnapshot.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error fetching history: $e");
      // You might want to show a SnackBar here
    }
  }

  void _onTabTap(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003049),
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/back.png', // Path to your PNG
            width: 40, // Adjust width as needed
            height: 40, // Adjust height as needed
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTabButton(0, "Pending"),
                const SizedBox(width: 0),
                _buildTabButton(1, "Completed"),
              ],
            ),
          ),
          Expanded(
            // ✨ NEW: Show loading indicator
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildHistoryView(
                  // ✨ UPDATED: Pass live data
                  data: _pendingPickups,
                  imagePath: 'assets/images/home/history/pending.png',
                  emptyMessage: 'No Pending history found !',
                  cardBuilder: (doc) {
                    // ✨ NEW: Transform Firestore doc to map for your card
                    final data = doc.data() as Map<String, dynamic>;
                    final pickupDate =
                    (data['pickupDate'] as Timestamp).toDate();
                    final daysLeft =
                        pickupDate.difference(DateTime.now()).inDays + 1;

                    final info = {
                      'imagePath': 'assets/images/home/scraps/metal.png', // Placeholder image
                      'title': "Due in $daysLeft day${daysLeft == 1 ? '' : 's'}",
                      'date': DateFormat('d MMMM yyyy').format(pickupDate),
                      'time': data['pickupTimeSlot'] ?? 'No time slot',
                      'items': (data['scrapTypes'] as List<dynamic>).join(', '),
                      'daysLeft': daysLeft,
                    };
                    return PendingPickupCard(info: info);
                  },
                ),
                _buildHistoryView(
                  // ✨ UPDATED: Pass live data
                  data: _completedPickups,
                  imagePath: 'assets/images/home/history/completed.png',
                  emptyMessage: 'No Completed history found !',
                  cardBuilder: (doc) {
                    // ✨ NEW: Transform Firestore doc to map for your card
                    final data = doc.data() as Map<String, dynamic>;
                    final pickupDate =
                    (data['pickupDate'] as Timestamp).toDate();

                    final info = {
                      'imagePath': 'assets/images/home/scraps/bottle.png', // Placeholder image
                      'date': DateFormat('d MMMM yyyy').format(pickupDate),
                      'time': data['pickupTimeSlot'] ?? 'No time slot',
                      'items': (data['scrapTypes'] as List<dynamic>).join(', '),
                      'orderNumber': doc.id, // Use doc ID as order number
                      'amount': data['amount'] ?? 0, // Use 0 if 'amount' is not set
                    };
                    return CompletedPickupCard(info: info);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () => _onTabTap(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedIndex == index
                ? const Color(0xFFa7cd47)
                : Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black12),
            ),
          ),
          child:
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ✨ UPDATED: Generics to handle DocumentSnapshot
  Widget _buildHistoryView({
    required List<DocumentSnapshot> data,
    required String imagePath,
    required String emptyMessage,
    required Widget Function(DocumentSnapshot) cardBuilder,
  }) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 130),
            Image.asset(imagePath, width: 300),
            const SizedBox(height: 16),
            Text(
              'OOPS!!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              emptyMessage,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return cardBuilder(data[index]);
      },
    );
  }
}

// This widget seems to be unused, you can remove it if you wish
Widget _buildEmptyState({
  required String imagePath,
  required String title,
  required String message,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath, height: 250),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 180),
      ],
    ),
  );
}