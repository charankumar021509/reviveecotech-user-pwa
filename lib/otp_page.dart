import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_autofill/sms_autofill.dart';

/// BRAND COLORS
const kPrimaryColor = Color(0xFF013856);
const kBeigeColor = Color(0xFFFDF4E2);
const kGreenColor = Color(0xFF77913b);
Color shadowColor = Colors.black;

class OtpPage extends StatefulWidget {
  final String verificationId;
  const OtpPage({super.key, required this.verificationId});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _listenForSms();
  }

  void _listenForSms() async {
    try {
      await SmsAutoFill().listenForCode();
    } catch (e) {
      // Handle error if listening fails
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : kGreenColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _verifyOtp(String smsCode) async {
    if (smsCode.length != 6) {
      _showSnackBar("Please enter a valid 6-digit code.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode.trim(),
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true &&
          userCredential.user != null) {
        final user = userCredential.user!;
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': 'User-${user.uid.substring(0, 6)}',
          'phone': user.phoneNumber ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Invalid OTP or an error occurred",
          isError: true);
    } catch (e) {
      _showSnackBar("An error occurred: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBeigeColor,
      body: Column(
        children: [
          Container(
            color: kPrimaryColor,
            padding: EdgeInsets.only(top: statusBarHeight, bottom: 32),
            width: double.infinity,
            child: Center(
              child: Image.asset(
                'assets/images/home/logo.png', // Make sure this path is correct
                width: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 44, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.phone_android, color: kGreenColor, size: 58),
                  const SizedBox(height: 16),
                  const Text(
                    "VERIFY YOUR PHONE NUMBER",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 52),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "We have sent a 6-digit confirmation code to your phone.",
                      style: TextStyle(
                          fontSize: 14,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PinFieldAutoFill(
                    controller: _codeController,
                    codeLength: 6,
                    autoFocus: true,
                    decoration: BoxLooseDecoration(
                      // ✨ FIX: Replaced deprecated 'PinListenForDoneSource' with 'FixedColorBuilder'.
                      // This is the correct way to set a static color in the current version of the package.
                      strokeColorBuilder: FixedColorBuilder(kPrimaryColor),
                      bgColorBuilder: FixedColorBuilder(kBeigeColor),
                      textStyle: const TextStyle(
                          fontSize: 20,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    onCodeChanged: (code) {
                      if (code != null && code.length == 6) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    },
                    onCodeSubmitted: (code) {
                      _verifyOtp(code);
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _verifyOtp(_codeController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreenColor,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 25),
                      elevation: 7,
                      shadowColor: Colors.black,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(kBeigeColor)),
                    )
                        : const Text(
                      "Verify & Continue",
                      style: TextStyle(fontSize: 15, color: kBeigeColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                      onPressed: () {
                        _showSnackBar(
                            "Resend code feature not implemented yet.");
                      },
                      child: const Text(
                        "Resend Code",
                        style: TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

