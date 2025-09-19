import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:revive_eco_tech_app/home.dart';
// ✨ CORRECTED IMPORT
import 'package:revive_eco_tech_app/launch_page.dart';
import 'package:revive_eco_tech_app/emailverification.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // 1. While loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFCF3E3), // Your theme color
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF013D5A), // Your theme color
              ),
            ),
          );
        }

        // 2. If user is logged in
        if (snapshot.hasData) {
          final user = snapshot.data!;

          if (user.emailVerified) {
            // 2a. Verified: Go to Home
            return const HomePage();
          } else {
            // 2b. Not Verified: Go to Verification
            return EmailVerificationPage();
          }
        }

        // 3. If user is logged out
        else {
          // ✨ CORRECTED PAGE
          return launch_page();
        }
      },
    );
  }
}