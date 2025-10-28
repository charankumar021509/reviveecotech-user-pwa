import 'package:flutter/material.dart';
// Note: Your path might be different, e.g., 'package:revive_eco_tech_app/models/campaign_model.dart'
import 'package:revive_eco_tech_app/widgets/campaign_model.dart';
import 'package:intl/intl.dart';
import 'package:revive_eco_tech_app/gallery_viewer_page.dart'; // ✅ 1. ADD THIS IMPORT

// --- Constants (copied for this file) ---
const kPrimaryColor = Color(0xFF013856);
const kAccentColor = Color(0xFFa7cd47);
const kCreamColor = Color(0xFFfcf3e2);
const kCreamLight = Color(0xFFfefaef);
// ---

class CampaignDetailsPage extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailsPage({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamColor,
      body: CustomScrollView(
        slivers: [
          // --- 1. App Bar with Hero Image --- (Unchanged)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: kPrimaryColor,
            iconTheme: const IconThemeData(color: kCreamLight),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                campaign.title,
                style: const TextStyle(
                  color: kCreamLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Hero(
                tag: 'campaign_poster_${campaign.id}',
                child: Image.asset(
                  campaign.posterUrl,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3), // Darken image slightly
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
          ),

          // --- 2. Article Content --- (Unchanged)
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // --- Date & Location Info --- (Unchanged)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.calendar_today,
                        text: DateFormat('MMM d, yyyy').format(campaign.date),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Icons.location_on,
                        text: campaign.location,
                      ),
                    ],
                  ),
                ),

                // --- Details "Article" --- (Unchanged)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    campaign.details,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[850],
                      height: 1.6,
                    ),
                  ),
                ),

                // --- Gallery Title --- (Unchanged)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Text(
                    "Campaign Gallery",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ),

                // --- Gallery Grid --- (✅ 2. UPDATED THIS SECTION)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GridView.builder(
                    shrinkWrap: true, // Needed inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: campaign.imageUrls.length,
                    itemBuilder: (context, index) {
                      final imageUrl = campaign.imageUrls[index];
                      // We now wrap the image in a GestureDetector and Hero
                      return GestureDetector(
                        onTap: () {
                          // This is what opens the new gallery page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GalleryViewerPage(
                                imageUrls: campaign.imageUrls,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          // The tag MUST be unique. The image path is perfect.
                          tag: imageUrl,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported,
                                        color: Colors.grey[500]),
                                  ),
                            ),
                          ),
                        ),
                      );
                      // This looks great!
                    },
                  ),
                ),
                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for date/location chips (Unchanged)
  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kCreamLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

