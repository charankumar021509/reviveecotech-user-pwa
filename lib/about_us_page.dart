import 'package:flutter/material.dart';

// ==== Constants (Ensure these match your main theme constants) ====
const kPrimaryColor = Color(0xFF013D5A);
const kCreamColor = Color(0xFFFCF3E3);
const kAccentColor = Color(0xFFA6CB4E);

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'About Us',
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section ---
            Center(
              child: Icon(
                Icons.recycling_rounded, // Relevant icon
                size: 80,
                color: kAccentColor,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Revive Eco Tech',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                  fontFamily: 'RedHatDisplay',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Earn Money While Recycling',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                  fontFamily: 'RedHatDisplay',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 40, thickness: 1, indent: 20, endIndent: 20),

            // --- Mission/Description ---
            Text(
              'Our Mission',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Revive is the ultimate solution for eco-conscious families looking to make a positive impact on the environment while earning money through convenient scrap recycling services.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              'Trusted by thousands of healthy families, we aim to simplify the recycling process, making it rewarding for both you and the planet.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),

            // --- Footer Info ---
            Center(
              child: Text(
                '© 2025 Revive Ecotech Ltd', // Updated Year
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}