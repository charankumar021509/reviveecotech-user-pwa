import 'package:flutter/material.dart';

class launch_page extends StatefulWidget {
  @override
  State<launch_page> createState() => _launch_pageState();
}

class _launch_pageState extends State<launch_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Text('launch page'),
      ),
    );
  }
}