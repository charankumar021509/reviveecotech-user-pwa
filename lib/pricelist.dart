import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/utilities/tiles.datrt.dart';

// ==== Constants (from your home.dart) ====
const kPrimaryColor = Color(0xFF013D5A);
const kCreamColor = Color(0xFFFCF3E3);

class pricelist extends StatefulWidget {
  const pricelist({super.key});

  @override
  State<pricelist> createState() => _pricelistState();
}

class _pricelistState extends State<pricelist> {
  // Stream to fetch the main categories
  final Stream<QuerySnapshot> _categoriesStream = FirebaseFirestore.instance
      .collection('price_list')
      .orderBy('order') // Sort by the 'order' field
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          // Using a standard, cleaner back icon
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kCreamColor,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Price List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'RedHatDisplay',
            letterSpacing: 1.0,
            color: kCreamColor,
          ),
        ),
        backgroundColor: kPrimaryColor,
      ),
      backgroundColor: kCreamColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: _categoriesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
                  "No prices found.",
                  style: TextStyle(fontSize: 18),
                ));
          }

          // Build the list of tiles from the categories
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            children: snapshot.data!.docs.map((DocumentSnapshot categoryDoc) {
              Map<String, dynamic> categoryData =
              categoryDoc.data()! as Map<String, dynamic>;

              // For each category, we fetch its items in a new StreamBuilder
              return StreamBuilder<QuerySnapshot>(
                stream: categoryDoc.reference
                    .collection('items')
                    .orderBy('order')
                    .snapshots(),
                builder: (context, itemSnapshot) {
                  if (itemSnapshot.hasError) {
                    return const Text('Could not load items');
                  }
                  if (itemSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      // Show a simple loader for the tile's content
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2,)),
                    );
                  }

                  // Once items are loaded, format them for the Tiles widget
                  List<Map<String, String>> dropdownItems = itemSnapshot
                      .data!.docs
                      .map((itemDoc) {
                    Map<String, dynamic> itemData =
                    itemDoc.data()! as Map<String, dynamic>;
                    return <String, String>{
                    // return {
                      'name': itemData['name'] ?? 'Unnamed',
                      'price':
                      'Rs. ${itemData['price'] ?? 0}/${itemData['unit'] ?? 'unit'}',
                    };
                  }).toList();

                  // Return the final Tile widget
                  return Tiles(
                    tilename: categoryData['name'] ?? 'Unnamed Category',
                    dropdownItems: dropdownItems,
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}