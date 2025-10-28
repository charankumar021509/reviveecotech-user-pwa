import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/home.dart';
import 'package:revive_eco_tech_app/emailverification.dart';
import 'package:revive_eco_tech_app/otp_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:revive_eco_tech_app/auth/google_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:revive_eco_tech_app/forgot_password_page.dart';

class login extends StatefulWidget {
  final int initialTabIndex;
  const login({Key? key, this.initialTabIndex = 0}) : super(key: key);
  @override
  State<login> createState() => _loginState();
}

// FIX 1: Add 'with SingleTickerProviderStateMixin' to allow the state to be a vsync provider for the TabController.
class _loginState extends State<login> with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isSignupConfirmPasswordVisible = false;

  final firebaseServices = FirebaseServices();

  bool _isPhoneAuth = false;
  bool _isLoading = false;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _signupConfirmPasswordController =
  TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // FIX 2: Declare a TabController to manage the tabs explicitly.
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // FIX 3: Initialize the TabController here.
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    // FIX 4: Always dispose of your controllers to free up resources.
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void showErrorToUser(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> createUserProfile(User user) async {
    final userDocRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnap = await userDocRef.get();

    if (!docSnap.exists) {
      await userDocRef.set({
        'name': user.displayName ?? 'User-${user.uid.substring(0, 6)}',
        'phone': user.phoneNumber ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'email': user.email,
      });
    }
  }

  // FIX 5: The function no longer needs a 'context' parameter to find the tab index.
  Future<void> _sendOtp() async {
    // FIX 6: Use the explicit '_tabController' to get the current index. This resolves the error.
    final formKey =
    _tabController.index == 0 ? _loginFormKey : _signupFormKey;

    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    final phoneNumber = "+91" + _phoneController.text.trim();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          showErrorToUser(context, "Verification completed automatically.");
        },
        verificationFailed: (FirebaseAuthException e) {
          showErrorToUser(context, "Failed to send OTP: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpPage(verificationId: verificationId),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      showErrorToUser(context, "An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Divider(color: Color(0xFF013D5A).withOpacity(0.5))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text("OR",
                style: TextStyle(
                    color: Color(0xFF013D5A).withOpacity(0.8),
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Divider(color: Color(0xFF013D5A).withOpacity(0.5))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIX 7: Remove the 'DefaultTabController' widget. It's no longer needed as we are managing the controller ourselves.
    return Scaffold(
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
            // FIX 8: Assign our controller to the TabBar.
            child: TabBar(
              controller: _tabController,
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
            // FIX 9: Assign our controller to the TabBarView.
            child: TabBarView(
              controller: _tabController,
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
                        if (_isPhoneAuth)
                          _buildPhoneInput()
                        else ...[
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
                                      if (_isPhoneAuth) return null;
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
                                  if (_isPhoneAuth) return null;
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
                        ],
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (!_isPhoneAuth)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotPasswordPage()),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFF013D5A),
                                      fontFamily: 'RedHatDisplay',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Container(),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _isPhoneAuth = !_isPhoneAuth),
                                child: Text(
                                  _isPhoneAuth ? 'Use Email' : 'Use Phone',
                                  style: TextStyle(
                                    color: Color(0xFF013D5A),
                                    fontFamily: 'RedHatDisplay',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildActionButton(isLogin: true),
                        _buildDivider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: GestureDetector(
                            onTap: () async {
                              final userCredential =
                              await firebaseServices.signInWithGoogle();
                              if (userCredential != null &&
                                  userCredential.user != null) {
                                await createUserProfile(userCredential.user!);

                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => HomePage()),
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
                                  'Continue with Google',
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
                        if (_isPhoneAuth)
                          _buildPhoneInput()
                        else ...[
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
                                      if (_isPhoneAuth) return null;
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
                                      if (_isPhoneAuth) return null;
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
                                      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
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
                                      if (_isPhoneAuth) return null;
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
                        ],
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.fromLTRB(0, 0, 30, 10),
                          child: TextButton(
                            onPressed: () =>
                                setState(() => _isPhoneAuth = !_isPhoneAuth),
                            child: Text(
                              _isPhoneAuth
                                  ? 'Use Email instead'
                                  : 'Use Phone instead',
                              style: TextStyle(
                                color: Color(0xFF013D5A),
                                fontFamily: 'RedHatDisplay',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        _buildActionButton(isLogin: false),
                        _buildDivider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: GestureDetector(
                            onTap: () async {
                              final userCredential =
                              await firebaseServices.signInWithGoogle();
                              if (userCredential != null &&
                                  userCredential.user != null) {
                                await createUserProfile(userCredential.user!);

                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => HomePage()),
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
                                  'SignUp with Google',
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
    );
  }

  Widget _buildPhoneInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 5, 30, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFCF3E3),
          border: Border.all(color: Color(0xFF013D5A), width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(4, 4))
          ],
        ),
        child: TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '10-digit mobile number',
            hintStyle: TextStyle(
                fontFamily: 'RedHatDisplay',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF013D5A)),
            prefixIcon: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 15.0, vertical: 13.0),
              child: Text('+91',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF013D5A))),
            ),
            border: InputBorder.none,
          ),
          validator: (value) {
            if (_isPhoneAuth) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length != 10) {
                return 'Please enter a valid 10-digit number';
              }
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({required bool isLogin}) {
    String buttonText;
    VoidCallback onPressed;

    if (_isPhoneAuth) {
      buttonText = 'Send OTP';
      // FIX 10: The call to _sendOtp is now simpler as it doesn't need the context.
      onPressed = _sendOtp;
    } else {
      buttonText = isLogin ? 'Login' : 'Join In Community';
      onPressed = isLogin
          ? () async {
        if (_loginFormKey.currentState!.validate()) {
          setState(() => _isLoading = true);
          try {
            final userCredential =
            await firebaseServices.loginWithEmail(
              _loginEmailController.text.trim(),
              _loginPasswordController.text.trim(),
            );
            if (userCredential != null && mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
              );
            }
          } catch (e) {
            showErrorToUser(context, e.toString());
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        }
      }
          : () async {
        if (_signupFormKey.currentState!.validate()) {
          setState(() => _isLoading = true);
          try {
            final error = await firebaseServices.signUpWithEmail(
              _signupEmailController.text.trim(),
              _signupPasswordController.text.trim(),
            );
            if (!mounted) return;
            if (error == null) {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await createUserProfile(user);
              }
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (ctx) => EmailVerificationPage()),
              );
            } else {
              showErrorToUser(context, error);
            }
          } catch (e) {
            if (!mounted) return;
            showErrorToUser(context, "Signup failed: $e");
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        }
      };
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
      child: GestureDetector(
        onTap: _isLoading ? null : onPressed,
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
                  offset: Offset(4, 4))
            ],
          ),
          child: Center(
            child: _isLoading
                ? CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Color(0xFFFCF3E3)))
                : Text(buttonText,
                style: TextStyle(
                    fontFamily: 'RedHatDisplay',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFCF3E3),
                    fontSize: 25)),
          ),
        ),
      ),
    );
  }
}
