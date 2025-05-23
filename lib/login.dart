import 'package:flutter/material.dart';
import 'otp_page.dart';

class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                    color: Colors.black.withOpacity(0.5), // Shadow color
                    spreadRadius: 3, // How far the shadow spreads
                    blurRadius: 5, // Blurry effect
                    offset: Offset(4, 4), // Position of shadow (x, y)
                  ),
                ],
              ),
              child: TabBar(
                tabs: [
                  Tab(text: 'Login',),
                  Tab(text: 'Signup'),
                ],

                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Color(0xFF013D5A),
                indicatorWeight: 3,
                labelStyle: TextStyle(fontSize: 20,
                  fontFamily: 'RedHatDisplay',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF013D5A),
                ),

              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                            child: Container(
                                child: Text('Login in your account',
                                  style: TextStyle(fontSize: 22,
                                      fontFamily: 'RedHatDisplay',
                                      fontWeight: FontWeight.bold
                                      ,color: Color(0xFF013D5A)),)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 5, 30, 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFCF3E3),
                              border: Border.all(color: Color(0xFF013D5A),
                                  width: 3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5), // Shadow color
                                  spreadRadius: 3, // How far the shadow spreads
                                  blurRadius: 5, // Blurry effect
                                  offset: Offset(4, 4), // Position of shadow (x, y)
                                ),
                              ],
                            ),
                            child: TextFormField(

                              decoration: InputDecoration(

                                hintText: 'E-mail',
                                hintStyle: TextStyle(
                                  fontFamily: 'RedHatDisplay',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF013D5A),
                                ),
                                prefixIcon:Icon(Icons.email,
                                  size: 40,
                                  color: Color(0xFFA6CB4E),),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFCF3E3),
                              border: Border.all(color: Color(0xFF013D5A),
                                  width: 3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5), // Shadow color
                                  spreadRadius: 3, // How far the shadow spreads
                                  blurRadius: 5, // Blurry effect
                                  offset: Offset(4, 4), // Position of shadow (x, y)
                                ),
                              ],
                            ),
                            child: TextFormField(

                              decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    fontFamily: 'RedHatDisplay',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF013D5A),
                                  ),
                                  prefixIcon:Icon(Icons.lock,
                                    size: 40,
                                    color: Color(0xFFA6CB4E),),
                                  suffixIcon: Icon(Icons.remove_red_eye,
                                    size: 40,
                                    color: Color(0xFFA6CB4E),
                                  )
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.fromLTRB(0, 10, 30, 10),
                          child: Text(
                            'Forget Pin?',
                            style: TextStyle(color: Color(0xFF013D5A),
                              fontFamily: 'RedHatDisplay',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => OtpPage()),
                              );
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
                                  'Login',
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
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                            child: Container(
                                child: Text('Become the part of our future',
                                  style: TextStyle(fontSize: 22,
                                      fontFamily: 'RedHatDisplay',
                                      fontWeight: FontWeight.bold
                                      ,color: Color(0xFF013D5A)),)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 5, 30, 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFCF3E3),
                              border: Border.all(color: Color(0xFF013D5A),
                                  width: 3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5), // Shadow color
                                  spreadRadius: 3, // How far the shadow spreads
                                  blurRadius: 5, // Blurry effect
                                  offset: Offset(4, 4), // Position of shadow (x, y)
                                ),
                              ],
                            ),
                            child: TextFormField(

                              decoration: InputDecoration(

                                hintText: 'E-mail',
                                hintStyle: TextStyle(
                                  fontFamily: 'RedHatDisplay',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF013D5A),
                                ),
                                prefixIcon:Icon(Icons.email,
                                  size: 40,
                                  color: Color(0xFFA6CB4E),),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFCF3E3),
                              border: Border.all(color: Color(0xFF013D5A),
                                  width: 3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5), // Shadow color
                                  spreadRadius: 3, // How far the shadow spreads
                                  blurRadius: 5, // Blurry effect
                                  offset: Offset(4, 4), // Position of shadow (x, y)
                                ),
                              ],
                            ),
                            child: TextFormField(

                              decoration: InputDecoration(
                                  hintText: 'Create password',
                                  hintStyle: TextStyle(
                                    fontFamily: 'RedHatDisplay',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF013D5A),
                                  ),
                                  prefixIcon:Icon(Icons.lock,
                                    size: 40,
                                    color: Color(0xFFA6CB4E),),
                                  suffixIcon: Icon(Icons.remove_red_eye,
                                    size: 40,
                                    color: Color(0xFFA6CB4E),
                                  )
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFCF3E3),
                              border: Border.all(color: Color(0xFF013D5A),
                                  width: 3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5), // Shadow color
                                  spreadRadius: 3, // How far the shadow spreads
                                  blurRadius: 5, // Blurry effect
                                  offset: Offset(4, 4), // Position of shadow (x, y)
                                ),
                              ],
                            ),
                            child: TextFormField(

                              decoration: InputDecoration(
                                  hintText: 'Repeat password',
                                  hintStyle: TextStyle(
                                    fontFamily: 'RedHatDisplay',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF013D5A),
                                  ),
                                  prefixIcon:Icon(Icons.lock,
                                    size: 40,
                                    color: Color(0xFFA6CB4E),),
                                  suffixIcon: Icon(Icons.remove_red_eye,
                                    size: 40,
                                    color: Color(0xFFA6CB4E),
                                  )
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color(0xFFA6CB4E),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5), // Shadow color
                                  spreadRadius: 3, // How far the shadow spreads
                                  blurRadius: 5, // Blurry effect
                                  offset: Offset(4, 4), // Position of shadow (x, y)
                                ),
                              ],
                            ),
                            child: Center(child: Text('Join In Communit',
                              style: TextStyle(
                                fontFamily: 'RedHatDisplay',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFCF3E3),
                                fontSize: 25,

                              ),)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}