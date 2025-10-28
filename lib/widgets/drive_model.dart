import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ 1. Define a list of your placeholder images
final _placeholderImages = [
  'assets/images/home/drives/plastic.png',
  'assets/images/home/drives/recycle.png',
  // You can add a third one if you have it
  'assets/images/home/15.png',
];

class Drive {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final String details;
  final String imageUrl;
  final bool isPlaceholder;

  Drive({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.details,
    required this.imageUrl,
    this.isPlaceholder = false,
  });

  // Factory to create a Drive from a Firestore document
  factory Drive.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Drive(
      id: doc.id,
      title: data['title'] ?? 'Untitled Drive',
      location: data['location'] ?? 'Location TBD',
      // Firestore 'date' field should be a Timestamp
      date: (data['date'] as Timestamp? ?? Timestamp.now()).toDate(),
      details: data['details'] ?? 'More details to come.',
      imageUrl: data['imageUrl'] ?? 'assets/images/home/drives/recycle.png', // Default image
      isPlaceholder: false,
    );
  }

  // Factory to create a "Coming Soon" placeholder drive
  factory Drive.placeholder({required int uniqueId}) {
    // ✅ 2. Use the uniqueId to pick an image from the list
    // The '%' (modulo) operator ensures we never go out of bounds
    final imagePath = _placeholderImages[uniqueId % _placeholderImages.length];

    return Drive(
      id: 'placeholder_$uniqueId',
      title: 'Drive Coming Soon!',
      location: 'Your Society Could Be Next!',
      date: DateTime.now(),
      details: 'Check back soon for more details on upcoming drives in your area.',
      imageUrl: imagePath, // ✅ 3. Use the selected image path
      isPlaceholder: true,
    );
  }
}
