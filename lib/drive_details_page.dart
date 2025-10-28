import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/widgets/drive_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ 1. ADD THIS IMPORT

// --- Constants (copied from home.dart) ---
const kPrimaryColor = Color(0xFF013856);
const kCreamColor = Color(0xFFfcf3e2);
const kCreamLight = Color(0xFFfefaef);

class DriveDetailsPage extends StatelessWidget {
  final Drive drive;

  const DriveDetailsPage({super.key, required this.drive});

  // ✅ 2. ADD THIS FUNCTION
  // This will launch the maps app
  Future<void> _launchMaps(String location, BuildContext context) async {
    // URL-encode the location string
    final query = Uri.encodeComponent(location);
    // Create a universal Google Maps URL
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Show a snackbar if it fails
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Could not open maps. App not found."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("An error occurred: $e"),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Hero Image with Back Button ---
            Stack(
              children: [
                Hero(
                  tag: 'drive_image_${drive.id}',
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(drive.imageUrl),
                        fit: BoxFit.cover,
                      ),
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: SafeArea(
                    child: CircleAvatar(
                      backgroundColor: kPrimaryColor.withOpacity(0.7),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: kCreamLight),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- 2. Title Section ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                drive.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),

            // --- 3. Info Cards (Date & Location) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: "Date & Time",
                    // e.g., "Saturday, Nov 8"
                    subtitle: DateFormat('EEEE, MMM d').format(drive.date),
                    // e.g., "10:00 AM - 2:00 PM"
                    trailing: "10:00 AM - 2:00 PM", // You can add this to your model
                  ),
                  const SizedBox(height: 12),
                  // ✅ 3. WRAP THE CARD IN AN INKWELL
                  InkWell(
                    onTap: () => _launchMaps(drive.location, context),
                    borderRadius: BorderRadius.circular(12),
                    child: _buildInfoCard(
                      icon: Icons.location_on,
                      title: "Location",
                      subtitle: drive.location,
                      trailing: "View Map", // Optional
                    ),
                  ),
                ],
              ),
            ),

            // --- 4. Details Section ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "About this drive",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    // Your e.g., "Open to all residents. Bring your e-waste!"
                    "${drive.details}\n\nThis drive is open to all residents. Please bring your segregated e-waste, plastics, and paper recyclables.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
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

  // Helper widget for info cards
  Widget _buildInfoCard(
      {required IconData icon,
        required String title,
        required String subtitle,
        String? trailing}) {
    return Card(
      elevation: 0,
      color: kCreamLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}

