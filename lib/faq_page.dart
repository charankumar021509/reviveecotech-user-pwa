import 'package:flutter/material.dart';

// ==== Constants ====
const kPrimaryColor = Color(0xFF013D5A);
const kCreamColor = Color(0xFFFCF3E3);
const kAccentColor = Color(0xFFA6CB4E);

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  // Helper for consistent ExpansionTile styling
  Widget _buildFaqTile(String question, String answer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius
      child: ExpansionTile(
        iconColor: kPrimaryColor,
        collapsedIconColor: Colors.grey.shade700,
        title: Text(
          question,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600, // Semi-bold for question
            color: kPrimaryColor,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'FAQs',
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
            color: kCreamColor,
          ),
        ),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kCreamColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFaqTile(
              "What do we do?",
              // ⭐ Updated Answer
              "We are a recycling service that collects recyclable materials from households and businesses, sorts them, and sends them to manufacturers who can reuse them to create new products. Our goal is to reduce waste and promote sustainability.",
            ),
            _buildFaqTile(
              "Who are we?",
              // ⭐ Updated Answer
              "We are a team of passionate individuals dedicated to making recycling easy and accessible for everyone. Our mission is to create a sustainable future by reducing waste and promoting responsible consumption.",
            ),
            _buildFaqTile(
              "How to get the App?",
              // ⭐ Updated Answer (Combined duplicate info)
              "We have a user-friendly app available for both Android and iOS. You can download it from the Google Play Store or Apple App Store by searching for 'Revive Eco Tech'.",
            ),
            _buildFaqTile(
              "How to Register in App?",
              // ⭐ Updated Answer
              "After downloading and opening the app, select the 'Sign Up' option. Follow the on-screen instructions to create your account using your name, email, and phone number. Once registered, you can schedule pickups, track your recycling progress, and earn rewards.",
            ),
            _buildFaqTile(
              "How to become a partner?",
              // ⭐ Updated Answer
              "We are always looking for partners who share our vision of sustainability. If you are a manufacturer or a business interested in collaborating with us, please reach out through the contact details provided in the 'Help & Support' section. We would love to discuss potential partnerships.",
            ),
            // Add more FAQs as needed using _buildFaqTile()
          ],
        ),
      ),
    );
  }
}