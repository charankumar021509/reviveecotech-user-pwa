import 'package:flutter/material.dart';

class LeaderBoard extends StatelessWidget {
  const LeaderBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCF3E3),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Leader Board',
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
            color: Color(0xFFFCF3E3),
          ),
        ),

        backgroundColor: Color(0xFF013D5A),
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.57, // 180 degrees in radians
            child: Icon(Icons.u_turn_left,
              color: Colors.white,),
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
            // Handle back button press
          },
        ),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Text("4",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    'Sampath Ghosh',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text("50PTS")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}