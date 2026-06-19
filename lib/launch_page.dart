import 'package:flutter/material.dart';
import 'login.dart'; // Ensure this matches your file structure

// --- Constants ---
const kPrimaryColor = Color(0xFF013D5A);
const kCreamColor = Color(0xFFFCF3E3);

// ✅ Renamed to LaunchPage (PascalCase standard)
// ⚠️ Note: Update your main.dart to call 'home: const LaunchPage()' if it breaks.
class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  // Mobile & Tablet (same as current app)
  if (width < 1024) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_screen_1.png',
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  _buildButton(
                    context: context,
                    label: "Get Started",
                    backgroundColor: kPrimaryColor,
                    textColor: kCreamColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Login(initialTabIndex: 1),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildButton(
                    context: context,
                    label: "Login",
                    backgroundColor: kCreamColor,
                    textColor: kPrimaryColor,
                    isOutlined: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Login(initialTabIndex: 0),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desktop / Website View
  return Scaffold(
    backgroundColor: kCreamColor,
    body: Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 1400,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 60,
          vertical: 40,
        ),
        child: Row(
          children: [

            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/home_screen_1.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(width: 60),

            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Welcome To Revive Eco Tech',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Smart recycling solutions for a greener future.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: 320,
                    child: _buildButton(
                      context: context,
                      label: "Get Started",
                      backgroundColor: kPrimaryColor,
                      textColor: kCreamColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Login(initialTabIndex: 1),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: 320,
                    child: _buildButton(
                      context: context,
                      label: "Login",
                      backgroundColor: kCreamColor,
                      textColor: kPrimaryColor,
                      isOutlined: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Login(initialTabIndex: 0),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  // ✅ CEVUS Helper: Reusable Button Widget
  Widget _buildButton({
    required BuildContext context,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity, // Makes button fill width
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor, // Controls the splash/ripple color
          elevation: 8, // Standard material shadow
          shadowColor: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutlined
                ? const BorderSide(color: kPrimaryColor, width: 2.0)
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.0,
            color: textColor,
          ),
        ),
      ),
    );
  }
}