import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revive_eco_tech_app/pricelist.dart';
import 'package:revive_eco_tech_app/setting.dart';
import 'package:revive_eco_tech_app/profile.dart';
import 'widgets/pickup_tracker.dart';


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

class _HomePageState extends State<HomePage> {
  String selectedLocation = 'Barrackpore, Kolkata';

  final List<String> locations = [
    'Barrackpore, Kolkata',
    'Salt Lake, Kolkata',
    'Howrah',
    'New Town',
  ];

  void _changeLocation() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: locations.map((location) => ListTile(
          title: Text(location),
          onTap: () {
            setState(() => selectedLocation = location);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  Widget upcomingCard(String label, String assetPath) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(assetPath, height: 200, width: 200, fit: BoxFit.cover),
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
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              child: Image.asset(iconAssetPath, width: 60, height: 60, fit: BoxFit.cover),
            ),
            //Image.asset(iconAssetPath, width: 60, height: 60),
            const SizedBox(width: 16),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Adjust alignment for better positioning
                  children: [
                    Text("$times", style: const TextStyle(color: kAccentColor, fontSize: 23, fontWeight: FontWeight.bold)),
                    Text("Times", style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                  ],
                ),
                const SizedBox(width: 40), // Adds space between the columns
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$kg", style: const TextStyle(color: kAccentColor, fontSize: 23, fontWeight: FontWeight.bold)),
                    Text("in kg", style: TextStyle(color: Colors.grey[800], fontSize: 14)), // Modified label to match left-side format
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
      child: Image.asset(path, fit: BoxFit.cover, width: double.infinity),
    );
  }
  int _CurrentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kPrimaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kCreamColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ==== Header ====
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
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
                              );
                            },
                            child: const CircleAvatar(
                              radius: 23,
                              backgroundColor: Color(0xFFa8ce4c),
                              child: Icon(Icons.account_circle, color: kPrimaryColor, size: 45),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center, // This helps!
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 23.0), // Adjust this value to move text downward
                                child: Row(
                                  children: const [
                                    Text(
                                      'Hello, Shubham ',
                                      style: TextStyle(
                                        fontSize: 21,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '!',
                                      style: TextStyle(
                                        fontSize: 21,
                                        color: kAccentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: kAccentColor, size: 18),
                                  SizedBox(width: 4),
                                  Text(selectedLocation,
                                      style: const TextStyle(fontSize: 14, color: Colors.white)),
                                  IconButton(
                                    icon: const Icon(Icons.keyboard_arrow_down, color: kAccentColor),
                                    onPressed: _changeLocation,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
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
                      child: Icon(Icons.notifications, color: kAccentColor, size: 30),
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
                      BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 13)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      StatCard(icon: Icons.recycling, label: '0 kg', sub: 'Total Recycled'),
                      StatCard(icon: Icons.cloud, label: '0 m³', sub: 'Saved CO₂'),
                      StatCard(icon: Icons.currency_rupee, label: '₹0', sub: 'Total Earnings'),
                    ],
                  ),
                ),
              ),

              // ==== Scrollable Cards ====
              ImageCardScroller(children: [
                buildCroppedAssetCard("assets/images/home/14.png", 0, 0),
                buildCroppedAssetCard("assets/images/home/14.png", 0, 0),
                buildCroppedAssetCard("assets/images/home/14.png", 0, 0),
              ]),

            const SizedBox(height: 8),

            PickupTracker(currentStep: 2),

            const SizedBox(height: 8),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 0, left: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft, // Aligns text to the left
                    child: Text(
                      'Shortcuts',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                ),
              ),

              // ==== Shortcuts Grid ====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  child: GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ShortcutButton(
                        icon: Icons.list,
                        label: 'Price List \n',
                        onTap: () {
                          //Navigator.push(context, MaterialPageRoute(builder: (_) => PriceListPage()));
                        },
                      ),
                      ShortcutButton(
                        icon: Icons.schedule,
                        label: 'Schedule \n Pick-up',
                        onTap: () {
                          //Navigator.push(context, MaterialPageRoute(builder: (_) => SchedulePickupPage()));
                        },
                      ),
                      ShortcutButton(
                        icon: Icons.track_changes,
                        label: 'Live \n Tracking',
                        onTap: () {
                          //Navigator.push(context, MaterialPageRoute(builder: (_) => LiveTrackingPage()));
                        },
                      ),
                      ShortcutButton(
                        icon: Icons.campaign,
                        label: 'Society \n Campaign',
                        onTap: () {
                          //Navigator.push(context, MaterialPageRoute(builder: (_) => SocietyCampaignPage()));
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
                    // --- Upcoming Drives ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Keeps them centered instead of stretching
                      children: const [
                        Text("Upcoming Drives", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(width: 180), // Adjust this value to control the gap
                        Text("View all", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200, // Adjust height based on card size
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cardList.length, // List of card details
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: upcomingCard(cardList[index].title, cardList[index].image),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- Most Recycled Scraps ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Most Recycled Scraps", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("View all", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    scrapCard("Metal", "10", "90", "assets/images/home/scraps/metal.png"),
                    scrapCard("Bottle", "05", "35", "assets/images/home/scraps/bottle.png"),
                    scrapCard("Newspaper", "00", "80", "assets/images/home/scraps/newspaper.png"),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ==== Bottom Nav ====

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: kGreenLight,
          currentIndex: _CurrentIndex,
          onTap: (index) {
            if (index == 1) { // If "Market Rates" is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => pricelist()),
              );
            }
            if (index == 2) { // If "Market Rates" is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            }else {
              setState(() {
                _CurrentIndex = index;
              });
            }
          },

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.graphic_eq), label: 'Market Rates'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

// ==== Reusable Components ====

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const StatCard({required this.icon, required this.label, required this.sub, super.key});

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
  final VoidCallback? onTap; // allow nullable for flexibility

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
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class CardItem {
  final String title;
  final String image;

  CardItem(this.title, this.image);
}

List<CardItem> cardList = [
  CardItem("Know more", "assets/images/home/drives/plastic.png"),
  CardItem("Know more", "assets/images/home/drives/recycle.png"),
  // Add more CardItem objects here...
];


class UnevenCropClipper extends CustomClipper<Rect> {
  final double topTrim;
  final double bottomTrim;
  UnevenCropClipper({required this.topTrim, required this.bottomTrim});

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, topTrim, size.width, size.height - bottomTrim);

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
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;


  @override
  Widget build(BuildContext context) {
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
                color: _currentIndex == index ? const Color(0xFFa8ce4c) : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
