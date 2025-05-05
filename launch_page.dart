import 'package:flutter/material.dart';
import 'signup.dart';
import 'login.dart';

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
              Container(
                padding: EdgeInsets.fromLTRB(0,400, 0, 50),
                child : Center(
                  child: ElevatedButton(
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
                      padding: EdgeInsets.symmetric(vertical:18.0,horizontal: 80),
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
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0,600, 0, 50),
                child : Center(
                  child: ElevatedButton(
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
                      padding: EdgeInsets.symmetric(vertical:18.0,horizontal: 104),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}