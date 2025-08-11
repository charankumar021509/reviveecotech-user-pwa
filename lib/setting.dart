import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/launch_page.dart';
import 'package:revive_eco_tech_app/utilities/tiles.datrt.dart';
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Transform.rotate(
            angle: 1.57,
            child: Icon(Icons.u_turn_left,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        title: Text('Settings',
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
            color: Color(0xFFFCF3E3),
          ),
        ),
        backgroundColor: Color(0xFF013D5A),
      ),
      backgroundColor: Color(0xFFFCF3E3),
      body:Padding(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
        child: ListView(
          children: [
            Tiles(tilename: 'About Us',
              iconPath: Icons.info,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>launch_page()));
              },
            ),
            Tiles(tilename: 'Help & Support',
              iconPath: Icons.headset_mic,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>launch_page()));
              },
            ),
            Tiles(tilename: 'Privacy Policy',
              iconPath: Icons.lock,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>launch_page()));
              },
            ),
            Tiles(tilename: 'Terms & Conditions',
              iconPath: Icons.description,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>launch_page()));
              },
            ),
            Tiles(tilename: 'FAQs',
              iconPath: Icons.help_center,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>launch_page()));
              },
            ),
            Tiles(
              tilename: 'Log Out',
              iconPath: Icons.logout,
              onTap: () async {
                await FirebaseAuth.instance.signOut(); // ✅ Sign out from Firebase
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => launch_page()),
                      (route) => false, // ✅ Remove all previous routes
                );
              },
            )
          ],
        ),
      ),
    );
  }
}