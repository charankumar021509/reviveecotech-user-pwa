import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/launch_page.dart';
import 'package:revive_eco_tech_app/utilities/tiles.datrt.dart';
import 'privacy_policy_page.dart';
import 'terms_and_conditions_page.dart';
import 'about_us_page.dart';
import 'faq_page.dart';
import 'help_support_page.dart';

class Settings_page extends StatefulWidget {
  const Settings_page({super.key});

  @override
  State<Settings_page> createState() => _SettingsState();
}

class _SettingsState extends State<Settings_page> {
  @override
  Widget build(BuildContext context) {
    // ✅ REMOVED Scaffold, AppBar, and backgroundColor
    // The main Scaffold in home.dart handles them.
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
      child: ListView(
        children: [
          Tiles(
            tilename: 'About Us',
            iconPath: Icons.info,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()));
            },
          ),
          Tiles(
            tilename: 'Help & Support',
            iconPath: Icons.headset_mic,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HelpSupportPage()));
            },
          ),
          Tiles(
            tilename: 'Privacy Policy',
            iconPath: Icons.lock,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
            },
          ),
          Tiles(
            tilename: 'Terms & Conditions',
            iconPath: Icons.description,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TermsAndConditionsPage()));
            },
          ),
          Tiles(
            tilename: 'FAQs',
            iconPath: Icons.help_center,
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => FaqPage()));
            },
          ),
          Tiles(
            tilename: 'Log Out',
            iconPath: Icons.logout,
            onTap: () async {
              await FirebaseAuth.instance
                  .signOut(); // ✅ Sign out from Firebase
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => launch_page()),
                    (route) => false, // ✅ Remove all previous routes
              );
            },
          )
        ],
      ),
    );
  }
}