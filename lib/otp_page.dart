import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revive_eco_tech_app/home.dart';

/// BRAND COLORS
const kPrimaryColor = Color(0xFF013856);
const kBeigeColor   = Color(0xFFFDF4E2);
const kGreenColor   = Color(0xFF77913b);
Color shadowColor = Colors.black;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // globally set status bar to navy + light icons
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kPrimaryColor,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revive App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'RedHatDisplay',
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
      ),
      home: const OtpPage(),
    );
  }
}

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _codeController = TextEditingController();
  int secondsLeft = 15;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && secondsLeft > 0) {
        setState(() => secondsLeft -= 1);
        _tick();
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      // cream background for the body
      backgroundColor: kBeigeColor,
      body: Column(
        children: [
          // ─── NAVY HEADER + STATUS BAR ─────────────────
          Container(
            color: kPrimaryColor,
            // cover the status bar + a bit more for padding
            padding: EdgeInsets.only(top: statusBarHeight, bottom: 32),
            width: double.infinity,
            child: Center(
              child: Image.asset(
                'assets/images/home/logo.png',
                width: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ─── CREAM CONTENT ─────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 24),
              //padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //const SizedBox(height: 10),
                  Icon(Icons.email, color: kGreenColor, size: 58),
                  const SizedBox(height: 16),
                  const Text(
                    "VERIFY YOUR E-MAIL ADDRESS",
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
                      "We have sent a confirmation code to your\nabc@gmail.com",
                      style: TextStyle(fontSize: 14, color: kPrimaryColor,fontWeight: FontWeight.bold,),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // code input
                  Container(
                    width: double.infinity,
                    height: 53,
                    decoration: BoxDecoration(
                      color: kBeigeColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor.withAlpha((0.4 * 255).toInt()),
                          blurRadius: 6,
                          spreadRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: kPrimaryColor, width: 3),
                    ),
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Enter Code",
                        hintStyle: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "00:${secondsLeft.toString().padLeft(2, '0')}",
                      style: TextStyle(color: kPrimaryColor,fontWeight: FontWeight.bold,),
                    ),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreenColor,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 25),
                      elevation: 7,
                      shadowColor: Colors.black,
                    ),
                    child: const Text("Let's Revive",style: TextStyle(fontSize: 15 ,color: kBeigeColor),),
                  ),

                  const SizedBox(height: 16),
                  TextButton(onPressed: () {}, child: const Text("Resend Code",style: TextStyle(color: kPrimaryColor,fontWeight: FontWeight.bold,),)),
                  TextButton(onPressed: () {}, child: const Text("Need Help?",style: TextStyle(color: kPrimaryColor,fontWeight: FontWeight.bold,),)),
                  TextButton(onPressed: () {}, child: const Text("Change email address",style: TextStyle(color: kPrimaryColor,fontWeight: FontWeight.bold,),)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
