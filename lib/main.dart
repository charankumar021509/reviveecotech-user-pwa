import 'package:flutter/material.dart';
// Import your new wrapper
import 'package:revive_eco_tech_app/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// You no longer need FirebaseAuth or HomePage here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // All the old logic is removed. We let AuthWrapper handle it.
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // Set the AuthWrapper as the home
      home: const AuthWrapper(),
    ),
  );
}