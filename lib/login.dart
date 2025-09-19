import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/home.dart';
import 'package:revive_eco_tech_app/emailverification.dart';
import 'otp_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:revive_eco_tech_app/auth/google_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✨ NEW: Import Firestore
import 'package:revive_eco_tech_app/forgot_password_page.dart'; // ✨ ADD THIS IMPORT

class login extends StatefulWidget {
  final int initialTabIndex;
  const login({Key? key, this.initialTabIndex = 0}) : super(key: key);
  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isSignupConfirmPasswordVisible = false;

  final firebaseServices = FirebaseServices();

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _signupConfirmPasswordController =
  TextEditingController();

  void showErrorToUser(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ✨ NEW: Helper function to create user profile in Firestore
  Future<void> createUserProfile(User user) async {
    final userDocRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnap = await userDocRef.get();

    if (!docSnap.exists) {
      // Only create profile if it doesn't already exist
      await userDocRef.set({
        'name': user.displayName ??
            'User-${user.uid.substring(0, 6)}', // Use Google name or default
        'phone': user.phoneNumber ?? '', // Use Google phone or empty
        'createdAt': FieldValue.serverTimestamp(),
        'email': user.email, // Store email for reference
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: Color(0xFFFCF3E3),
        body: Column(
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/HOME_SCREEN_6[1].png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFCF3E3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: TabBar(
                tabs: [
                  Tab(text: 'Login'),
                  Tab(text: 'Signup'),
                ],
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Color(0xFF013D5A),
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontFamily: 'RedHatDisplay',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF013D5A),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Login Form
                  SingleChildScrollView(
                    child: Form(
                      key: _loginFormKey,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                              child: Text(
                                'Login in your account',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'RedHatDisplay',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF013D5A),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 5, 30, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFCF3E3),
                                    border: Border.all(
                                        color: Color(0xFF013D5A), width: 3),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _loginEmailController,
                                    decoration: InputDecoration(
                                      hintText: 'E-mail',
                                      hintStyle: TextStyle(
                                        fontFamily: 'RedHatDisplay',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF013D5A),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        size: 40,
                                        color: Color(0xFFA6CB4E),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      final emailRegex = RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFCF3E3),
                                border: Border.all(
                                    color: Color(0xFF013D5A), width: 3),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _loginPasswordController,
                                obscureText: !_isLoginPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    fontFamily: 'RedHatDisplay',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF013D5A),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    size: 40,
                                    color: Color(0xFFA6CB4E),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isLoginPasswordVisible =
                                        !_isLoginPasswordVisible;
                                      });
                                    },
                                    child: Icon(
                                      _isLoginPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 40,
                                      color: Color(0xFFA6CB4E),
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters long';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          // ==== REPLACE IT WITH THIS CODE ====
                          Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.fromLTRB(0, 10, 30, 10),
                            child: GestureDetector( // ✨ WRAPPED WITH GESTUREDETECTOR
                              onTap: () {
                                // ✨ ADDED NAVIGATION
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                                );
                              },
                              child: Text(
                                'Forgot Password?', // ✨ TEXT CHANGED
                                style: TextStyle(
                                  color: Color(0xFF013D5A),
                                  fontFamily: 'RedHatDisplay',
                                  fontWeight: FontWeight.bold, // Added bold to make it look more like a link
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: GestureDetector(
                              onTap: () async {
                                if (_loginFormKey.currentState!.validate()) {
                                  final userCredential =
                                  await firebaseServices.loginWithEmail(
                                    _loginEmailController.text.trim(),
                                    _loginPasswordController.text.trim(),
                                  );
                                  if (userCredential != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => HomePage()),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color(0xFFA6CB4E),
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
                                    'Login',
                                    style: TextStyle(
                                      fontFamily: 'RedHatDisplay',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFCF3E3),
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: GestureDetector(
                              onTap: () async {
                                final userCredential =
                                await firebaseServices.signInWithGoogle();
                                if (userCredential != null &&
                                    userCredential.user != null) {
                                  // ✨ NEW: Ensure profile exists on Google login
                                  await createUserProfile(userCredential.user!);

                                  if (!mounted)
                                    return; // ✨ NEW: mounted check
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => HomePage()),
                                  );
                                }
                              },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color(0xFFA6CB4E),
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
                                    'Continue with google ',
                                    style: TextStyle(
                                      fontFamily: 'RedHatDisplay',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFCF3E3),
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Signup Form
                  SingleChildScrollView(
                    child: Form(
                      key: _signupFormKey,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                              child: Text(
                                'Become the part of our future',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'RedHatDisplay',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF013D5A),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 5, 30, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFCF3E3),
                                    border: Border.all(
                                        color: Color(0xFF013D5A), width: 3),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _signupEmailController,
                                    decoration: InputDecoration(
                                      hintText: 'E-mail',
                                      hintStyle: TextStyle(
                                        fontFamily: 'RedHatDisplay',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF013D5A),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        size: 40,
                                        color: Color(0xFFA6CB4E),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      final emailRegex = RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFCF3E3),
                                    border: Border.all(
                                        color: Color(0xFF013D5A), width: 3),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _signupPasswordController,
                                    obscureText: !_isSignupPasswordVisible,
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        fontFamily: 'RedHatDisplay',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF013D5A),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        size: 40,
                                        color: Color(0xFFA6CB4E),
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isSignupPasswordVisible =
                                            !_isSignupPasswordVisible;
                                          });
                                        },
                                        child: Icon(
                                          _isSignupPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          size: 40,
                                          color: Color(0xFFA6CB4E),
                                        ),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 8) {
                                        return 'Password must be at least 8 characters long';
                                      }
                                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                        return 'Password must contain at least one uppercase letter';
                                      }
                                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                                        return 'Password must contain at least one lowercase letter';
                                      }
                                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                                        return 'Password must contain at least one number';
                                      }
                                      if (!RegExp(
                                          r'[!@#$%^&*(),.?":{}|<>]')
                                          .hasMatch(value)) {
                                        return 'Password must contain at least one special character';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFCF3E3),
                                    border: Border.all(
                                        color: Color(0xFF013D5A), width: 3),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller:
                                    _signupConfirmPasswordController,
                                    obscureText:
                                    !_isSignupConfirmPasswordVisible,
                                    decoration: InputDecoration(
                                      hintText: 'Confirm Password',
                                      hintStyle: TextStyle(
                                        fontFamily: 'RedHatDisplay',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF013D5A),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        size: 40,
                                        color: Color(0xFFA6CB4E),
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isSignupConfirmPasswordVisible =
                                            !_isSignupConfirmPasswordVisible;
                                          });
                                        },
                                        child: Icon(
                                          _isSignupConfirmPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          size: 40,
                                          color: Color(0xFFA6CB4E),
                                        ),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value !=
                                          _signupPasswordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: GestureDetector(
                              onTap: () async {
                                if (_signupFormKey.currentState!.validate()) {
                                  try {
                                    final error =
                                    await firebaseServices.signUpWithEmail(
                                      _signupEmailController.text.trim(),
                                      _signupPasswordController.text.trim(),
                                    );

                                    if (!mounted) return;

                                    if (error == null) {
                                      // ✨ NEW: Create profile on successful signup
                                      User? user =
                                          FirebaseAuth.instance.currentUser;
                                      if (user != null) {
                                        await createUserProfile(user);
                                      }

                                      // Success: navigate to email verification
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (ctx) =>
                                                EmailVerificationPage()),
                                      );
                                    } else {
                                      // Error: show error message
                                      showErrorToUser(context, error);
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    showErrorToUser(context, "Signup failed: $e");
                                  }
                                }
                              },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color(0xFFA6CB4E),
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
                                    'Join In Community',
                                    style: TextStyle(
                                      fontFamily: 'RedHatDisplay',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFCF3E3),
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: GestureDetector(
                              onTap: () async {
                                // ✨ NEW: Updated Google Sign-Up logic
                                final userCredential =
                                await firebaseServices.signInWithGoogle();
                                if (userCredential != null &&
                                    userCredential.user != null) {
                                  // ✨ NEW: Ensure profile exists on Google signup
                                  await createUserProfile(userCredential.user!);

                                  if (!mounted)
                                    return; // ✨ NEW: mounted check
                                  // ✨ NEW: Navigate to home on success
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => HomePage()),
                                  );
                                }
                              },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color(0xFFA6CB4E),
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
                                    'SignUp with google ',
                                    style: TextStyle(
                                      fontFamily: 'RedHatDisplay',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFCF3E3),
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}