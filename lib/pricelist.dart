import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/utilities/tiles.datrt.dart';
class pricelist extends StatelessWidget {
  const pricelist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Transform.rotate(
                angle:1.57,
                child: Icon(Icons.u_turn_left,
                  color: Colors.white,),
              )
          ),
          centerTitle: true,
          title: Text('Price List',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'RedHatDisplay',
                letterSpacing: 1.0,
                color: Color(0xFFFCF3E3)
            ),
          ),
          backgroundColor: Color(0xFF013D5A),
        ),
        backgroundColor: Color(0xFFFCF3E3),
        body: Padding(
          padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
          child: ListView(
            children: [
              Tiles(tilename: 'Paper', dropdownItems:[
                {
                  'name': 'Newspaper',
                  'price': 'Rs.14/kg',
                },
                {
                  'name':'books/magazines',
                  'price': 'Rs.16/kg',
                },
                {
                  'name':'Gatta/Cardboard',
                  'price': 'Rs.10/kg',
                },
                {
                  'name':'A4',
                  'price': 'Rs.12/kg',
                },
              ]
              ),
              Tiles(tilename: 'Plastic', dropdownItems:[
                {
                  'name': 'Bottles',
                  'price': 'Rs.10/kg',
                },
                {
                  'name':'tupperware',
                  'price': 'Rs.12/kg',
                },

              ]
              ),
              Tiles(tilename: 'Glass', dropdownItems:[
                {
                  'name': 'Bottles',
                  'price': 'Rs.10/kg',
                },
              ]
              ),
              Tiles(tilename: 'Metals', dropdownItems:[
                {
                  'name': 'Aluminium',
                  'price': 'Rs.140/kg',
                },
                {
                  'name': 'Copper',
                  'price': 'Rs.570/kg',
                },
                {
                  'name': 'Iron',
                  'price': 'Rs.20/kg',
                },
                {
                  'name': 'Steel',
                  'price': 'Rs.45/kg',
                },
                {
                  'name': 'Brass',
                  'price': 'Rs.400/kg',
                },
              ]
              ),

              Tiles(tilename: 'E-waste', dropdownItems:[
                {
                  'name': 'Keypad Phone',
                  'price': 'Rs.200/piece',
                },
                {
                  'name': 'Smart Phone',
                  'price': 'Rs.400/piece',
                },
                {
                  'name': 'Tablet',
                  'price': 'Rs.300/piece',
                },
                {
                  'name': 'Lcd',
                  'price': 'Rs.200/piece',
                },
                {
                  'name': 'Laptop',
                  'price': 'Rs.400/piece',
                },
              ]
              ),
            ],
          ),
        )
    );
  }
}