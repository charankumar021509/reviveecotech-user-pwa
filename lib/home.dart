import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:revive_eco_tech_app/history.dart';
import 'package:revive_eco_tech_app/pricelist.dart';
import 'package:revive_eco_tech_app/setting.dart';
import 'package:revive_eco_tech_app/profile.dart';
import 'Schedule_Pickup.dart';
import 'notification.dart';
import 'widgets/pickup_tracker.dart';
import 'package:revive_eco_tech_app/all_trackers_page.dart';
import 'package:revive_eco_tech_app/society_campaign_page.dart';

import 'dart:math';
import 'package:revive_eco_tech_app/widgets/drive_model.dart';
import 'package:revive_eco_tech_app/all_drives_page.dart';
import 'package:revive_eco_tech_app/drive_details_page.dart';

import 'package:revive_eco_tech_app/widgets/banner_model.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:revive_eco_tech_app/utilities/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';

// ─── Design Tokens ───────────────────────────────────────────────
const kPrimaryColor   = Color(0xFF013856);
const kAccentColor    = Color(0xFFa7cd47);
const kCreamColor     = Color(0xFFfcf3e2);
const kCreamLight     = Color(0xFFfefaef);
const kGreenLight     = Color(0xFFd3e7b4);
const kRedColor       = Color(0xFFE53935);

// Extended palette for premium feel
const kPrimaryDark    = Color(0xFF01263D);
const kPrimaryMid     = Color(0xFF024D75);
const kAccentDark     = Color(0xFF8AAF2A);
const kAccentLight    = Color(0xFFD4E88A);
const kSurface        = Color(0xFFFFFFFF);
const kSurfaceDim     = Color(0xFFF5F0E8);
const kTextPrimary    = Color(0xFF0D1B2A);
const kTextSecondary  = Color(0xFF6B7A8D);
const kTextHint       = Color(0xFFAAB4C0);

// ─── HomePage ─────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {

  String userName = "User";

  // Data state
  bool _isLoadingStats   = true;
  bool _isLoadingTracker = true;
  bool _isLoadingDrives  = true;
  bool _isLoadingBanners = true;

  double _totalWeight   = 0;
  double _totalEarnings = 0;

  DocumentSnapshot? _latestPendingPickup;
  List<Drive>       _homePageDrives  = [];
  List<BannerModel> _banners         = [];

  int _currentIndex       = 0;
  int _notificationCount  = 0;
  String _currentLocation = "India";

  // ─── Animation controllers ──────────────────────────────────────
  late AnimationController _headerAnim;
  late AnimationController _statsAnim;
  late AnimationController _contentAnim;
  late AnimationController _shimmerAnim;

  late Animation<double>  _headerFade;
  late Animation<Offset>  _headerSlide;
  late Animation<double>  _statsFade;
  late Animation<Offset>  _statsSlide;
  late Animation<double>  _contentFade;
  late Animation<Offset>  _contentSlide;
  late Animation<double>  _shimmerProgress;

  @override
  void initState() {
    super.initState();

    // Header animation (0–600ms)
    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade  = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));

    // Stats card (200ms delay)
    _statsAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _statsFade  = CurvedAnimation(parent: _statsAnim, curve: Curves.easeOut);
    _statsSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _statsAnim, curve: Curves.easeOutCubic));

    // Body content (400ms delay)
    _contentAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _contentFade  = CurvedAnimation(parent: _contentAnim, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentAnim, curve: Curves.easeOutCubic));

    // Shimmer
    _shimmerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _shimmerProgress = CurvedAnimation(parent: _shimmerAnim, curve: Curves.easeInOut);

    // Staggered entrance
    _headerAnim.forward();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _statsAnim.forward();
    });
    Future.delayed(const Duration(milliseconds: 340), () {
      if (mounted) _contentAnim.forward();
    });

    WidgetsBinding.instance.addObserver(this);
    NotificationService().initNotifications(context);
    _listenToNotificationCount();
    _fetchAllData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _headerAnim.dispose();
    _statsAnim.dispose();
    _contentAnim.dispose();
    _shimmerAnim.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshTrackerData();
  }

  // ─── Data fetching (unchanged logic) ────────────────────────────
  void _listenToNotificationCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('notifications').doc(user.uid)
          .collection('userNotifications')
          .where('read', isEqualTo: false)
          .snapshots().listen((snapshot) {
        if (mounted) setState(() => _notificationCount = snapshot.docs.length);
      });
    }
  }

  void _onPickupScheduled() {
    _refreshTrackerData();
    setState(() => _currentIndex = 0);
  }

  void _fetchAllData() {
    fetchUserName();
    _fetchStatsAndScraps();
    _fetchLatestPickup();
    _fetchUpcomingDrives();
    _fetchBanners();
  }

  void _refreshTrackerData() {
    if (!mounted) return;
    setState(() { _isLoadingTracker = true; _isLoadingStats = true; });
    _fetchLatestPickup();
    _fetchStatsAndScraps();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        String fetchedName = data["name"] ?? "User";
        if (fetchedName.isEmpty) fetchedName = "User-${user.uid.substring(0, 6)}";

        String detectedLocation = "India";
        if (data['currentAddress'] != null && data['currentAddress'] is Map) {
          String fullAddress = data['currentAddress']['fullAddress'] ?? "";
          if (fullAddress.contains("Telangana") || fullAddress.contains("Hyderabad")) {
            detectedLocation = "Telangana";
          } else if (fullAddress.contains("Andhra") ||
              fullAddress.contains("Visakhapatnam") ||
              fullAddress.contains("Vijayawada")) {
            detectedLocation = "Andhra Pradesh";
          }
        }
        if (mounted) setState(() { userName = fetchedName; _currentLocation = detectedLocation; });
      }
    } catch (e) { debugPrint("Error fetching profile: $e"); }
  }

  Future<void> _fetchStatsAndScraps() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { if (mounted) setState(() => _isLoadingStats = false); return; }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      final pickupsSnapshot = await FirebaseFirestore.instance
          .collection('pickups').where('userId', isEqualTo: user.uid).get();
      double totalEarnings = 0;
      for (var doc in pickupsSnapshot.docs) {
        final data = doc.data();
        totalEarnings += double.tryParse(data['finalPrice'].toString()) ?? 0;
      }
      if (mounted) setState(() {
        _totalWeight   = (userData['totalWeight'] as num? ?? 0).toDouble();
        _totalEarnings = totalEarnings;
        _isLoadingStats = false;
      });
    } catch (e) {
      debugPrint("Error fetching stats: $e");
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _fetchLatestPickup() async {
    if (!mounted) return;
    setState(() => _isLoadingTracker = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { if (mounted) setState(() => _isLoadingTracker = false); return; }
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('pickups')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['Pending','Confirmed','Out-for-Pickup','Estimate Sent','OTP Generated'])
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        if (mounted) setState(() { _latestPendingPickup = null; _isLoadingTracker = false; });
        return;
      }
      final status = snapshot.docs.first['status'];
      if (status == 'Completed') {
        if (mounted) setState(() { _latestPendingPickup = null; _isLoadingTracker = false; });
        return;
      }
      final docs = snapshot.docs;
      docs.sort((a, b) {
        final statusA = a['status'] as String;
        final statusB = b['status'] as String;
        final dateA   = (a['pickupDate'] as Timestamp).toDate();
        final dateB   = (b['pickupDate'] as Timestamp).toDate();
        if (statusA == 'Out-for-Pickup' && statusB != 'Out-for-Pickup') return -1;
        if (statusA != 'Out-for-Pickup' && statusB == 'Out-for-Pickup') return 1;
        return dateA.compareTo(dateB);
      });
      if (mounted) setState(() { _latestPendingPickup = docs.first; _isLoadingTracker = false; });
    } catch (e) {
      debugPrint("Error fetching pickup: $e");
      if (mounted) setState(() => _isLoadingTracker = false);
    }
  }

  Future<void> _fetchUpcomingDrives() async {
  if (!mounted) return;

  setState(() => _isLoadingDrives = true);

  try {
    List<Drive> drivesForHome = [
      Drive(
        id: '1',
        title: 'My Test Drive',
        location: 'Greenview Apartments, Main Gate',
        date: DateTime(2026, 12, 18),
        details: 'Test Drive',
        imageUrl: 'assets/images/home/drives/recycle.jpeg',
      ),
      Drive.placeholder(uniqueId: 0),
      Drive.placeholder(uniqueId: 1),
    ];

    if (mounted) {
      setState(() {
        _homePageDrives = drivesForHome;
        _isLoadingDrives = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
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
          .collection('banners').orderBy('order').get();
      final banners = snapshot.docs.map((doc) => BannerModel.fromFirestore(doc)).toList();
      if (mounted) setState(() { _banners = banners; _isLoadingBanners = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoadingBanners = false; _banners = []; });
    }
  }

  // ─── Navigation helpers ──────────────────────────────────────────
  void _onBannerTapped(BannerModel banner) async {
    if (banner.linkValue.isEmpty) return;
    switch (banner.linkType) {
      case 'URL':
        final uri = Uri.tryParse(banner.linkValue);
        if (uri != null) {
          try { await launchUrl(uri, mode: LaunchMode.externalApplication); } catch (e) {}
        }
        break;
      case 'PAGE':
        if (banner.linkValue == '/schedule_pickup') { setState(() => _currentIndex = 1); return; }
        if (banner.linkValue == '/settings')        { setState(() => _currentIndex = 2); return; }
        Widget? page;
        switch (banner.linkValue) {
          case '/pricelist':        page = pricelist();                    break;
          case '/society_campaign': page = const SocietyCampaignPage();   break;
          case '/history':          page = HistoryScreen();                break;
        }
        if (page != null && mounted) Navigator.push(context, _fadeRoute(page));
        break;
    }
  }

  void _onDriveCardTapped(Drive drive) {
    if (drive.isPlaceholder) {
      _showToast("A new drive is coming soon! Check back later.");
    } else {
      Navigator.push(context, _fadeRoute(DriveDetailsPage(drive: drive)));
    }
  }

  void _onViewAllDrivesTapped() =>
      Navigator.push(context, _fadeRoute(const AllDrivesPage()));

  // ─── Utilities ───────────────────────────────────────────────────
  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      backgroundColor: kPrimaryColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 100, left: 32, right: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      duration: const Duration(seconds: 2),
    ));
  }

  Route _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
    transitionDuration: const Duration(milliseconds: 280),
  );

  int _mapStatusToStep(String? status) {
    switch (status) {
      case 'Pending':       return 1;
      case 'Confirmed':     return 2;
      case 'Out-for-Pickup':return 3;
      case 'Completed':     return 4;
      default:              return 0;
    }
  }

  String _resolveImageUrl(String raw) {
    if (raw.contains('drive.google.com')) {
      return raw.replaceAll('uc?export=view&id=', 'thumbnail?id=') + '&sz=w2000';
    }
    return raw;
  }

  // ─── Shimmer helper ──────────────────────────────────────────────
  Widget _shimmer({double height = 16, double? width, double radius = 10}) {
    return AnimatedBuilder(
      animation: _shimmerProgress,
      builder: (_, __) {
        final gradient = LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          stops: const [0.0, 0.4, 0.6, 1.0],
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.white,
            Colors.grey.shade200,
          ],
          transform: GradientRotation(_shimmerProgress.value * 3.14),
        );
        return Container(
          height: height, width: width,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  // ─── Build ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final List<String> pageTitles = [
      'home'.tr(),
      'schedule_pickup'.tr(),
      'settings'.tr(),
    ];
    final List<Widget> pages = [
      _buildHomeContent(),
      SchedulePickup(onPickupScheduled: _onPickupScheduled, isTab: true),
      Settings_page(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() => _currentIndex = 0);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: kCreamColor,
          extendBodyBehindAppBar: true,

          appBar: _currentIndex == 0
              ? null
              : PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: AppBar(
                centerTitle: true,
                toolbarHeight: 64,
                title: Text(
                  pageTitles[_currentIndex],
                  style: const TextStyle(
                    fontFamily: 'RedHatDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 0.5,
                    color: kCreamColor,
                  ),
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [kPrimaryColor, kPrimaryMid],
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                elevation: 0,
              ),
            ),
          ),

          body: IndexedStack(index: _currentIndex, children: pages),
          extendBody: true,
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  // ─── Bottom nav ──────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.12),
                  blurRadius: 32, offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 1, offset: const Offset(0, -1),
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _navItem(Icons.home_rounded,          'home'.tr(),            0),
                _navItem(Icons.calendar_month_rounded, 'schedule_pickup'.tr(), 1),
                _navItem(Icons.settings_rounded,       'settings'.tr(),        2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(horizontal: selected ? 20 : 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kAccentColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 220),
              child: Icon(icon, size: 26,
                  color: selected ? kPrimaryColor : kTextSecondary),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOutCubic,
              child: selected
                  ? Row(children: [
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: kPrimaryColor,
                    )),
              ])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Home content ─────────────────────────────────────────────────
  Widget _buildHomeContent() {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 900;

    return Container(
      color: isDesktop ? const Color(0xFFF5EFE3) : kCreamColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header — full width always
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: _buildHeader(),
              ),
            ),

            // 2. Stats card — centered on desktop
            FadeTransition(
              opacity: _statsFade,
              child: SlideTransition(
                position: _statsSlide,
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: isDesktop
                      ? Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: _buildStatsCard(),
                          ),
                        )
                      : _buildStatsCard(),
                ),
              ),
            ),

            // 3+ Content
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Column(
                    children: [
                      _buildBannerSection(),
                      const SizedBox(height: 28),
                      _buildShortcutsSection(),
                      const SizedBox(height: 32),
                      _buildDrivesSection(),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [kPrimaryColor, kPrimaryMid],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
      ),
      child: Stack(
        children: [
          // Background image overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(44)),
              child: Image.asset(
                'assets/images/home/homeheader.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.18),
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          // Decorative circle
          Positioned(
            right: -40, top: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccentColor.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 20, bottom: 60,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 68),
              child: Row(
                children: [
                  // Avatar
                  _buildAvatarButton(),
                  const SizedBox(width: 16),
                  // Greeting
                  Expanded(child: _buildGreeting()),
                  // Notification bell
                  _buildNotificationBell(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context, _fadeRoute(profile()),
      ).then((_) => _refreshTrackerData()),
      child: Hero(
        tag: 'user-avatar',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kAccentColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: kAccentColor.withOpacity(0.3),
                blurRadius: 12, spreadRadius: 1,
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_rounded, color: kPrimaryColor, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Hello, $userName 👋',
          style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800,
            color: Colors.white, letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded, color: kAccentColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _currentLocation,
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationBell() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context, _fadeRoute(const NotificationPage()),
      ).then((_) => _refreshTrackerData()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
            if (_notificationCount > 0)
              Positioned(
                right: -3, top: -3,
                child: AnimatedScale(
                  scale: 1.0, duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: kRedColor, shape: BoxShape.circle),
                    child: Text(
                      _notificationCount > 9 ? '9+' : _notificationCount.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Stats card ──────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.10),
            blurRadius: 24, offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 4, offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _isLoadingStats ? _buildStatsShimmer() : _buildStatsContent(),
    );
  }

  Widget _buildStatsShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (_) => Column(
          children: [
            _shimmer(height: 32, width: 32, radius: 16),
            const SizedBox(height: 8),
            _shimmer(height: 18, width: 64),
            const SizedBox(height: 6),
            _shimmer(height: 12, width: 48),
          ],
        )),
      ),
    );
  }

  Widget _buildStatsContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
      child: Row(
        children: [
          Expanded(child: _PremiumStatTile(
            icon: Icons.recycling_rounded,
            iconColor: const Color(0xFF2E9E5E),
            iconBg: const Color(0xFFE8F6EF),
            value: '${_totalWeight.toStringAsFixed(1)} kg',
            label: 'recycled'.tr(),
          )),
          _statDivider(),
          Expanded(child: _PremiumStatTile(
            icon: Icons.cloud_outlined,
            iconColor: const Color(0xFF2979FF),
            iconBg: const Color(0xFFE8F0FE),
            value: '${(_totalWeight * 1.61803399).toStringAsFixed(1)} m³',
            label: 'co2_saved'.tr(),
          )),
          _statDivider(),
          Expanded(child: _PremiumStatTile(
            icon: Icons.currency_rupee_rounded,
            iconColor: const Color(0xFFFF6F00),
            iconBg: const Color(0xFFFFF3E0),
            value: '₹${_totalEarnings.toStringAsFixed(0)}',
            label: 'earned'.tr(),
          )),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(
    width: 1, height: 48,
    color: kTextHint.withOpacity(0.3),
  );

  // ─── Banner section ──────────────────────────────────────────────
  Widget _buildBannerSection() {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (_isLoadingBanners) {
      return _desktopWrap(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: _shimmer(height: 200, radius: 22),
          ),
        ),
      );
    }
    if (_banners.isEmpty) return const SizedBox.shrink();

    return _desktopWrap(
      _PremiumBannerScroller(
        banners: _banners,
        onTap: _onBannerTapped,
        resolveUrl: _resolveImageUrl,
        bannerHeight: isDesktop ? 220 : 172,
      ),
    );
  }

  // ─── Desktop content wrapper ─────────────────────────────────────
  // Centers content with max-width on wide screens
  Widget _desktopWrap(Widget child) {
    final w = MediaQuery.of(context).size.width;
    if (w < 900) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: child,
      ),
    );
  }

  // ─── Shortcuts section ───────────────────────────────────────────
  Widget _buildShortcutsSection() {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 900;

    final shortcuts = [
      _ShortcutData(
        icon: Icons.format_list_bulleted_rounded,
        label: 'price_list'.tr(),
        gradient: const [Color(0xFF013856), Color(0xFF024D75)],
        onTap: () => Navigator.push(context, _fadeRoute(const pricelist())),
      ),
      _ShortcutData(
        icon: Icons.history_rounded,
        label: 'history'.tr(),
        gradient: const [Color(0xFF8AAF2A), Color(0xFFa7cd47)],
        onTap: () => Navigator.push(context, _fadeRoute(HistoryScreen()))
            .then((_) => _refreshTrackerData()),
      ),
      _ShortcutData(
        icon: Icons.track_changes_rounded,
        label: 'tracking'.tr(),
        gradient: const [Color(0xFF00897B), Color(0xFF26A69A)],
        onTap: () => Navigator.push(context, _fadeRoute(const AllTrackersPage())),
      ),
      _ShortcutData(
        icon: Icons.campaign_rounded,
        label: 'campaign'.tr(),
        gradient: const [Color(0xFFE65100), Color(0xFFFF8F00)],
        onTap: () => Navigator.push(context, _fadeRoute(const SocietyCampaignPage())),
      ),
    ];

    return _desktopWrap(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: isDesktop ? 20 : 17,
                fontWeight: FontWeight.w800,
                color: kPrimaryColor,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 16),

            // Desktop: compact pill-style row buttons
            if (isDesktop)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: shortcuts.map((s) => _DesktopShortcutPill(
                  icon: s.icon,
                  label: s.label,
                  gradient: s.gradient,
                  onTap: s.onTap,
                )).toList(),
              )

            // Mobile: icon + label stacked in equal row
            else
              Row(
                children: shortcuts.asMap().entries.map((e) {
                  final isLast = e.key == shortcuts.length - 1;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 12),
                      child: _PremiumShortcut(
                        icon: e.value.icon,
                        label: e.value.label,
                        gradient: e.value.gradient,
                        onTap: e.value.onTap,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Drives section ──────────────────────────────────────────────
  Widget _buildDrivesSection() {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 900;
    final isTablet  = w >= 600;

    return _desktopWrap(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Drives',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 17,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: _onViewAllDrivesTapped,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: kAccentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: kAccentDark, fontSize: 13, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Loading shimmer
          if (_isLoadingDrives)
            isDesktop || isTablet
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: List.generate(isDesktop ? 3 : 2, (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < (isDesktop ? 2 : 1) ? 16 : 0),
                          child: _shimmer(height: 260, radius: 24),
                        ),
                      )),
                    ),
                  )
                : SizedBox(
                    height: 248,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, __) => _shimmer(height: 248, width: 172, radius: 24),
                    ),
                  )

          // Desktop: proper grid filling full width
          else if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _homePageDrives.take(3).toList().asMap().entries.map((e) {
                  final isLast = e.key == 2;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 16),
                      child: DriveCard(
                        drive: e.value,
                        onTap: () => _onDriveCardTapped(e.value),
                        fillWidth: true,
                      ),
                    ),
                  );
                }).toList(),
              ),
            )

          // Tablet: 2-column grid
          else if (isTablet)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _homePageDrives.length,
                itemBuilder: (_, i) => DriveCard(
                  drive: _homePageDrives[i],
                  onTap: () => _onDriveCardTapped(_homePageDrives[i]),
                  fillWidth: true,
                ),
              ),
            )

          // Mobile: horizontal scroll
          else
            SizedBox(
              height: 248,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: _homePageDrives.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => DriveCard(
                  drive: _homePageDrives[i],
                  onTap: () => _onDriveCardTapped(_homePageDrives[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Premium stat tile ────────────────────────────────────────────
class _PremiumStatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _PremiumStatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 15, color: kTextPrimary,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: kTextSecondary, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Shortcut data holder ─────────────────────────────────────────
class _ShortcutData {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback? onTap;
  const _ShortcutData({
    required this.icon, required this.label,
    required this.gradient, this.onTap,
  });
}

// ─── Desktop pill-style shortcut ─────────────────────────────────
// Looks like: [🟩 icon] Label  — horizontal compact chip
class _DesktopShortcutPill extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback? onTap;
  const _DesktopShortcutPill({
    required this.icon, required this.label,
    required this.gradient, this.onTap,
  });

  @override
  State<_DesktopShortcutPill> createState() => _DesktopShortcutPillState();
}

class _DesktopShortcutPillState extends State<_DesktopShortcutPill> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) { setState(() => _pressed = false); widget.onTap?.call(); },
        onTapCancel: ()  => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _hovered ? Colors.white : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? widget.gradient.first.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: _hovered ? [
                BoxShadow(
                  color: widget.gradient.last.withOpacity(0.2),
                  blurRadius: 16, offset: const Offset(0, 6),
                ),
              ] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon bubble
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _hovered ? widget.gradient.first : kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Premium shortcut button ─────────────────────────────────────
class _PremiumShortcut extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final bool desktopMode;

  const _PremiumShortcut({
    required this.icon, required this.label,
    required this.gradient, this.onTap,
    this.desktopMode = false,
  });

  @override
  State<_PremiumShortcut> createState() => _PremiumShortcutState();
}

class _PremiumShortcutState extends State<_PremiumShortcut> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final iconSize   = widget.desktopMode ? 28.0 : 24.0;
    final iconPad    = widget.desktopMode ? 20.0 : 14.0;
    final labelSize  = widget.desktopMode ? 13.0 : 11.0;
    final radius     = widget.desktopMode ? 22.0 : 18.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) { setState(() => _pressed = false); widget.onTap?.call(); },
        onTapCancel: ()  => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.93 : (_hovered ? 1.04 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.all(iconPad),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: widget.gradient,
                  ),
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: (_pressed || !_hovered) ? [
                    BoxShadow(
                      color: widget.gradient.last.withOpacity(0.30),
                      blurRadius: 10, offset: const Offset(0, 4),
                    ),
                  ] : [
                    BoxShadow(
                      color: widget.gradient.last.withOpacity(0.45),
                      blurRadius: 18, offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(widget.icon, size: iconSize, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: labelSize, fontWeight: FontWeight.w700, color: kPrimaryColor,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Premium banner scroller ─────────────────────────────────────
class _PremiumBannerScroller extends StatefulWidget {
  final List<BannerModel> banners;
  final void Function(BannerModel) onTap;
  final String Function(String) resolveUrl;
  final double bannerHeight;

  const _PremiumBannerScroller({
    super.key,
    required this.banners,
    required this.onTap,
    required this.resolveUrl,
    this.bannerHeight = 172,
  });

  @override
  State<_PremiumBannerScroller> createState() =>
      _PremiumBannerScrollerState();
}

class _PremiumBannerScrollerState
    extends State<_PremiumBannerScroller> {
  late final PageController _ctrl;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(
      viewportFraction: 0.92,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.bannerHeight,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.banners.length,
            onPageChanged: (i) {
              setState(() {
                _current = i;
              });
            },
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              final bannerImages = [
  'assets/banners/banner 1.png',
  'assets/banners/banner 2.png',
  'assets/banners/banner 3.png',
];

return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 4),
  child: GestureDetector(
    onTap: () => widget.onTap(banner),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.asset(
  bannerImages[index],
  fit: BoxFit.contain,
  width: double.infinity,
)
    ),
  ),
);
            },
          ),
        ),

        const SizedBox(height: 12),

        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (i) {
              final active = _current == i;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                margin:
                    const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active
                      ? kAccentDark
                      : kTextHint.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Stat card (kept for backward compatibility) ──────────────────
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const StatCard({required this.icon, required this.label, required this.sub, super.key});

  @override
  Widget build(BuildContext context) => _PremiumStatTile(
    icon: icon, iconColor: kAccentDark, iconBg: kGreenLight,
    value: label, label: sub,
  );
}

// ─── ShortcutButton (kept for backward compatibility) ─────────────
class ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const ShortcutButton({required this.icon, required this.label, this.onTap, super.key});

  @override
  Widget build(BuildContext context) => _PremiumShortcut(
    icon: icon, label: label,
    gradient: const [kPrimaryColor, kPrimaryMid],
    onTap: onTap,
  );
}

// ─── UnevenCropClipper (unchanged) ───────────────────────────────
class UnevenCropClipper extends CustomClipper<Rect> {
  final double topTrim;
  final double bottomTrim;
  UnevenCropClipper({required this.topTrim, required this.bottomTrim});

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, topTrim, size.width, size.height - bottomTrim);

  @override
  bool shouldReclip(covariant UnevenCropClipper old) =>
      topTrim != old.topTrim || bottomTrim != old.bottomTrim;
}

// ─── ImageCardScroller (legacy, kept for compatibility) ───────────
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
    _controller = PageController(viewportFraction: 0.92);
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
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.children.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: widget.children[i],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.children.length, (i) {
            final active = _currentIndex == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width:  active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color:  active ? kAccentDark : kTextHint.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DRIVE CARD
// ═══════════════════════════════════════════════════════════════════

double _driveCardWidth(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w >= 900) return 220;
  if (w >= 600) return 200;
  return 172;
}

class DriveCard extends StatefulWidget {
  final Drive drive;
  final VoidCallback? onTap;
  final bool fillWidth; // true on desktop/tablet grid — expands to parent width
  const DriveCard({super.key, required this.drive, this.onTap, this.fillWidth = false});

  @override
  State<DriveCard> createState() => _DriveCardState();
}

class _DriveCardState extends State<DriveCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _hoverCtrl;
  late final Animation<double> _hoverAnim;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _hoverAnim = CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _hoverCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cardW = _driveCardWidth(context);
    return MouseRegion(
      onEnter: (_) => _hoverCtrl.forward(),
      onExit:  (_) => _hoverCtrl.reverse(),
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) { setState(() => _pressed = false); widget.onTap?.call(); },
        onTapCancel: ()  => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeInOut,
          child: AnimatedBuilder(
            animation: _hoverAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, -4 * _hoverAnim.value),
              child: child,
            ),
            child: _buildCard(cardW),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(double width) {
    return Container(
      width: widget.fillWidth ? double.infinity : width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.09),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 2, offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildImageArea(width),
          _buildInfo(),
        ],
      ),
    );
  }

  // ── Image area ────────────────────────────────────────────────
  Widget _buildImageArea(double cardW) {
    final drive = widget.drive;
    final isAsset = drive.imageUrl.startsWith('assets/');

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SizedBox(
        height: cardW * 0.72,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image — asset or network
            isAsset
                ? Image.asset(
                    drive.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderBg(),
                  )
                : CachedNetworkImage(
                    imageUrl: drive.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: const Color(0xFFEEEEEE),
                      child: const Center(
                        child: SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kAccentColor),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => _placeholderBg(),
                  ),

            // Bottom scrim
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Badge
            Positioned(
              top: 12, right: 12,
              child: drive.isPlaceholder
                  ? _ComingSoonBadge()
                  : _OpenBadge(),
            ),

            // Eco icon on placeholder
            if (drive.isPlaceholder)
              Positioned(
                bottom: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco_rounded,
                      color: kAccentDark, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBg() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFDCEDC8)],
          ),
        ),
        child: Center(
          child: Icon(Icons.nature_people_rounded,
              color: kAccentDark.withOpacity(0.35), size: 48),
        ),
      );

  // ── Info section ──────────────────────────────────────────────
  Widget _buildInfo() {
    final drive = widget.drive;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title (correct field name from drive_model.dart)
          Text(
            drive.title,
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w800,
              color: kTextPrimary, letterSpacing: 0.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // date (non-nullable DateTime in drive_model.dart)
          _DriveInfoRow(
            icon: Icons.calendar_today_rounded,
            iconColor: kPrimaryMid,
            text: _formatDate(drive.date),
          ),

          // location (non-nullable String in drive_model.dart)
          const SizedBox(height: 5),
          _DriveInfoRow(
            icon: Icons.location_on_rounded,
            iconColor: kAccentDark,
            text: drive.location,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

// ─── Drive info row ───────────────────────────────────────────────
class _DriveInfoRow extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   text;
  const _DriveInfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12, color: kTextSecondary, fontWeight: FontWeight.w500,
            ),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Coming Soon badge ────────────────────────────────────────────
class _ComingSoonBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF8AAF2A), Color(0xFFa7cd47)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8AAF2A).withOpacity(0.4),
            blurRadius: 8, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 11, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'COMING SOON',
            style: TextStyle(
              color: Colors.white, fontSize: 9,
              fontWeight: FontWeight.w900, letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Open / Active badge ──────────────────────────────────────────
class _OpenBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.4),
            blurRadius: 8, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: kAccentColor),
          SizedBox(width: 4),
          Text(
            'OPEN',
            style: TextStyle(
              color: Colors.white, fontSize: 9,
              fontWeight: FontWeight.w900, letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DriveCardGrid — responsive ───────────────────────────────────
class DriveCardGrid extends StatelessWidget {
  final List<Drive> drives;
  final void Function(Drive) onTap;
  const DriveCardGrid({super.key, required this.drives, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    if (w >= 900) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.72,
        ),
        itemCount: drives.length,
        itemBuilder: (_, i) =>
            DriveCard(drive: drives[i], onTap: () => onTap(drives[i])),
      );
    }

    if (w >= 600) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: drives.length,
        itemBuilder: (_, i) =>
            DriveCard(drive: drives[i], onTap: () => onTap(drives[i])),
      );
    }

    // Mobile — horizontal scroll
    return SizedBox(
      height: 248,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: drives.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) =>
            DriveCard(drive: drives[i], onTap: () => onTap(drives[i])),
      ),
    );
  }
}