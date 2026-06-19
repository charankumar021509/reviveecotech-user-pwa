import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:revive_eco_tech_app/launch_page.dart';
import 'package:revive_eco_tech_app/refer_page.dart';
import 'package:revive_eco_tech_app/review_and_rate_page.dart';
import 'history.dart';
import 'manage_addresses.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
// ─── Design tokens ────────────────────────────────────────────────
const kPrimaryColor  = Color(0xFF013856);
const kPrimaryMid    = Color(0xFF024D75);
const kAccentColor   = Color(0xFFa7cd47);
const kAccentDark    = Color(0xFF8AAF2A);
const kCreamColor    = Color(0xFFfcf3e2);
const kCreamLight    = Color(0xFFfefaef);
const kTextPrimary   = Color(0xFF0D1B2A);
const kTextSecondary = Color(0xFF6B7A8D);
const kTextHint      = Color(0xFFAAB4C0);
const kRedColor      = Color(0xFFE53935);

class profile extends StatefulWidget {
  const profile({super.key});
  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> with TickerProviderStateMixin {

  // ── Animation controllers ────────────────────────────────────────
  late AnimationController _headerAnim;
  late AnimationController _contentAnim;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;
  late Animation<double>   _contentFade;
  late Animation<Offset>   _contentSlide;

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade  = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));

    _contentAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _contentFade  = CurvedAnimation(parent: _contentAnim, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentAnim, curve: Curves.easeOutCubic));

    _headerAnim.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentAnim.forward();
    });

    _syncVerifiedData();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _contentAnim.dispose();
    super.dispose();
  }

  // ── Background sync (unchanged logic) ────────────────────────────
  Future<void> _syncVerifiedData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser!;
      if (refreshedUser.email != null && refreshedUser.emailVerified) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(refreshedUser.uid).get();
        if (doc.data()?['email'] != refreshedUser.email) {
          final callable = FirebaseFunctions.instanceFor(region: 'asia-south1').httpsCallable('updateUserProfile');
          await callable.call({'email': refreshedUser.email});
        }
      }
    } catch (_) {}
  }

  Future<double> _fetchTotalEarnings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;
    final snapshot = await FirebaseFirestore.instance
        .collection('pickups').where('userId', isEqualTo: user.uid).get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += double.tryParse(doc.data()['finalPrice'].toString()) ?? 0;
    }
    return total;
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? kRedColor : kAccentDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showEditSheet(BuildContext context, Map<String, dynamic> userData, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GranularEditSheet(
        userData: userData,
        user: user,
        onSuccess: (msg) => _showSnackBar(msg),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
  Route _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: const Duration(milliseconds: 260),
  );

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Please log in.")));

    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 900;

    return Scaffold(
      backgroundColor: kCreamColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Session expired. Please log in again.",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.orange.shade800,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LaunchPage()), (_) => false);
              }
            });
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.security_rounded, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text("Session Expired", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
              const SizedBox(height: 8),
              const Text("For your security, please log back in.", style: TextStyle(color: Colors.grey)),
            ]));
          }

          final data         = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final displayName  = data['name'] ?? "User";
          final displayPhone = data['phone'] ?? '';
          String displayEmail = data['email'] ?? '';
          if (displayEmail.isEmpty && user.email != null && user.emailVerified) {
            displayEmail = user.email!;
          }
          final double totalWeight = (data['totalWeight'] as num? ?? 0).toDouble();

          int filledFields = 0;
          bool isNameFilled = displayName.isNotEmpty && displayName != "User" && !displayName.startsWith("User-");
          if (isNameFilled) filledFields++;
          if (displayEmail.isNotEmpty) filledFields++;
          if (displayPhone.isNotEmpty) filledFields++;
          double progress = filledFields / 3.0;
          bool isComplete = progress >= 0.999;

          String formattedPhone = displayPhone.startsWith('+') ? displayPhone : "+91 $displayPhone";

          if (isDesktop) {
            return _buildDesktopLayout(context, user, data, displayName, displayEmail,
                displayPhone, formattedPhone, totalWeight, progress, isComplete);
          }

          return _buildMobileLayout(context, user, data, displayName, displayEmail,
              displayPhone, formattedPhone, totalWeight, progress, isComplete);
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      BuildContext context, User user, Map<String, dynamic> data,
      String displayName, String displayEmail, String displayPhone,
      String formattedPhone, double totalWeight, double progress, bool isComplete) {

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Sliver app bar ──────────────────────────────────────
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: kPrimaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Profile',
              style: TextStyle(fontFamily: 'RedHatDisplay', fontWeight: FontWeight.w800,
                  fontSize: 20, color: Colors.white)),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))),
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeaderBg(
                context, user, data, displayName, displayEmail, displayPhone, formattedPhone),
          ),
        ),

        // ── Body content ────────────────────────────────────────
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _contentSlide,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    _buildStatsCard(totalWeight),
                    const SizedBox(height: 20),
                    _buildProfileStrengthCard(context, data, user, progress, isComplete,
                        displayEmail, displayPhone),
                    const SizedBox(height: 20),
                    _buildMenuSection(context),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(
      BuildContext context, User user, Map<String, dynamic> data,
      String displayName, String displayEmail, String displayPhone,
      String formattedPhone, double totalWeight, double progress, bool isComplete) {

    return Column(
      children: [
        // ── Desktop header bar ────────────────────────────────
        FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: _buildDesktopHeader(context, user, data, displayName,
                displayEmail, displayPhone, formattedPhone),
          ),
        ),

        // ── Desktop body ──────────────────────────────────────
        Expanded(
          child: FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _contentSlide,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: stats + strength
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildStatsCard(totalWeight),
                                const SizedBox(height: 20),
                                _buildProfileStrengthCard(context, data, user,
                                    progress, isComplete, displayEmail, displayPhone),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right column: menu
                          Expanded(
                            flex: 3,
                            child: _buildMenuSection(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Desktop top header ──────────────────────────────────────────
  Widget _buildDesktopHeader(
      BuildContext context, User user, Map<String, dynamic> data,
      String displayName, String displayEmail, String displayPhone, String formattedPhone) {

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [kPrimaryColor, kPrimaryMid],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kAccentColor, width: 3),
                          boxShadow: [BoxShadow(color: kAccentColor.withOpacity(0.3), blurRadius: 16)],
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: kAccentColor,
                            child: Icon(Icons.person_rounded, size: 42, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => _showEditSheet(context, data, user),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.edit_rounded, size: 16, color: kPrimaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Name + contact
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 6),
                        Row(children: [
                          if (displayPhone.isNotEmpty) ...[
                            _contactChip(Icons.phone_rounded, formattedPhone),
                            const SizedBox(width: 10),
                          ],
                          if (displayEmail.isNotEmpty)
                            _contactChip(Icons.email_rounded, displayEmail),
                        ]),
                      ],
                    ),
                  ),
                  // Edit button desktop
                  _DesktopEditButton(
                    onTap: () => _showEditSheet(context, data, user),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: kAccentColor),
        const SizedBox(width: 5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }

  // ── Mobile header background ────────────────────────────────────
  Widget _buildHeaderBg(
      BuildContext context, User user, Map<String, dynamic> data,
      String displayName, String displayEmail, String displayPhone, String formattedPhone) {

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [kPrimaryColor, kPrimaryMid],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(right: -30, top: -30,
                child: Container(width: 150, height: 150,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: kAccentColor.withOpacity(0.07)))),
            Positioned(left: -20, bottom: 20,
                child: Container(width: 100, height: 100,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04)))),

            // Content
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Avatar + edit
                    Stack(alignment: Alignment.bottomRight, children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kAccentColor, width: 3),
                          boxShadow: [BoxShadow(color: kAccentColor.withOpacity(0.25), blurRadius: 16)],
                        ),
                        child: const CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 47,
                            backgroundColor: kAccentColor,
                            child: Icon(Icons.person_rounded, size: 56, color: Colors.white),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEditSheet(context, data, user),
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.edit_rounded, size: 18, color: kPrimaryColor),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    Text(displayName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                        textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8, runSpacing: 6,
                      children: [
                        if (displayPhone.isNotEmpty) _contactChip(Icons.phone_rounded, formattedPhone),
                        if (displayEmail.isNotEmpty) _contactChip(Icons.email_rounded, displayEmail),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats card ──────────────────────────────────────────────────
  Widget _buildStatsCard(double totalWeight) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: kPrimaryColor.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 2, offset: const Offset(0, -1)),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _StatTile(
            icon: Icons.recycling_rounded,
            iconColor: const Color(0xFF2E9E5E),
            iconBg: const Color(0xFFE8F6EF),
            value: '${totalWeight.toStringAsFixed(1)} kg',
            label: 'recycled'.tr(),
          )),
          Container(width: 1, height: 48, color: kTextHint.withOpacity(0.3)),
          Expanded(child: _StatTile(
            icon: Icons.cloud_outlined,
            iconColor: const Color(0xFF2979FF),
            iconBg: const Color(0xFFE8F0FE),
            value: '${(totalWeight * 1.618).toStringAsFixed(1)} m³',
            label: 'co2_saved'.tr(),
          )),
          Container(width: 1, height: 48, color: kTextHint.withOpacity(0.3)),
          FutureBuilder<double>(
            future: _fetchTotalEarnings(),
            builder: (_, snap) => Expanded(child: _StatTile(
              icon: Icons.currency_rupee_rounded,
              iconColor: const Color(0xFFFF6F00),
              iconBg: const Color(0xFFFFF3E0),
              value: '₹${(snap.data ?? 0).toStringAsFixed(0)}',
              label: 'earned'.tr(),
            )),
          ),
        ],
      ),
    );
  }

  // ── Profile strength card ───────────────────────────────────────
  Widget _buildProfileStrengthCard(
      BuildContext context, Map<String, dynamic> data, User user,
      double progress, bool isComplete, String displayEmail, String displayPhone) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: isComplete
          ? Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kAccentColor.withOpacity(0.4), width: 1.5),
                boxShadow: [BoxShadow(color: kAccentColor.withOpacity(0.08),
                    blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: kAccentColor.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.verified_rounded, color: kAccentDark, size: 24),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("Profile 100% Complete",
                      style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w800, fontSize: 15)),
                  Text("All details verified.",
                      style: TextStyle(color: kTextSecondary, fontSize: 12)),
                ]),
              ]),
            )
          : Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [kPrimaryColor, kPrimaryMid]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.25),
                    blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.verified_user_outlined, color: kAccentColor, size: 20),
                  const SizedBox(width: 8),
                  const Text("Profile Strength",
                      style: TextStyle(color: kAccentColor, fontWeight: FontWeight.w700, fontSize: 14)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kAccentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("${(progress * 100).toInt()}%",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ]),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    color: kAccentColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: Text(
                      displayPhone.isEmpty && displayEmail.isEmpty
                          ? "Add Phone & Email"
                          : displayPhone.isEmpty ? "Add Phone Number" : "Add Email Address",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () => _showEditSheet(context, data, user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kPrimaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: const Text("Complete Now",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ]),
              ]),
            ),
    );
  }

  // ── Menu section ────────────────────────────────────────────────
  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      _MenuItemData(
        icon: Icons.location_on_outlined,
        label: 'manage_addresses'.tr(),
        color: const Color(0xFF013856),
        bg: const Color(0xFFE8F0FE),
        onTap: () => Navigator.push(context, _fadeRoute(const ManageAddressesPage())),
      ),
      _MenuItemData(
        icon: Icons.history_rounded,
        label: 'history'.tr(),
        color: const Color(0xFF8AAF2A),
        bg: const Color(0xFFE8F6EF),
        onTap: () => Navigator.push(context, _fadeRoute(HistoryScreen())),
      ),
      _MenuItemData(
        icon: Icons.star_outline_rounded,
        label: 'review_rate'.tr(),
        color: const Color(0xFFFF6F00),
        bg: const Color(0xFFFFF3E0),
        onTap: () => Navigator.push(context, _fadeRoute(ReviewAndRatePage())),
      ),
      _MenuItemData(
        icon: Icons.language_rounded,
        label: 'language'.tr(),
        color: const Color(0xFF00897B),
        bg: const Color(0xFFE0F2F1),
        onTap: () => _showLanguageSheet(context),
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: kPrimaryColor.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: menuItems.asMap().entries.map((e) {
          final isLast = e.key == menuItems.length - 1;
          return _buildMenuTile(e.value, showDivider: !isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuTile(_MenuItemData item, {bool showDivider = true}) {
    return _MenuTile(item: item, showDivider: showDivider);
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: kCreamLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const Text("Choose Language",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kPrimaryColor)),
            const SizedBox(height: 16),
            _langTile(context, "English", "EN", const Locale('en')),
            _langTile(context, "Hindi", "HI", const Locale('hi')),
            _langTile(context, "Telugu", "TE", const Locale('te')),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _langTile(BuildContext context, String name, String code, Locale locale) {
    final isCurrent = context.locale == locale;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isCurrent ? kAccentColor.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? kAccentDark : Colors.grey.shade200,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: () { context.setLocale(locale); Navigator.pop(context); },
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isCurrent ? kAccentColor : kCreamColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(code,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                  color: isCurrent ? Colors.white : kPrimaryColor))),
        ),
        title: Text(name, style: TextStyle(
            fontWeight: FontWeight.w700, color: isCurrent ? kAccentDark : kTextPrimary)),
        trailing: isCurrent
            ? const Icon(Icons.check_circle_rounded, color: kAccentDark, size: 20)
            : null,
      ),
    );
  }
}

// ─── Stat tile ────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  const _StatTile({required this.icon, required this.iconColor,
      required this.iconBg, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      const SizedBox(height: 8),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(value, style: const TextStyle(
            fontWeight: FontWeight.w800, fontSize: 15, color: kTextPrimary)),
      ),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 11, color: kTextSecondary, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center),
    ]);
  }
}

// ─── Menu item data ───────────────────────────────────────────────
class _MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _MenuItemData({required this.icon, required this.label,
      required this.color, required this.bg, required this.onTap});
}

// ─── Menu tile with hover ─────────────────────────────────────────
class _MenuTile extends StatefulWidget {
  final _MenuItemData item;
  final bool showDivider;
  const _MenuTile({required this.item, this.showDivider = true});

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: _hovered ? widget.item.bg.withOpacity(0.4) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _hovered ? widget.item.bg : kCreamColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.item.icon,
                        color: _hovered ? widget.item.color : kPrimaryColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(widget.item.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15,
                          color: _hovered ? widget.item.color : kTextPrimary,
                        )),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: _hovered ? widget.item.color : kTextHint),
                  ),
                ]),
              ),
              if (widget.showDivider)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1, color: kTextHint.withOpacity(0.2)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Desktop edit button ──────────────────────────────────────────
class _DesktopEditButton extends StatefulWidget {
  final VoidCallback onTap;
  const _DesktopEditButton({required this.onTap});

  @override
  State<_DesktopEditButton> createState() => _DesktopEditButtonState();
}

class _DesktopEditButtonState extends State<_DesktopEditButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? kAccentColor : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.edit_rounded, size: 16,
                color: _hovered ? kPrimaryColor : Colors.white),
            const SizedBox(width: 8),
            Text("Edit Profile", style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: _hovered ? kPrimaryColor : Colors.white,
            )),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EDIT SHEET — unchanged logic, premium UI
// ═══════════════════════════════════════════════════════════════════
class _GranularEditSheet extends StatefulWidget {
  final Map<String, dynamic> userData;
  final User user;
  final Function(String)? onSuccess;
  const _GranularEditSheet({required this.userData, required this.user, this.onSuccess});

  @override
  State<_GranularEditSheet> createState() => _GranularEditSheetState();
}

class _GranularEditSheetState extends State<_GranularEditSheet> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  final FocusNode nameNode  = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode emailNode = FocusNode();

  bool isNameLoading  = false;
  bool isPhoneLoading = false;
  bool isEmailLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late String originalName;
  late String originalPhone;
  late String originalEmail;

  final phoneRegex = RegExp(r'^[0-9]{10}$');
  final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  String? phoneError;
  String? emailError;

  @override
  void initState() {
    super.initState();
    nameController    = TextEditingController(text: widget.userData['name'] ?? '');
    phoneController   = TextEditingController(text: widget.userData['phone'] ?? '');
    emailController   = TextEditingController(text: widget.userData['email'] ?? '');
    passwordController        = TextEditingController();
    confirmPasswordController = TextEditingController();

    nameController.addListener(() => setState(() {}));
    phoneController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));

    originalName  = nameController.text;
    originalPhone = phoneController.text;
    originalEmail = emailController.text;
  }

  @override
  void dispose() {
    nameController.dispose(); phoneController.dispose(); emailController.dispose();
    passwordController.dispose(); confirmPasswordController.dispose();
    nameNode.dispose(); phoneNode.dispose(); emailNode.dispose();
    super.dispose();
  }

  void _validatePhone(String val) => setState(() {
    if (val.isEmpty) phoneError = null;
    else if (!phoneRegex.hasMatch(val.trim())) phoneError = "Enter 10 digits";
    else phoneError = null;
  });

  void _validateEmail(String val) => setState(() {
    if (val.isEmpty) emailError = null;
    else if (!emailRegex.hasMatch(val.trim())) emailError = "Invalid email";
    else emailError = null;
  });

  void _showToast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? kRedColor : kAccentDark,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.8,
        left: 20, right: 20,
      ),
      dismissDirection: DismissDirection.up,
    ));
  }

  Future<void> _updateName() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty || newName == originalName) return;
    setState(() => isNameLoading = true);
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-south1').httpsCallable('updateUserProfile');
      await callable.call({'name': newName});
      if (mounted) {
        setState(() { originalName = newName; isNameLoading = false; });
        FocusScope.of(context).unfocus();
        Navigator.pop(context);
        widget.onSuccess?.call("Name updated successfully!");
      }
    } catch (e) {
      if (mounted) setState(() => isNameLoading = false);
      _showToast("Update Failed: ${e.toString()}", isError: true);
    }
  }

 Future<void> _verifyAndUpdatePhone() async {
  final newPhone = phoneController.text.trim();

  if (phoneError != null || newPhone.isEmpty || isPhoneLoading) return;

  setState(() => isPhoneLoading = true);

  try {
    // WEB / PWA
    if (kIsWeb) {
      final ConfirmationResult confirmationResult =
          await FirebaseAuth.instance.signInWithPhoneNumber(
        "+91$newPhone",
      );

      if (mounted) {
        setState(() => isPhoneLoading = false);
      }

      _showWebOtpDialog(
        confirmationResult,
        newPhone,
      );

      return;
    }

    // ANDROID / IOS
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91$newPhone",

      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await widget.user.updatePhoneNumber(credential);

          await _updateCloudProfile(
            phone: newPhone,
          );

          if (mounted) {
            setState(() => isPhoneLoading = false);
          }

          widget.onSuccess?.call("Phone Verified & Updated!");
        } catch (e) {
          if (mounted) {
            setState(() => isPhoneLoading = false);
          }

          _showToast(
            e.toString(),
            isError: true,
          );
        }
      },

      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() => isPhoneLoading = false);
        }

        _showToast(
          "Verification Failed: ${e.message}",
          isError: true,
        );
      },

      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() => isPhoneLoading = false);
        }

        _showOtpDialog(
          verificationId,
          newPhone,
        );
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) {
          setState(() => isPhoneLoading = false);
        }
      },
    );
  } catch (e) {
    if (mounted) {
      setState(() => isPhoneLoading = false);
    }

    _showToast(
      e.toString(),
      isError: true,
    );
  }
}

void _showOtpDialog(
  String verificationId,
  String newPhone,
) {
  final TextEditingController otpController =
      TextEditingController();

  bool isVerifying = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Verify Phone",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: kPrimaryColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter code sent to +91 $newPhone",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryColor,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: kCreamLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (isVerifying)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(
                      color: kAccentColor,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: kTextSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isVerifying
                    ? null
                    : () async {
                        setDialogState(
                          () => isVerifying = true,
                        );

                        try {
                          final PhoneAuthCredential credential =
                              PhoneAuthProvider.credential(
                            verificationId: verificationId,
                            smsCode:
                                otpController.text.trim(),
                          );

                          await widget.user.updatePhoneNumber(
                            credential,
                          );

                          await _updateCloudProfile(
                            phone: newPhone,
                          );

                          if (mounted) {
                            Navigator.pop(dialogContext);

                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }

                            widget.onSuccess?.call(
                              "Phone Verified & Updated!",
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          setDialogState(
                            () => isVerifying = false,
                          );

                          if (e.code ==
                              'credential-already-in-use') {
                            _showToast(
                              "Number already in use by another account.",
                              isError: true,
                            );
                          } else {
                            _showToast(
                              "Error: ${e.message}",
                              isError: true,
                            );
                          }
                        } catch (e) {
                          setDialogState(
                            () => isVerifying = false,
                          );

                          _showToast(
                            "Error: $e",
                            isError: true,
                          );
                        }
                      },
                child: const Text(
                  "Verify",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showWebOtpDialog(
  ConfirmationResult confirmationResult,
  String newPhone,
) {
  final TextEditingController otpController =
      TextEditingController();

  bool isVerifying = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Verify Phone",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: kPrimaryColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter code sent to +91 $newPhone",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryColor,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: kCreamLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (isVerifying)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(
                      color: kAccentColor,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: kTextSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isVerifying
                    ? null
                    : () async {
                        setDialogState(
                          () => isVerifying = true,
                        );

                        try {
                          await confirmationResult.confirm(
                            otpController.text.trim(),
                          );

                          await _updateCloudProfile(
                            phone: newPhone,
                          );

                          if (mounted) {
                            Navigator.pop(dialogContext);

                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }

                            widget.onSuccess?.call(
                              "Phone Verified & Updated!",
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          setDialogState(
                            () => isVerifying = false,
                          );

                          _showToast(
                            e.message ?? "Verification failed",
                            isError: true,
                          );
                        } catch (e) {
                          setDialogState(
                            () => isVerifying = false,
                          );

                          _showToast(
                            e.toString(),
                            isError: true,
                          );
                        }
                      },
                child: const Text(
                  "Verify",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> _verifyAndUpdateEmail() async {
    final newEmail = emailController.text.trim();
    if (emailError != null || newEmail.isEmpty || isEmailLoading) return;
    setState(() => isEmailLoading = true);
    try {
      bool hasPasswordProvider = widget.user.providerData.any((i) => i.providerId == 'password');
      if (!hasPasswordProvider) {
        final password = passwordController.text;
        AuthCredential credential = EmailAuthProvider.credential(email: newEmail, password: password);
        await widget.user.linkWithCredential(credential);
        await widget.user.sendEmailVerification();
        if (mounted) {
          setState(() { originalEmail = newEmail; isEmailLoading = false;
            passwordController.clear(); confirmPasswordController.clear(); });
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
          widget.onSuccess?.call("Account upgraded! Verification email sent.");
        }
      } else {
        await widget.user.verifyBeforeUpdateEmail(newEmail);
        if (mounted) {
          setState(() { originalEmail = newEmail; isEmailLoading = false; });
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
          widget.onSuccess?.call("Verification email sent! Link expires in 1 hour.");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => isEmailLoading = false);
      if (e.code == 'requires-recent-login') {
        _showToast("Please log out and log back in to verify a new email.", isError: true);
      } else {
        _showToast("Error: ${e.message}", isError: true);
      }
    } catch (e) {
      if (mounted) setState(() => isEmailLoading = false);
      _showToast("Error: ${e.toString()}", isError: true);
    }
  }

  Future<void> _updateCloudProfile({String? phone, String? email}) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-south1').httpsCallable('updateUserProfile');
      final Map<String, dynamic> payload = {};
      if (phone != null) payload['phone'] = phone;
      if (email != null) payload['email'] = email;
      await callable.call(payload);
    } catch (e) {
      _showToast("Cloud sync failed. Profile might update late.", isError: true);
    }
  }

  bool _isPasswordValid(String p) =>
      p.length >= 8 && RegExp(r'[A-Z]').hasMatch(p) &&
      RegExp(r'[0-9]').hasMatch(p) && RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(p);

  Widget _buildPasswordRequirements(String password) {
    bool l = password.length >= 8;
    bool u = RegExp(r'[A-Z]').hasMatch(password);
    bool n = RegExp(r'[0-9]').hasMatch(password);
    bool s = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    Widget row(String t, bool met) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 15, color: met ? Colors.green : Colors.grey),
        const SizedBox(width: 7),
        Text(t, style: TextStyle(fontSize: 12, color: met ? Colors.green.shade800 : Colors.grey.shade600)),
      ]),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        row("At least 8 characters", l),
        row("At least one Uppercase letter (A-Z)", u),
        row("At least one Number (0-9)", n),
        row("At least one Special Character (!@#...)", s),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isGoogle = widget.user.providerData.any((i) => i.providerId == 'google.com');
    bool hasPasswordProvider = widget.user.providerData.any((i) => i.providerId == 'password');

    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: kCreamLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            )),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Edit Profile',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: kPrimaryColor)),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: kTextSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
            const SizedBox(height: 20),

            _buildGranularField(
              label: "Full Name", controller: nameController, node: nameNode,
              icon: Icons.person_outline_rounded, isLoading: isNameLoading,
              isChanged: nameController.text.trim() != originalName,
              btnText: "Save", onAction: _updateName,
            ),
            _buildGranularField(
              label: "Phone Number", controller: phoneController, node: phoneNode,
              icon: Icons.phone_outlined, isLoading: isPhoneLoading,
              isChanged: phoneController.text.trim() != originalPhone,
              btnText: "Verify", onAction: _verifyAndUpdatePhone,
              inputType: TextInputType.phone,
              errorText: phoneError, onChanged: _validatePhone,
            ),

            if (!hasPasswordProvider && !isGoogle)
              _buildEmailUpgradeSection()
            else
              _buildGranularField(
                label: "Email Address", controller: emailController, node: emailNode,
                icon: Icons.email_outlined, isLoading: isEmailLoading,
                isChanged: emailController.text.trim() != originalEmail,
                btnText: "Verify", onAction: _verifyAndUpdateEmail,
                isLocked: isGoogle,
                helperText: isGoogle ? "Managed by Google Account" : "Link expires in 1 hour",
                errorText: emailError, onChanged: _validateEmail,
                inputType: TextInputType.emailAddress,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailUpgradeSection() {
    bool isPassValid = _isPasswordValid(passwordController.text);
    bool isMatch     = passwordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;
    bool isEmailValid = emailController.text.isNotEmpty && emailError == null;
    bool isChanged    = emailController.text.trim() != originalEmail;
    bool isDisabled   = isEmailLoading || !isEmailValid || !isPassValid || !isMatch || !isChanged;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Link Email Address",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kPrimaryColor)),
        const SizedBox(height: 4),
        const Text("Since you signed in with a phone number, create a password to log in with this email.",
            style: TextStyle(fontSize: 12, color: kTextSecondary)),
        const SizedBox(height: 16),

        _styledTextField(
          controller: emailController, focusNode: emailNode,
          hint: "Enter Email", icon: Icons.email_outlined,
          inputType: TextInputType.emailAddress,
          hasError: emailError != null, onChanged: _validateEmail,
        ),
        if (emailError != null)
          _errorText(emailError!),

        const SizedBox(height: 12),

        _styledTextField(
          controller: passwordController, hint: "Create Password",
          icon: Icons.lock_outline_rounded, obscure: !_isPasswordVisible,
          suffix: IconButton(
            icon: Icon(_isPasswordVisible
                ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: kAccentDark, size: 20),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
        ),
        if (passwordController.text.isNotEmpty)
          _buildPasswordRequirements(passwordController.text),

        const SizedBox(height: 12),

        _styledTextField(
          controller: confirmPasswordController, hint: "Confirm Password",
          icon: Icons.lock_outline_rounded, obscure: !_isConfirmPasswordVisible,
          suffix: IconButton(
            icon: Icon(_isConfirmPasswordVisible
                ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: kAccentDark, size: 20),
            onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
          ),
        ),
        if (confirmPasswordController.text.isNotEmpty &&
            confirmPasswordController.text != passwordController.text)
          _errorText("Passwords do not match"),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: isDisabled ? null : _verifyAndUpdateEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentColor,
              disabledBackgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: isEmailLoading
                ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text("Link & Verify Email", style: TextStyle(
                    color: isDisabled ? Colors.grey.shade500 : kPrimaryColor,
                    fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ]),
    );
  }

  Widget _styledTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType inputType = TextInputType.text,
    bool hasError = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: inputType,
      obscureText: obscure,
      onChanged: onChanged,
      style: const TextStyle(fontWeight: FontWeight.w600, color: kPrimaryColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextHint, fontWeight: FontWeight.w400),
        prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
        suffixIcon: suffix,
        filled: true, fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: hasError ? kRedColor.withOpacity(0.5) : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: hasError ? kRedColor : kPrimaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _errorText(String msg) => Padding(
    padding: const EdgeInsets.only(top: 6, left: 4),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, size: 13, color: kRedColor),
      const SizedBox(width: 5),
      Text(msg, style: const TextStyle(fontSize: 12, color: kRedColor, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _buildGranularField({
    required String label,
    required TextEditingController controller,
    required FocusNode node,
    required IconData icon,
    required VoidCallback onAction,
    required bool isChanged,
    required bool isLoading,
    required String btnText,
    String? errorText,
    bool isLocked = false,
    TextInputType inputType = TextInputType.text,
    String? helperText,
    Function(String)? onChanged,
  }) {
    bool isDisabled = isLoading || errorText != null || !isChanged || isLocked;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kPrimaryColor)),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: TextField(
              controller: controller, focusNode: node,
              readOnly: isLocked, keyboardType: inputType,
              onChanged: (val) { if (onChanged != null) onChanged(val); },
              style: const TextStyle(fontWeight: FontWeight.w600, color: kPrimaryColor),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: isLocked ? kTextHint : kPrimaryColor, size: 20),
                filled: true,
                fillColor: isLocked ? Colors.grey.shade100 : Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: errorText != null
                      ? kRedColor.withOpacity(0.5) : Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: errorText != null ? kRedColor : kPrimaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
          ),
          if (!isLocked) ...[
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isDisabled ? null : onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  disabledBackgroundColor: Colors.grey.shade200,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(btnText, style: TextStyle(
                        color: isDisabled ? Colors.grey.shade500 : kPrimaryColor,
                        fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
          ],
        ]),
        if (errorText != null) _errorText(errorText),
        if (helperText != null && errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 13, color: kTextSecondary),
              const SizedBox(width: 5),
              Text(helperText, style: TextStyle(fontSize: 12, color: kTextSecondary)),
            ]),
          ),
      ]),
    );
  }
}