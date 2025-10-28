import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revive_eco_tech_app/history.dart';
import 'package:revive_eco_tech_app/pricelist.dart';
import 'package:revive_eco_tech_app/setting.dart';
import 'package:revive_eco_tech_app/profile.dart';
import 'Schedule_Pickup.dart';
import 'widgets/pickup_tracker.dart';
import 'package:revive_eco_tech_app/all_trackers_page.dart';
import 'package:revive_eco_tech_app/society_campaign_page.dart';

// IMPORTS FOR NEW DRIVE FEATURE
import 'dart:math'; // For placeholder logic
import 'package:revive_eco_tech_app/widgets/drive_model.dart'; // Using your path
import 'package:revive_eco_tech_app/widgets/drive_card.dart';
import 'package:revive_eco_tech_app/all_drives_page.dart';
import 'package:revive_eco_tech_app/drive_details_page.dart';

// IMPORT THE BANNER MODEL
import 'package:revive_eco_tech_app/widgets/banner_model.dart'; // Adjust path if needed

// IMPORT URL_LAUNCHER
import 'package:url_launcher/url_launcher.dart';


// ==== Constants ====
const kPrimaryColor = Color(0xFF013856);
const kAccentColor = Color(0xFFa7cd47);
const kCreamColor = Color(0xFFfcf3e2);
const kCreamLight = Color(0xFFfefaef);
const kGreenLight = Color(0xFFd3e7b4);

// ==== Main ====
void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: kPrimaryColor,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

// ==== MyApp ====
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revive App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'RedHatDisplay',
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

Color shadowColor = Colors.white; // You can change it to any color

// ==== HomePage ====
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String userName = "User";

  // State variables for live data
  bool _isLoadingStats = true;
  bool _isLoadingTracker = true;
  bool _isLoadingScraps = true;
  double _totalWeight = 0;
  double _totalEarnings = 0;
  DocumentSnapshot? _latestPendingPickup;
  List<MapEntry<String, int>> _topScrapsList = [];
  Map<String, double> _scrapWeights = {};

  // STATE FOR UPCOMING DRIVES
  bool _isLoadingDrives = true;
  List<Drive> _homePageDrives = [];

  // STATE FOR BANNERS
  bool _isLoadingBanners = true;
  List<BannerModel> _banners = [];

  // STATE FOR NAVIGATION
  int _currentIndex = 0;

  // ... (upcomingCard, scrapCard, buildCroppedAssetCard... no changes) ...
  Widget upcomingCard(String label, String assetPath) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(assetPath,
              height: 200, width: 200, fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: shadowColor.withAlpha((0.8 * 255).toInt()),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget scrapCard(String name, String times, String kg, String iconAssetPath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(iconAssetPath,
                  width: 60, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Text(name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold))),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text("$times",
                        style: const TextStyle(
                            color: kAccentColor,
                            fontSize: 23,
                            fontWeight: FontWeight.bold)),
                    Text("Times",
                        style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$kg",
                        style: const TextStyle(
                            color: kAccentColor,
                            fontSize: 23,
                            fontWeight: FontWeight.bold)),
                    Text("in kg",
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildCroppedAssetCard(String path, double topTrim, double bottomTrim) {
    return ClipRect(
      clipper: UnevenCropClipper(topTrim: topTrim, bottomTrim: bottomTrim),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchAllData();
  }

  void _onPickupScheduled() {
    _refreshTrackerData();
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshTrackerData();
    }
  }

  void _fetchAllData() {
    fetchUserName();
    _fetchStatsAndScraps();
    _fetchLatestPickup();
    _fetchUpcomingDrives();
    _fetchBanners();
  }

  void _refreshTrackerData() {
    if (mounted) {
      setState(() => _isLoadingTracker = true);
      _fetchLatestPickup();
    }
  }

  // ... (fetchUserName, _fetchStatsAndScraps, _fetchLatestPickup... no changes) ...
  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        if (mounted)
          setState(() {
            userName = user.displayName!;
          });
      } else {
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data()!.containsKey("name")) {
          if (mounted)
            setState(() {
              userName = doc["name"];
            });
        } else {
          // fallback to default
          if (mounted)
            setState(() {
              userName = "User-${user.uid.substring(0, 6)}";
            });
        }
      }
    }
  }

  Future<void> _fetchStatsAndScraps() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted)
        setState(() {
          _isLoadingStats = false;
          _isLoadingScraps = false;
        });
      return;
    }

    double tempTotalWeight = 0;
    double tempTotalEarnings = 0;
    Map<String, int> tempScrapTimes = {};
    Map<String, double> tempScrapWeights = {};

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('pickups')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Completed')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final weight = (data['finalWeight'] ?? 0).toDouble();
        final amount = (data['amount'] ?? 0).toDouble();

        tempTotalWeight += weight;
        tempTotalEarnings += amount;

        List<String> scraps = List<String>.from(data['scrapTypes'] ?? []);
        double weightPerType = weight / (scraps.isEmpty ? 1 : scraps.length);

        for (String scrap in scraps) {
          tempScrapTimes[scrap] = (tempScrapTimes[scrap] ?? 0) + 1;
          tempScrapWeights[scrap] =
              (tempScrapWeights[scrap] ?? 0) + weightPerType;
        }
      }

      final sortedByTimes = tempScrapTimes.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (mounted) {
        setState(() {
          _totalWeight = tempTotalWeight;
          _totalEarnings = tempTotalEarnings;
          _isLoadingStats = false;

          _topScrapsList = sortedByTimes.take(3).toList();
          _scrapWeights = tempScrapWeights;
          _isLoadingScraps = false;
        });
      }
    } catch (e) {
      print("Error fetching stats: $e");
      if (mounted)
        setState(() {
          _isLoadingStats = false;
          _isLoadingScraps = false;
        });
    }
  }

  Future<void> _fetchLatestPickup() async {
    if (!mounted) return;
    setState(() => _isLoadingTracker = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingTracker = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('pickups')
          .where('userId', isEqualTo: user.uid)
          .where('status',
          whereIn: ['Pending', 'Confirmed', 'Out-for-Pickup'])
          .orderBy('pickupDate')
          .limit(1)
          .get();

      if (mounted) {
        setState(() {
          _latestPendingPickup = snapshot.docs.firstOrNull;
          _isLoadingTracker = false;
        });
      }
    } catch (e) {
      print("Error fetching latest pickup: $e");
      if (mounted) setState(() => _isLoadingTracker = false);
    }
  }

  Future<void> _fetchUpcomingDrives() async {
    if (!mounted) return;
    setState(() => _isLoadingDrives = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('drives')
          .where('date', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('date')
          .limit(3)
          .get();

      final realDrives =
      snapshot.docs.map((doc) => Drive.fromFirestore(doc)).toList();

      List<Drive> drivesForHome = List.from(realDrives);
      int placeholdersNeeded = max(0, 3 - realDrives.length);

      for (int i = 0; i < placeholdersNeeded; i++) {
        drivesForHome.add(Drive.placeholder(uniqueId: i));
      }

      if (mounted) {
        setState(() {
          _homePageDrives = drivesForHome;
          _isLoadingDrives = false;
        });
      }
    } catch (e) {
      print("Error fetching upcoming drives: $e");
      if (mounted) {
        setState(() {
          _homePageDrives = [
            Drive.placeholder(uniqueId: 0),
            Drive.placeholder(uniqueId: 1),
            Drive.placeholder(uniqueId: 2),
          ];
          _isLoadingDrives = false;
        });
      }
    }
  }

  Future<void> _fetchBanners() async {
    if (!mounted) return;
    setState(() => _isLoadingBanners = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('banners')
          .orderBy('order')
          .get();

      final banners = snapshot.docs.map((doc) => BannerModel.fromFirestore(doc)).toList();

      if (mounted) {
        setState(() {
          _banners = banners;
          _isLoadingBanners = false;
        });
      }
    } catch (e) {
      print("Error fetching banners: $e");
      if (mounted) {
        setState(() {
          _isLoadingBanners = false;
          _banners = [];
        });
      }
    }
  }

  // ✅ 1. UPDATED THIS METHOD
  void _onBannerTapped(BannerModel banner) async {
    if (banner.linkValue.isEmpty) {
      return; // Do nothing if there's no link
    }

    switch (banner.linkType) {
      case 'URL':
      // Launch external URL
        final uri = Uri.tryParse(banner.linkValue);
        if (uri != null) {
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            print('Could not launch ${banner.linkValue}: $e');
          }
        }
        break;

      case 'PAGE':
      // ✅ 2. ADDED LOGIC TO CHECK FOR MAIN TABS
      // Check for main tab routes first
        if (banner.linkValue == '/schedule_pickup') {
          setState(() {
            _currentIndex = 1; // Switch to the Schedule Pickup tab
          });
          return; // Stop here
        }
        if (banner.linkValue == '/settings') {
          setState(() {
            _currentIndex = 2; // Switch to the Settings tab
          });
          return; // Stop here
        }

        // If not a main tab, navigate to internal page
        Widget? page;
        switch (banner.linkValue) {
          case '/pricelist':
            page = pricelist();
            break;
          case '/society_campaign':
            page = const SocietyCampaignPage();
            break;
        // You can add more pages here
          case '/history':
            page = HistoryScreen();
            break;
        }

        if (page != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page!),
          );
        }
        break;

      case 'NONE':
      default:
      // Do nothing
        break;
    }
  }

  // ... (_onDriveCardTapped, _onViewAllDrivesTapped, _mapStatusToStep, _getIconForScrap... no changes) ...
  void _onDriveCardTapped(Drive drive) {
    if (drive.isPlaceholder) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kPrimaryColor,
          content: Text(
            "A new drive is coming soon! Check back later.",
            style: TextStyle(color: kCreamLight),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriveDetailsPage(drive: drive),
        ),
      );
    }
  }

  void _onViewAllDrivesTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllDrivesPage()),
    );
  }

  int _mapStatusToStep(String? status) {
    switch (status) {
      case 'Pending':
        return 1;
      case 'Confirmed':
        return 2;
      case 'Out-for-Pickup':
        return 3;
      case 'Completed':
        return 4;
      default:
        return 0;
    }
  }

  String _getIconForScrap(String scrapName) {
    final name = scrapName.toLowerCase();
    if (name.contains('metal')) {
      return 'assets/images/home/scraps/metal.png';
    }
    if (name.contains('bottle') || name.contains('plastic')) {
      return 'assets/images/home/scraps/bottle.png';
    }
    if (name.contains('paper') || name.contains('newspaper')) {
      return 'assets/images/home/scraps/newspaper.png';
    }
    return 'assets/images/home/scraps/bottle.png';
  }


  // EXTRACTED HOME CONTENT
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ==== Header ====
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(40)),
              image: const DecorationImage(
                image: AssetImage('assets/images/home/homeheader.png'),
                fit: BoxFit.cover,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(26, 0, 21, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side (Avatar + Texts)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => profile()),
                          ).then((_) => _refreshTrackerData());
                        },
                        child: const CircleAvatar(
                          radius: 23,
                          backgroundColor: Color(0xFFa8ce4c),
                          child: Icon(Icons.account_circle,
                              color: kPrimaryColor, size: 45),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 23.0),
                            child: Row(
                              children: [
                                Text(
                                  'Hello, $userName',
                                  style: const TextStyle(
                                    fontSize: 21,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: kAccentColor, size: 18),
                              SizedBox(width: 4),
                              Text("Andhra Pradesh",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Notification Icon on the right
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child:
                  Icon(Icons.notifications, color: kAccentColor, size: 30),
                ),
              ],
            ),
          ),

          // ==== Stats Card ====
          Transform.translate(
            offset: const Offset(0, -30),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 26),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCreamLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: const Offset(0, 13)),
                ],
              ),
              child: _isLoadingStats
                  ? Center(child: CircularProgressIndicator())
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatCard(
                      icon: Icons.recycling,
                      label: '${_totalWeight.toStringAsFixed(1)} kg',
                      sub: 'Total Recycled'),
                  StatCard(
                      icon: Icons.cloud,
                      label: '0 m³',
                      sub: 'Saved CO₂'),
                  StatCard(
                      icon: Icons.currency_rupee,
                      label: '₹${_totalEarnings.toStringAsFixed(0)}',
                      sub: 'Total Earnings'),
                ],
              ),
            ),
          ),

          // ==== Scrollable Cards ====
          // ✅ 3. THIS SECTION IS NOW CLICKABLE
          _isLoadingBanners
              ? const SizedBox(
            height: 187,
            child: Center(child: CircularProgressIndicator()),
          )
              : _banners.isEmpty
              ? const SizedBox(height: 8)
              : ImageCardScroller(
            children: _banners.map((banner) {
              // Wrap the card in a GestureDetector
              return GestureDetector(
                onTap: () => _onBannerTapped(banner),
                child: buildCroppedAssetCard(banner.imageUrl, 0, 0),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // ==== UPDATED: Pickup Tracker Section ====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                if (!_isLoadingTracker && _latestPendingPickup != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Pickup Tracker",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllTrackersPage(),
                            ),
                          ).then((_) => _refreshTrackerData());
                        },
                        child: const Text(
                          "View all",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),

                if (!_isLoadingTracker && _latestPendingPickup != null)
                  const SizedBox(height: 4),

                _isLoadingTracker
                    ? const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()))
                    : _latestPendingPickup != null
                    ? PickupTracker(
                  currentStep: _mapStatusToStep(
                      _latestPendingPickup!['status'] as String?),
                  pickupDate: (_latestPendingPickup!['pickupDate']
                  as Timestamp)
                      .toDate(),
                  showUpcomingTag: true,
                  pickupId: _latestPendingPickup!.id,
                )
                    : const SizedBox(
                    height: 0),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ==== Shortcuts Grid ====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ShortcutButton(
                    icon: Icons.list,
                    label: 'Price List \n',
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => pricelist()));
                    },
                  ),
                  ShortcutButton(
                    icon: Icons.history,
                    label: 'History \n',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => HistoryScreen()))
                          .then((_) => _refreshTrackerData());
                    },
                  ),
                  ShortcutButton(
                    icon: Icons.track_changes,
                    label: 'Live \n Tracking',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Live Tracking is an upcoming feature!",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: kPrimaryColor,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  ShortcutButton(
                    icon: Icons.campaign,
                    label: 'Society \n Campaign',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SocietyCampaignPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ==== Footer Image ====
          Padding(
            padding: const EdgeInsets.all(0),
            child: ClipRRect(
              child: Align(
                child: Image.asset('assets/images/home/15.png'),
              ),
            ),
          ),

          // ==== Recycling Dashboard Section ====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- UPCOMING DRIVES ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Upcoming Drives",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    TextButton(
                      onPressed: _onViewAllDrivesTapped,
                      child: const Text(
                        "View all",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: _isLoadingDrives
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _homePageDrives.length,
                    itemBuilder: (context, index) {
                      final drive = _homePageDrives[index];
                      return DriveCard(
                        drive: drive,
                        onTap: () => _onDriveCardTapped(drive),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // --- Most Recycled Scraps ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Most Recycled Scraps",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("View all", style: TextStyle(color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 10),

                _isLoadingScraps
                    ? Center(child: CircularProgressIndicator())
                    : _topScrapsList.isEmpty
                    ? Center(
                    child: Text("No completed pickups yet.",
                        style: TextStyle(fontSize: 16)))
                    : Column(
                  children: _topScrapsList.map((entry) {
                    final name = entry.key;
                    final times = entry.value.toString();
                    final kg = _scrapWeights[name]
                        ?.toStringAsFixed(1) ??
                        '0.0';
                    final iconPath = _getIconForScrap(name);
                    return scrapCard(name, times, kg, iconPath);
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method - no changes) ...
    const List<String> _pageTitles = [
      'Home',
      'Schedule Pickup',
      'Settings',
    ];

    final List<Widget> pages = [
      _buildHomeContent(),
      SchedulePickup(
          onPickupScheduled: _onPickupScheduled,
          isTab: true),
      Settings_page(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kPrimaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kCreamColor,

        appBar: _currentIndex == 0
            ? null
            : AppBar(
          centerTitle: true,
          title: Text(
            _pageTitles[_currentIndex],
            style: const TextStyle(
              fontFamily: 'RedHatDisplay',
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1.0,
              color: kCreamColor,
            ),
          ),
          backgroundColor: kPrimaryColor,
          automaticallyImplyLeading: false,
        ),

        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: kGreenLight,
          currentIndex: _currentIndex,

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.schedule), label: 'Schedule Pickup'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

// ==== Reusable Components ====

// ... (StatCard, ShortcutButton, UnevenCropClipper, ImageCardScroller remain unchanged) ...
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const StatCard(
      {required this.icon,
        required this.label,
        required this.sub,
        super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 37),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(sub, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ShortcutButton({
    required this.icon,
    required this.label,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFa6cb56),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 3),
          Text(label,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class UnevenCropClipper extends CustomClipper<Rect> {
  final double topTrim;
  final double bottomTrim;
  UnevenCropClipper({required this.topTrim, required this.bottomTrim});

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, topTrim, size.width, size.height - bottomTrim);

  @override
  bool shouldReclip(covariant UnevenCropClipper oldClipper) =>
      topTrim != oldClipper.topTrim || bottomTrim != oldClipper.bottomTrim;
}

class ImageCardScroller extends StatefulWidget {
  final List<Widget> children;
  const ImageCardScroller({super.key, required this.children});

  @override
  _ImageCardScrollerState createState() => _ImageCardScrollerState();
}

class _ImageCardScrollerState extends State<ImageCardScroller> {
  late final PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
  }

  @override
  void didUpdateWidget(ImageCardScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _controller.jumpToPage(0);
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.children.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: widget.children[index],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.children.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 12 : 8,
              height: _currentIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? const Color(0xFFa8ce4c)
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}

