import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final int order;
  final String linkType; // New: Can be 'URL', 'PAGE', or 'NONE'
  final String linkValue; // New: The actual link or page route

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.order,
    required this.linkType,
    required this.linkValue,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? 'assets/images/home/15.png',
      order: data['order'] ?? 99,
      // Add defaults for the new fields
      linkType: data['linkType'] ?? 'NONE',
      linkValue: data['linkValue'] ?? '',
    );
  }
}

