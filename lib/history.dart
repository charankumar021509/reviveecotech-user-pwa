import 'package:flutter/material.dart';
import 'widgets/pending_pickup_card.dart';
import 'widgets/completed_pickup_card.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HistoryScreen(),
  ));
}

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  PageController _pageController = PageController();
  int _selectedIndex = 0;

  // Dummy data for demo purposes
  List<Map<String, dynamic>> pendingHistory = [
    {
      'imagePath': 'assets/images/home/scraps/metal.png',
      'title': "Due in a week",       // e.g. "Due in a week"
      'date': '3 July 2024',        // e.g. "3 July 2024"
      'time': "Wednesday 11 a.m. To 1 p.m.",        // e.g. "Wednesday 11 a.m. To 1 p.m."
      'items': "Newspaper, Brass, Copper",       // e.g. "Newspaper, Brass, Copper"
      'daysLeft': 7,
    },
    {
      'imagePath': 'assets/images/home/scraps/bottle.png',
      'title': "Due in 3 days",       // e.g. "Due in a week"
      'date': '29 June 2024',        // e.g. "3 July 2024"
      'time': "Thursday 11 a.m. To 1 p.m.",        // e.g. "Wednesday 11 a.m. To 1 p.m."
      'items': "Newspaper, Brass, Copper",       // e.g. "Newspaper, Brass, Copper"
      'daysLeft': 3,
    }
  ];

  // List<Map<String, dynamic>> completedHistory = List.generate(
  //   9,
  //       (index) => {
  //     'imagePath': 'assets/images/home/scraps/bottle.png',
  //     'date': '3 June 2024',
  //     'time': '09 a.m. To 11 a.m.',
  //     'items': 'Newspaper, PET',
  //     'orderNumber': 123456187912,
  //     'amount': 220,
  //   },
  // );

  List<Map<String, dynamic>> completedHistory = [
    // {
    //   'imagePath': 'assets/images/home/scraps/bottle.png',
    //   'date': '3 June 2024',
    //   'time': '09 a.m. To 11 a.m.',
    //   'items': 'Newspaper, PET',
    //   'orderNumber': 123456187912,
    //   'amount': 220,
    // }
  ];

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
            'assets/icons/back.png',  // Path to your PNG
            width: 40,  // Adjust width as needed
            height: 40, // Adjust height as needed
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {
        //     Navigator.pop(context); // Navigate back to the previous screen
        //     // Handle back button press
        //   },
        // ),
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
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildHistoryView(
                  data: pendingHistory,
                  imagePath: 'assets/images/home/history/pending.png',
                  emptyMessage: 'No Pending history found !',
                  cardBuilder: (pickup) => PendingPickupCard(info: pickup),
                ),
                _buildHistoryView(
                  data: completedHistory,
                  imagePath: 'assets/images/home/history/completed.png',
                  emptyMessage: 'No Completed history found !',
                  cardBuilder: (pickup) => CompletedPickupCard(info: pickup),
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
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHistoryView({
    required List<Map<String, dynamic>> data,
    required String imagePath,
    required String emptyMessage,
    required Widget Function(Map<String, dynamic>) cardBuilder,
  }) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 130),
            Image.asset(imagePath, width: 300),
            const SizedBox(height: 16),
            Text('OOPS!!',style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            Text(emptyMessage,style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 180),
      ],
    ),
  );
}