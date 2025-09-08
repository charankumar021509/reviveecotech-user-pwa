import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'refer_page.dart'; // ✅ Import your ReferFriendPage

class ReviewAndRatePage extends StatefulWidget {
  @override
  _ReviewAndRatePageState createState() => _ReviewAndRatePageState();
}

class _ReviewAndRatePageState extends State<ReviewAndRatePage> {
  double _rating = 3;
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3E3),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Review & Rate",
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
            color: Color(0xFFFCF3E3),
          ),
        ),
        backgroundColor: const Color(0xFF013D5A),
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.57,
            child: const Icon(Icons.u_turn_left, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context), // back to previous page
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🖼 Asset image
            Image.asset('assets/review.png', height: 200),

            const SizedBox(height: 20),

            const Text(
              'Leave us a review',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 15),

            // ⭐ Rating Bar
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder:
                  (context, _) =>
                      const Icon(Icons.star, color: Color(0xFFA4C639)),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),

            const SizedBox(height: 20),

            // 📝 Comment Box
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a comment',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Submit Button
            ElevatedButton(
              onPressed: () {
                print('Rating: $_rating');
                print('Comment: ${_commentController.text}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8D862),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Submit Review",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 🚀 New Button to go to Refer Page
          ],
        ),
      ),
    );
  }
}
