import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:revive_eco_tech_app/home.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isVerified = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // ✨ FIX IS HERE
    // We can't call _showSnackBar directly from initState.
    // Instead, we use addPostFrameCallback to run it *after* the build is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSnackBar("Please check your inbox to verify your email.",
          isError: false, isInfo: true);
    });

    // This call is fine because its own SnackBar calls happen *after* an 'await'
    checkVerification();
  }

  // Helper function for showing feedback
  void _showSnackBar(String message,
      {bool isError = false, bool isInfo = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.red : (isInfo ? Color(0xFF013D5A) : Color(0xFFA6CB4E)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> checkVerification() async {
    setState(() => isLoading = true);
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isVerified = user?.emailVerified ?? false;
      isLoading = false;
    });

    if (isVerified) {
      // Add check to ensure user profile exists before navigating
      if (user != null) {
        final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnap = await userDocRef.get();

        if (!docSnap.exists) {
          // Profile doesn't exist, so create it.
          await userDocRef.set({
            'name': 'User-${user.uid.substring(0, 6)}', // Default name
            'phone': '', // Default empty phone
            'createdAt': FieldValue.serverTimestamp(),
            'email': user.email,
          });
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // This call is fine because it happens after the 'await' in initState
      _showSnackBar("Email not verified yet. Please check your inbox.",
          isError: true);
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      _showSnackBar("Verification email resent!");
    } catch (e) {
      _showSnackBar("Failed to resend email: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCF3E3),
      appBar: AppBar(
        title: Text(
          'Verify Your Email',
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            color: Color(0xFFFCF3E3),
          ),
        ),
        backgroundColor: Color(0xFF013D5A),
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(
          color: Color(0xFF013D5A),
        )
            : Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 100,
                color: Color(0xFF013D5A),
              ),
              SizedBox(height: 30),
              Text(
                "A verification link has been sent to your email.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'RedHatDisplay',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF013D5A),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Please click the link in your email to continue. You may need to check your spam folder.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'RedHatDisplay',
                  fontSize: 16,
                  color: Color(0xFF013D5A).withOpacity(0.8),
                ),
              ),
              SizedBox(height: 40),
              GestureDetector(
                onTap: checkVerification,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xFFA6CB4E), // Your app's button color
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "I've Verified, Continue",
                      style: TextStyle(
                        fontFamily: 'RedHatDisplay',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFCF3E3), // Your button text color
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: resendVerificationEmail,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xFFFCF3E3), // Light background
                    border: Border.all(
                        color: Color(0xFF013D5A),
                        width: 3), // Dark border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Resend Email",
                      style: TextStyle(
                        fontFamily: 'RedHatDisplay',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF013D5A), // Dark text
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}