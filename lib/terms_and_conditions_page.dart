import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'privacy_policy_page.dart'; // Import the privacy policy page

// ==== Constants (Ensure these match your main theme constants) ====
const kPrimaryColor = Color(0xFF013D5A); // From your other files
const kCreamColor = Color(0xFFFCF3E3); // From your other files
const kAccentColor = Color(0xFFA6CB4E); // Greenish accent

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  // Helper function for consistent heading style inside Cards
  Widget _buildCardHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 12.0, left: 16.0, right: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor, // Use primary color for headings
        ),
      ),
    );
  }

  // Helper function for consistent paragraph style inside Cards
  Widget _buildCardParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 16.0, right: 16.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.45, // Slightly increased line spacing
          color: Colors.grey.shade800, // Softer than pure black
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  // Helper for bullet points inside Cards
  Widget _buildCardBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 16.0, bottom: 8.0), // Increased left padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0), // Align bullet better
            child: Icon(Icons.circle, size: 8, color: kAccentColor), // Use accent color bullet
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, height: 1.45, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for ALL CAPS emphasis
  Widget _buildEmphasisParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 16.0, right: 16.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w600, // Make it slightly bolder
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }


  // Helper to create styled Card sections with numbering
  Widget _buildSectionCard({required int number, required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding( // Combine number and title in the heading
            padding: const EdgeInsets.only(top: 16.0, bottom: 12.0, left: 16.0, right: 16.0),
            child: Text(
              "$number. $title", // Add numbering
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ),
          const Divider(indent: 16, endIndent: 16, height: 1),
          const SizedBox(height: 12),
          ...children,
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define tap gesture recognizer for Privacy Policy link
    final TapGestureRecognizer privacyPolicyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
        );
      };

    return Scaffold(
      backgroundColor: kCreamColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Terms and Conditions',
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
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Last Updated ---
              _buildCardParagraph("Last Updated: October 25, 2025"), // Use relevant date

              // --- 1. Acceptance of Terms ---
              _buildSectionCard(
                  number: 1,
                  title: "Acceptance of Terms",
                  children: [
                    _buildCardParagraph(
                        "By downloading, accessing, or using the Revive Eco Tech mobile application and any associated services (collectively, the \"App\"), you agree to be bound by these Terms and Conditions (\"Terms\"). If you do not agree to these Terms, please do not access or use the App."
                    ),
                  ]
              ),

              // --- 2. Definitions ---
              _buildSectionCard(
                  number: 2,
                  title: "Definitions",
                  children: [
                    _buildCardBulletPoint("\"We,\" \"us,\" \"our,\" and \"Company\" refer to Revive Eco Tech."),
                    _buildCardBulletPoint("\"You\" and \"your\" refer to the individual user accessing the App."),
                    _buildCardBulletPoint("\"Content\" refers to all information, data, text, software, graphics, messages, and other materials, whether publicly posted or privately transmitted."),
                  ]
              ),

              // --- 3. User Accounts ---
              _buildSectionCard(
                  number: 3,
                  title: "User Accounts",
                  children: [
                    _buildCardParagraph("Account Creation: You may be required to register for an account to access certain features. You agree to provide accurate, current, and complete information during registration."),
                    _buildCardParagraph("Account Security: You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account."),
                    // ⚠️ Verify Age Requirement for your region/target audience
                    _buildCardParagraph("Eligibility: You must be at least 18 years old to use the App, or the age of majority in your jurisdiction. By using the App, you represent and warrant that you meet this age requirement."),
                  ]
              ),

              // --- 4. User Conduct and Responsibilities ---
              _buildSectionCard(
                  number: 4,
                  title: "User Conduct and Responsibilities",
                  children: [
                    _buildCardParagraph("You agree not to use the App to:"),
                    _buildCardBulletPoint("Violate any applicable law or regulation."),
                    _buildCardBulletPoint("Infringe upon the intellectual property rights of others."),
                    _buildCardBulletPoint("Harass, abuse, or harm another person."),
                    _buildCardBulletPoint("Transmit spam, chain letters, or other unsolicited communications."),
                    _buildCardBulletPoint("Upload or transmit viruses or any other malicious code."),
                    _buildCardBulletPoint("Use any automated system, such as \"robots\" or \"spiders,\" to access the App."),
                    _buildCardBulletPoint("Interfere with or disrupt the integrity or performance of the App."),
                  ]
              ),

              // --- 5. Intellectual Property ---
              _buildSectionCard(
                  number: 5,
                  title: "Intellectual Property",
                  children: [
                    _buildCardParagraph("Our Rights: The App, including its original content, features, functionality, logos, and design, are the exclusive property of Revive Eco Tech and its licensors and are protected by copyright, trademark, and other intellectual property laws."),
                    _buildCardParagraph("Your Content: For any content that you submit, post, or display on or through the App (\"User Content\"), you grant us a worldwide, non-exclusive, royalty-free, sublicensable, and transferable license to use, reproduce, distribute, and display that User Content in connection with operating and providing the App."),
                    _buildCardParagraph("You represent and warrant that you own or have the necessary rights to any User Content you submit."),
                  ]
              ),

              // --- 6. Payments and Subscriptions (If Applicable) ---
              // ⚠️ Include this section only if your app has payments/subscriptions
              /*
               _buildSectionCard(
                 number: 6,
                 title: "Payments and Subscriptions",
                 children: [
                   _buildCardParagraph("Fees: Certain features of the App may require payment of fees. You agree to pay all applicable fees as described in the App."),
                   _buildCardParagraph("Subscriptions: If you purchase a subscription, it will automatically renew at the end of each billing cycle until you cancel. You can manage or cancel your subscription through your device's app store (e.g., Apple App Store, Google Play Store)."),
                   _buildCardParagraph("Refunds: All payments are non-refundable, except as required by law or as otherwise stated in our refund policy. Refund requests are subject to the policies of the app store from which you made the purchase."),
                 ]
               ),
               */

              // --- 7. Privacy ---
              _buildSectionCard(
                  number: 7, // Adjust number if section 6 is removed
                  title: "Privacy",
                  children: [
                    Padding( // Use Padding for RichText
                      padding: const EdgeInsets.only(bottom: 12.0, left: 16.0, right: 16.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                            style: TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                color: Colors.grey.shade800,
                                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily // Use default font
                            ),
                            children: [
                              const TextSpan(text: "Your privacy is important to us. Our Privacy Policy, which is incorporated into these Terms by reference, explains how we collect, use, and share your information. Please review it "),
                              TextSpan(
                                text: "here.",
                                style: TextStyle(
                                  color: Colors.blue.shade700, // Link color
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: privacyPolicyRecognizer, // Make it tappable
                              ),
                            ]
                        ),
                      ),
                    ),
                  ]
              ),

              // --- 8. Third-Party Links and Services ---
              _buildSectionCard(
                  number: 8, // Adjust number if section 6 is removed
                  title: "Third-Party Links and Services",
                  children: [
                    _buildCardParagraph("The App may contain links to third-party websites or services that are not owned or controlled by us. We have no control over, and assume no responsibility for, the content, privacy policies, or practices of any third-party sites or services. You access them at your own risk."),
                  ]
              ),

              // --- 9. Disclaimer of Warranties ---
              _buildSectionCard(
                  number: 9, // Adjust number if section 6 is removed
                  title: "Disclaimer of Warranties",
                  children: [
                    _buildEmphasisParagraph( // Use emphasis helper for ALL CAPS
                        "THE APP IS PROVIDED ON AN \"AS IS\" AND \"AS AVAILABLE\" BASIS WITHOUT ANY WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. WE DO NOT GUARANTEE THAT THE APP WILL BE UNINTERRUPTED, SECURE, OR ERROR-FREE."
                    ),
                  ]
              ),

              // --- 10. Limitation of Liability ---
              _buildSectionCard(
                  number: 10, // Adjust number if section 6 is removed
                  title: "Limitation of Liability",
                  children: [
                    _buildEmphasisParagraph( // Use emphasis helper for ALL CAPS
                        "TO THE FULLEST EXTENT PERMITTED BY LAW, IN NO EVENT WILL REVIVE ECO TECH, ITS AFFILIATES, OFFICERS, EMPLOYEES, AGENTS, SUPPLIERS OR LICENSORS BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL OR PUNITIVE DAMAGES... [Ensure the full text is included here]" // ⚠️ Add the rest of your Limitation of Liability text
                    ),
                    // Add more _buildEmphasisParagraph or _buildCardParagraph as needed for the rest of section 10
                  ]
              ),

              // Add more sections (e.g., Governing Law, Changes to Terms, Contact Us)
              // using _buildSectionCard(...)

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}