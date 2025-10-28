import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// ─────────────────────────────────────────────────────────────
// Logs Firebase configuration at runtime
// ─────────────────────────────────────────────────────────────
Future<void> logFirebaseProjectInfo() async {
  final app = Firebase.app();
  final options = app.options;

  print('------------------ FIREBASE CONFIG CHECK ------------------');
  print('Project ID:       ${options.projectId}');
  print('App ID:           ${options.appId}');
  print('API Key:          ${options.apiKey}');
  print('Messaging Sender: ${options.messagingSenderId}');
  print('------------------------------------------------------------');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔍 Print which Firebase project this build is connected to
  await logFirebaseProjectInfo();

  // ✅ Initialize App Check (Play Integrity + DeviceCheck)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    ),
  );
}
