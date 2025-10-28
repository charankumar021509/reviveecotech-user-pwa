import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ 1. ADD FIRESTORE
import 'package:revive_eco_tech_app/widgets/campaign_model.dart'; // ✅ 2. ADD CAMPAIGN MODEL
import 'package:revive_eco_tech_app/campaign_details_page.dart'; // ✅ 3. ADD DETAILS PAGE

// --- Constants ---
const kPrimaryColor = Color(0xFF013856);
const kAccentColor = Color(0xFFa7cd47);
const kCreamColor = Color(0xFFfcf3e2);
const kCreamLight = Color(0xFFfefaef);
// ---

// ✅ 4. CONVERT TO STATEFULWIDGET
class SocietyCampaignPage extends StatefulWidget {
  const SocietyCampaignPage({super.key});

  @override
  State<SocietyCampaignPage> createState() => _SocietyCampaignPageState();
}

class _SocietyCampaignPageState extends State<SocietyCampaignPage> {
  // ✅ 5. ADD STATE VARIABLES FOR FETCHING
  late Future<List<Campaign>> _pastCampaignsFuture;

  @override
  void initState() {
    super.initState();
    // ✅ 6. CALL THE FETCH FUNCTION
    _pastCampaignsFuture = _fetchPastCampaigns();
  }

  // ✅ 7. ADD FETCH FUNCTION
  Future<List<Campaign>> _fetchPastCampaigns() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('campaigns') // New collection
          .orderBy('date', descending: true) // Newest first
          .get();

      return snapshot.docs
          .map((doc) => Campaign.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching campaigns: $e");
      // Handle error, maybe return an empty list
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamColor,
      appBar: AppBar(
        title: const Text(
          "Society Campaigns",
          style: TextStyle(
            color: kCreamColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kCreamColor), // Back arrow
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Hero Image --- (Unchanged)
            Container(
              height: 200,
              color: kPrimaryColor,
              child: Image.asset(
                'assets/images/home/drives/campaign_hero.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.campaign, color: kCreamColor, size: 80)),
              ),
            ),

            // --- 2. "What is it?" Section --- (Unchanged)
            _buildSection(
              title: "Start a Movement in Your Society",
              child: Text(
                "Partner with us to bring easy and rewarding recycling to your entire housing society! \n\n"
                    "We are a recycling service that collects recyclable materials from households, sorts them, and sends them to manufacturers who can reuse them. Our mission is to create a sustainable future by reducing waste and promoting responsible consumption.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),

            // --- 3. "How it Works" Section --- (Unchanged)
            _buildSection(
              title: "How It Works",
              child: Column(
                children: [
                  _buildStepItem(
                    icon: Icons.group_add,
                    title: "1. Nominate Your Society",
                    subtitle:
                    "Fill out the form below to nominate your society. Our team will get in touch to plan the next steps.",
                  ),
                  _buildStepItem(
                    icon: Icons.calendar_today,
                    title: "2. We Coordinate",
                    subtitle:
                    "We'll work with your society manager to schedule collection days, and provide posters and materials.",
                  ),
                  _buildStepItem(
                    icon: Icons.celebration,
                    title: "3. Launch Your Drive",
                    subtitle:
                    "On the scheduled day, we'll arrive to collect all the recyclables and ensure your society gets rewarded!",
                  ),
                ],
              ),
            ),

            // --- 4. "Past Campaigns" Gallery --- (✅ 8. REBUILT)
            _buildSection(
              title: "Our Past Campaigns",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "See the impact we've made with other societies!",
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 16),
                  // Use a FutureBuilder to show the list from Firestore
                  FutureBuilder<List<Campaign>>(
                    future: _pastCampaignsFuture,
                    builder: (context, snapshot) {
                      // --- Loading State ---
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      // --- Error State ---
                      if (snapshot.hasError) {
                        return const SizedBox(
                          height: 180,
                          child: Center(
                              child: Text("Could not load campaigns.")),
                        );
                      }
                      // --- Empty State ---
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox(
                          height: 180,
                          child: Center(
                              child: Text("No past campaigns found yet.")),
                        );
                      }
                      // --- Success State ---
                      final campaigns = snapshot.data!;
                      return SizedBox(
                        height: 180, // Height of the card
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: campaigns.length,
                          itemBuilder: (context, index) {
                            // Build one card for each campaign
                            return _buildCampaignCard(campaigns[index]);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // --- 5. "Become a Partner" --- (Unchanged)
            _buildSection(
              title: "Are You a Business?",
              child: _buildInfoCard(
                icon: Icons.business,
                text:
                "We are always looking for partners who share our vision of sustainability. If you are a manufacturer or a business interested in collaborating with us, please reach out. We would love to discuss potential partnerships!",
              ),
            ),

            // --- 6. "About Us" --- (Unchanged)
            _buildSection(
              title: "Who Are We?",
              child: _buildInfoCard(
                icon: Icons.eco,
                text:
                "We are a team of passionate individuals dedicated to making recycling easy and accessible for everyone. Our mission is to create a sustainable future by reducing waste and promoting responsible consumption.",
              ),
            ),

            // --- 7. Call to Action Button --- (Unchanged)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.how_to_reg, color: kPrimaryColor),
                label: const Text(
                  "Nominate Your Society",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: kPrimaryColor,
                      content: Text(
                        "Thank you for your interest! This feature is coming soon.",
                        style: TextStyle(color: kCreamLight),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for section titles (Unchanged)
  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Helper widget for "How it Works" steps (Unchanged)
  Widget _buildStepItem(
      {required IconData icon,
        required String title,
        required String subtitle}) {
    return Card(
      elevation: 0,
      color: kCreamLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: kAccentColor, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 9. REPLACED _buildGalleryImage with _buildCampaignCard
  // This is the new card for the horizontal list
  Widget _buildCampaignCard(Campaign campaign) {
    return Container(
      width: 160, // Wider card to show title
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignDetailsPage(campaign: campaign),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hero Image
              Hero(
                tag: 'campaign_poster_${campaign.id}',
                child: Image.asset(
                  campaign.posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey[500], size: 50),
                  ),
                ),
              ),
              // Gradient overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
              // Title text
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  campaign.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for the info cards (Unchanged)
  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Card(
      elevation: 0,
      color: kCreamLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: kPrimaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

