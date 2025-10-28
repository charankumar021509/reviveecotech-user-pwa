import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Import Firestore

// Constants (assuming from your theme)
const kPrimaryColor = Color(0xFF013D5A);
const kCreamColor = Color(0xFFFCF3E3);
const kAccentColor = Color(0xFFA6CB4E); // Button color


class ReviewAndRatePage extends StatefulWidget {
  @override
  _ReviewAndRatePageState createState() => _ReviewAndRatePageState();
}

class _ReviewAndRatePageState extends State<ReviewAndRatePage> {
  double _rating = 3.0; // Start with a default
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false; // ✅ State for loading indicator

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ✅ Function to handle submission to Firestore
  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;

    // --- Validations ---
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to submit a review."), backgroundColor: Colors.red),
      );
      return;
    }
    // Optional: Add validation for comment length if desired
    // if (_commentController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Please enter a comment."), backgroundColor: Colors.orange),
    //   );
    //   return;
    // }

    setState(() => _isSubmitting = true); // Show loading indicator

    try {
      // --- Prepare Data ---
      final reviewData = {
        'userId': user.uid,
        'userName': user.displayName ?? "Anonymous", // Get name if available
        'rating': _rating,
        'comment': _commentController.text.trim(), // Trim whitespace
        'createdAt': FieldValue.serverTimestamp(), // Use server time
      };

      // --- Save to Firestore ---
      await FirebaseFirestore.instance.collection('reviews').add(reviewData);

      // --- Success Feedback ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Thank you for your review!"), backgroundColor: kAccentColor), // Use accent color
        );
        // Optional: Navigate back after successful submission
        Navigator.pop(context);
      }

    } catch (e) {
      // --- Error Feedback ---
      print("Error submitting review: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit review. Please try again."), backgroundColor: Colors.red),
        );
      }
    } finally {
      // --- Hide Loading Indicator ---
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamColor, // Use constant
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Review & Rate",
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
            color: kCreamColor, // Use constant
          ),
        ),
        backgroundColor: kPrimaryColor, // Use constant
        leading: IconButton(
          // Use standard back icon for consistency
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kCreamColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView( // ✅ Wrap in SingleChildScrollView
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20), // Increased vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🖼 Asset image
            Image.asset('assets/images/review.png', height: 180), // Slightly smaller image

            const SizedBox(height: 25),

            const Text(
              'Share Your Experience', // More engaging text
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: kPrimaryColor), // Use primary color
            ),
            const SizedBox(height: 8),
            const Text(
              'How would you rate our service?', // Added subtext
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),


            const SizedBox(height: 20),

            // ⭐ Rating Bar
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false, // Keep as whole stars
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 6.0), // Slightly more padding
              itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded, // Rounded star icon
                  color: kAccentColor // Use accent color
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
              glowColor: kAccentColor.withOpacity(0.5), // Add glow effect
            ),

            const SizedBox(height: 25),

            // 📝 Comment Box
            TextField(
              controller: _commentController,
              maxLines: 4, // Allow slightly more lines
              decoration: InputDecoration(
                hintText: 'Tell us more about your experience (optional)',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Consistent border radius
                  borderSide: BorderSide(color: Colors.grey.shade300), // Subtle border
                ),
                enabledBorder: OutlineInputBorder( // Border when not focused
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder( // Border when focused
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kPrimaryColor, width: 1.5), // Use primary color on focus
                ),
              ),
              textCapitalization: TextCapitalization.sentences, // Capitalize sentences
            ),

            const SizedBox(height: 30),

            // ✅ Submit Button with Loading Indicator
            ElevatedButton(
              // Disable button while submitting
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor, // Use constant
                foregroundColor: kPrimaryColor, // Darker text on light button
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: const Size(double.infinity, 50),
                elevation: 3, // Add subtle elevation
              ),
              child: _isSubmitting // Show indicator or text
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
              )
                  : const Text(
                "Submit Review",
                style: TextStyle(
                  // color: kPrimaryColor, // Set via foregroundColor
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Standard button text size
                ),
              ),
            ),
            const SizedBox(height: 20), // Add space at the bottom
          ],
        ),
      ),
    );
  }
}

