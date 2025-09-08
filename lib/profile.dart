import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/leader_Board.dart';
import 'package:revive_eco_tech_app/refer_page.dart';
import 'package:revive_eco_tech_app/review_and_rate_page.dart';
import 'history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class profile extends StatefulWidget {
  @override
  State<profile> createState() => _profileState();
}

final _editProfileFormKey = GlobalKey<FormState>();
final _nameController = TextEditingController();
final _emailController = TextEditingController();
final _addressController = TextEditingController();
final _phoneController = TextEditingController();

class _profileState extends State<profile> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFFCF3E3),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
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
            angle: 1.57,
            child: Icon(Icons.u_turn_left, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          user != null
              ? StreamBuilder<DocumentSnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong.'));
                  }

                  // Even if doc doesn't exist, we give empty values
                  final data =
                      snapshot.data?.data() as Map<String, dynamic>? ?? {};

                  _nameController.text = data['name'] ?? '';
                  _emailController.text = data['email'] ?? user.email ?? '';
                  _phoneController.text = data['phone'] ?? '';
                  _addressController.text = data['address'] ?? '';

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          10,
                                          20,
                                          0,
                                          0,
                                        ),
                                        child: CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Color(0xFFa8ce4c),
                                          child: Icon(
                                            Icons.account_circle,
                                            color: Color(0xFFffffff),
                                            size: 80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        // Ensure the text column doesn't overflow
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            10,
                                            20,
                                            0,
                                            0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _nameController.text.isNotEmpty
                                                    ? _nameController.text
                                                    : 'Name not available',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Text(
                                                _phoneController.text.isNotEmpty
                                                    ? '+91 ${_phoneController.text}'
                                                    : 'Phone not available',
                                              ),
                                              Text(
                                                _emailController.text.isNotEmpty
                                                    ? _emailController.text
                                                    : 'Email not available',
                                              ),
                                              Text(
                                                _addressController
                                                        .text
                                                        .isNotEmpty
                                                    ? _addressController.text
                                                    : 'Address not available',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          0,
                                          10,
                                          0,
                                          20,
                                        ),
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          10,
                                          10,
                                          10,
                                          20,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(20),
                                                    ),
                                              ),
                                              builder: (context) {
                                                return Container(
                                                  color: Color(0xFFFCF3E3),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 20,
                                                      right: 20,
                                                      top: 20,
                                                      bottom:
                                                          MediaQuery.of(
                                                            context,
                                                          ).viewInsets.bottom,
                                                    ),
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'Edit Profile',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color: Color(
                                                                0xFF013D5A,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 20),
                                                          Form(
                                                            key:
                                                                _editProfileFormKey,
                                                            child: Column(
                                                              children: [
                                                                TextFormField(
                                                                  controller:
                                                                      _nameController,
                                                                  decoration: InputDecoration(
                                                                    labelText:
                                                                        'Name',
                                                                    filled:
                                                                        true,
                                                                    fillColor:
                                                                        Colors
                                                                            .white,
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                  validator: (
                                                                    value,
                                                                  ) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Please enter your name';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                TextFormField(
                                                                  controller:
                                                                      _phoneController,
                                                                  decoration: InputDecoration(
                                                                    labelText:
                                                                        'Phone',
                                                                    filled:
                                                                        true,
                                                                    fillColor:
                                                                        Colors
                                                                            .white,
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                  validator: (
                                                                    value,
                                                                  ) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Please enter your phone number';
                                                                    }
                                                                    if (!RegExp(
                                                                      r'^\d{10}$',
                                                                    ).hasMatch(
                                                                      value,
                                                                    )) {
                                                                      return 'Please enter a valid phone number';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                TextFormField(
                                                                  controller:
                                                                      _addressController,
                                                                  decoration: InputDecoration(
                                                                    labelText:
                                                                        'Address',
                                                                    filled:
                                                                        true,
                                                                    fillColor:
                                                                        Colors
                                                                            .white,
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                  validator: (
                                                                    value,
                                                                  ) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Please enter your address';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () async {
                                                                    if (_editProfileFormKey
                                                                        .currentState!
                                                                        .validate()) {
                                                                      final user =
                                                                          FirebaseAuth
                                                                              .instance
                                                                              .currentUser;
                                                                      if (user !=
                                                                          null) {
                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection(
                                                                              'users',
                                                                            )
                                                                            .doc(
                                                                              user.uid,
                                                                            )
                                                                            .set(
                                                                              {
                                                                                'name':
                                                                                    _nameController.text.trim(),
                                                                                'phone':
                                                                                    _phoneController.text.trim(),
                                                                                'address':
                                                                                    _addressController.text.trim(),
                                                                              },
                                                                              SetOptions(
                                                                                merge:
                                                                                    true,
                                                                              ),
                                                                            );

                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                        ScaffoldMessenger.of(
                                                                          context,
                                                                        ).showSnackBar(
                                                                          SnackBar(
                                                                            content: Text(
                                                                              'Profile updated successfully!',
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                    }
                                                                  },
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                          10,
                                                                          10,
                                                                          10,
                                                                          40,
                                                                        ),
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                        color:
                                                                            Colors.lightGreenAccent,
                                                                      ),
                                                                      child: Padding(
                                                                        padding:
                                                                            const EdgeInsets.fromLTRB(
                                                                              0,
                                                                              10,
                                                                              0,
                                                                              20,
                                                                            ),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              'Save Changes',
                                                                              style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                                fontSize:
                                                                                    16,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
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
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.lightGreenAccent,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center, // Center content
                                              children: [
                                                Icon(Icons.edit, size: 30),
                                                SizedBox(
                                                  width: 5,
                                                ), // Add spacing between icon and text
                                                Text(
                                                  'Edit Profile',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      10,
                                      0,
                                      10,
                                    ),
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Icon(
                                              Icons.recycling,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Text(
                                            '0 kg',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            'Total Recycled',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    10,
                                    0,
                                    10,
                                  ),
                                  child: Container(
                                    width: 2,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      10,
                                      0,
                                      10,
                                    ),
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Icon(
                                              Icons.attach_money,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          Text(
                                            'Rs. 0',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            'Total Earnings',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoryScreen(),
                              ),
                            );
                          },
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
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      0,
                                      0,
                                    ),
                                    child: Icon(Icons.history, size: 35),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10,
                                      0,
                                      0,
                                      0,
                                    ),
                                    child: Text(
                                      'History',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      0,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReferFriendPage(),
                              ),
                            );
                          },
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
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      0,
                                      0,
                                    ),
                                    child: Container(
                                      child: Icon(
                                        Icons.person_add_rounded,
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10,
                                      0,
                                      0,
                                      0,
                                    ),
                                    child: Container(
                                      child: Text(
                                        'Refer a friend',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      0,
                                    ),
                                    child: Container(
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewAndRatePage(),
                              ),
                            );
                          },
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
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      0,
                                      0,
                                    ),
                                    child: Container(
                                      child: Icon(Icons.star_rate, size: 35),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10,
                                      0,
                                      0,
                                      0,
                                    ),
                                    child: Container(
                                      child: Text(
                                        'Review & Rate',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      0,
                                    ),
                                    child: Container(
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaderBoard(),
                              ),
                            );
                          },
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
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      0,
                                      0,
                                    ),
                                    child: Container(
                                      child: Icon(Icons.wallet, size: 35),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10,
                                      0,
                                      0,
                                      0,
                                    ),
                                    child: Container(
                                      child: Text(
                                        'Wallet',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      0,
                                    ),
                                    child: Container(
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
              : Center(child: Text('User not logged in.')),
    );
  }
}
