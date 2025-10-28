import 'package:flutter/material.dart';
import 'faq_page.dart'; // Import the FAQ page
import 'privacy_policy_page.dart'; // Import Privacy Policy
import 'terms_and_conditions_page.dart'; // Import Terms

// ==== Constants ====
const kPrimaryColor = Color(0xFF013D5A);
const kCreamColor = Color(0xFFFCF3E3);
const kAccentColor = Color(0xFFA6CB4E);

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  // Helper for building tappable list tiles
  Widget _buildLinkTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget page, // The page to navigate to
    Color iconColor = kPrimaryColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryColor),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey.shade600),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }

  // Helper for displaying contact info
  Widget _buildContactInfo({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
              Text(value, style: TextStyle(fontSize: 16, color: kPrimaryColor, fontWeight: FontWeight.w500)),
            ],
          )
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
          'Help & Support',
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
            // --- Contact Information Section ---
            Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "If you have any questions or need assistance, feel free to reach out to us:",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.4),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Use the contact info from your Privacy Policy
                    _buildContactInfo(
                      icon: Icons.email_outlined,
                      label: "Email",
                      value: "reviveecotech@gmail.com",
                    ),
                    Divider(height: 20),
                    _buildContactInfo(
                      icon: Icons.phone_outlined,
                      label: "Phone",
                      value: "6304218355",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Quick Links Section ---
            Text(
              "Quick Links",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildLinkTile(
              context: context,
              icon: Icons.help_outline_rounded,
              title: "Frequently Asked Questions (FAQs)",
              page: const FaqPage(), // Navigate to FaqPage
            ),
            _buildLinkTile(
              context: context,
              icon: Icons.description_outlined,
              title: "Terms & Conditions",
              page: const TermsAndConditionsPage(), // Navigate to Terms
              iconColor: Colors.orange.shade700,
            ),
            _buildLinkTile(
              context: context,
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              page: const PrivacyPolicyPage(), // Navigate to Privacy Policy
              iconColor: Colors.blue.shade700,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}