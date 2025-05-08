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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap:(){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>signup()
                      ),
                      );
                    },
                  child:Container(
                    height: 70,
                    padding: EdgeInsets.symmetric(vertical: 18,horizontal: 100),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFF013D5A),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                        ]
                    ),
                    child: Text("Get Started",
                    style: TextStyle(
                        fontFamily: 'RedHatDisplay',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.0,
                        color: Color(0xFFFCF3E3)
                    ),
                    ),
                  ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (context)=>login()
                        ),
                      );
                    },
                    child: Container(
                      height:70,
                      padding: EdgeInsets.symmetric(vertical: 18 ,horizontal: 124),
                      margin: EdgeInsets.only(bottom: 50),
                      decoration: BoxDecoration(
                        color: Color(0xFFFCF3E3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF013D5A),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: Offset(0, 6),
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: Text("Login",
                      style: TextStyle(
                        fontFamily: 'RedHatDisplay',
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Color(0xFF013D5A),
                      ),
                      ),
                    ),
                  )
                ],
              ),
            )
            ],
          ),
        ),
      ),
    );
  }
}