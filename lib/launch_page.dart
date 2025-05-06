import 'package:flutter/material.dart';
import 'signup.dart';
import 'login.dart';
//final launch page by satvik
class launch_page extends StatefulWidget {
  @override
  State<launch_page> createState() => _launch_pageState();
}

class _launch_pageState extends State<launch_page> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          child:Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/HOME SCREEN 1.png',
                  fit: BoxFit.cover,),
              ),
              Align(
                alignment: Alignment.bottomCenter,
              child: Padding(
                padding:EdgeInsets.only(bottom: 60),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                    ElevatedButton(
                    onPressed: ()
                    {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>signup()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF013D5A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      padding: EdgeInsets.symmetric(vertical:18.0,horizontal: 60),
                      elevation: 8,
                    ),
                    child: Text('Get Started',
                      style: TextStyle(
                          fontFamily: 'RedHatDisplay',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 18,
                          color: Color(0xFFFCF3E3)
                      ),
                    ),
                  ),
              Padding(
                  padding:EdgeInsets.only(top:30),
              child:ElevatedButton(
                    onPressed: ()
                    {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFCF3E3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      padding: EdgeInsets.symmetric(vertical:18.0,horizontal: 86),
                      elevation: 8,
                    ),
                    child: Text('Log In',
                      style: TextStyle(
                          fontFamily: 'RedHatDisplay',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Color(0xFF013D5A)
                      ),
                    ),
                  ),
              ),
                ]
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