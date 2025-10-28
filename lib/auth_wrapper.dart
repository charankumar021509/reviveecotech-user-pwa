import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:revive_eco_tech_app/home.dart';
import 'package:revive_eco_tech_app/launch_page.dart';
import 'package:revive_eco_tech_app/emailverification.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. While waiting for the connection
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFCF3E3),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF013D5A),
              ),
            ),
          );
        }

        // 2. If a user is logged in
        if (snapshot.hasData) {
          final user = snapshot.data!;

          // ✨ NEW LOGIC START ✨

          // Check if any of the user's authentication providers is 'phone'.
          // user.providerData is a list of all methods linked to the account (password, phone, google.com etc).
          final isPhoneUser = user.providerData.any(
                (userInfo) => userInfo.providerId == 'phone',
          );

          // If the user authenticated with their phone OR their email is verified,
          // they are fully authenticated and can proceed to the home page.
          if (isPhoneUser || user.emailVerified) {
            return const HomePage();
          } else {
            // This 'else' block is now only reached if the user is NOT a phone user
            // AND their email is NOT verified. This correctly targets only the
            // users who need to verify their email.
            return EmailVerificationPage();
          }

          // ✨ NEW LOGIC END ✨
        }

        // 3. If no user is logged in
        else {
          return launch_page();
        }
      },
    );
  }
}
