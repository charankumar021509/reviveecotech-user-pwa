import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final String details;
  final String posterUrl; // The one poster image for the list
  final List<String> imageUrls; // All other images for the gallery

  Campaign({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.details,
    required this.posterUrl,
    required this.imageUrls,
  });

  // Factory to create a Campaign from a Firestore document
  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    // Handle the list of images
    List<String> images = [];
    if (data['imageUrls'] != null) {
      // Cast from List<dynamic> to List<String>
      images = List<String>.from(data['imageUrls']);
    }

    return Campaign(
      id: doc.id,
      title: data['title'] ?? 'Untitled Campaign',
      location: data['location'] ?? 'Location TBD',
      date: (data['date'] as Timestamp? ?? Timestamp.now()).toDate(),
      details: data['details'] ?? 'More details to come.',
      posterUrl: data['posterUrl'] ?? 'assets/images/home/drives/recycle.png', // Default
      imageUrls: images,
    );
  }
}
