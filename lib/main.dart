import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models.dart';
import 'information_form.dart';
import 'api_service.dart';
import 'login_screen.dart';
import 'get_started_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Camera Error: $e");
  }

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Visitor Management System',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F0FF),
        textTheme: GoogleFonts.montserratTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF3A0A3F),
        textTheme: GoogleFonts.montserratTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      initialRoute: '/start',
      routes: {
        '/start': (context) => const GetStartedScreen(),
        '/': (context) => const LoginScreen(),
        '/home': (context) => MyHomePage(
              cameras: widget.cameras,
              onThemeChanged: toggleTheme,
              currentTheme: _themeMode,
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(bool) onThemeChanged;
  final ThemeMode currentTheme;

  const MyHomePage({
    super.key,
    required this.cameras,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<PersonRecord> _allLogs = [];
  final ApiService apiService = ApiService();

  // ── HELPER TO BUILD IMAGE FROM SERVER ──
  Widget buildVisitorImage(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, color: Colors.white),
      );
    }

    // This URL matches your published API static files folder
    final String imageUrl = "http://172.16.40.215:8080/images/$fileName";

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        // Shows a placeholder if the server is unreachable or file is missing
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50,
            height: 50,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 20),
          );
        },
      ),
    );
  }

  void _openForm(String category) async {
    final PersonRecord? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InformationFormScreen(
          categoryTitle: category,
          cameras: widget.cameras,
        ),
      ),
    );

    if (result != null) {
      setState(() => _allLogs.insert(0, result)); // Add to top of list
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: curved.value,
          child: Opacity(
            opacity: animation.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Confirm Logout", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
              content: Text("Are you sure you want to logout?", style: GoogleFonts.montserrat()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text("Logout", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.currentTheme == ThemeMode.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 120,
        leading: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.light_mode_rounded, color: Colors.white, size: 17),
            Transform.scale(
              scale: 0.7,
              child: Switch(
                value: isDark,
                onChanged: widget.onThemeChanged,
                activeColor: Colors.white,
                activeTrackColor: Colors.white24,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white24,
              ),
            ),
            const Icon(Icons.dark_mode_rounded, color: Colors.white, size: 17),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Visitor Registration", style: GoogleFonts.pacifico(fontSize: 20, color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFCB8CE6), Color(0xFFB22DBE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Total: ${_allLogs.length}",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(18, 110, 18, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Please select a category:", style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _CategoryGrid(onSelect: _openForm),
              
              const SizedBox(height: 32),

              // ── NEW: RECENT REGISTRATIONS LIST ──
              if (_allLogs.isNotEmpty) ...[
                Text("Recent Registrations:", style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allLogs.length,
                  itemBuilder: (context, index) {
                    final log = _allLogs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: buildVisitorImage(log.imageBase64), // FETCHES FROM SERVER
                        title: Text(log.fullName, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                        subtitle: Text("${log.company} • ${log.purpose}"),
                        trailing: const Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _showLogoutDialog,
                    icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                    label: Text("Logout", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CATEGORY GRID & ANIMATED CARD CLASSES REMAIN THE SAME AS YOUR PROVIDED CODE ──
class _CategoryGrid extends StatelessWidget {
  final void Function(String) onSelect;
  const _CategoryGrid({required this.onSelect});

  static const _items = [
    _CategoryItem(title: 'A VISITOR', icon: Icons.person_pin_rounded, color: Color(0xFF9E9E9E)),
    _CategoryItem(title: 'A JOB CANDIDATE', icon: Icons.person_search_rounded, color: Color(0xFF4ECDB4)),
    _CategoryItem(title: 'O.J.T.', icon: Icons.school_rounded, color: Color(0xFFF4845F)),
    _CategoryItem(title: 'MAINTENANCE', icon: Icons.build_rounded, color: Color(0xFF5B8FF9)),
    _CategoryItem(title: 'SUPPLIER DELIVERY', icon: Icons.local_shipping_rounded, color: Color(0xFF72C472)),
    _CategoryItem(title: 'SUPPLIER COLLECTION', icon: Icons.shopping_basket_rounded, color: Color(0xFFBF7AF0)),
  ];

  @override
  Widget build(BuildContext context) {
    final double cardWidth = (MediaQuery.of(context).size.width - 36 - 13) / 2;
    final List<Widget> rows = [];

    for (int i = 0; i < _items.length; i += 2) {
      if (i + 1 >= _items.length) {
        rows.add(Center(child: SizedBox(width: cardWidth, child: _AnimatedCard(item: _items[i], delay: Duration(milliseconds: 60 + i * 70), onTap: () => onSelect(_items[i].title)))));
      } else {
        rows.add(Row(children: [
          Expanded(child: _AnimatedCard(item: _items[i], delay: Duration(milliseconds: 60 + i * 70), onTap: () => onSelect(_items[i].title))),
          const SizedBox(width: 13),
          Expanded(child: _AnimatedCard(item: _items[i + 1], delay: Duration(milliseconds: 60 + (i + 1) * 70), onTap: () => onSelect(_items[i + 1].title))),
        ]));
      }
      if (i + 2 < _items.length) rows.add(const SizedBox(height: 13));
    }
    return Column(children: rows);
  }
}

class _AnimatedCard extends StatefulWidget {
  final _CategoryItem item;
  final Duration delay;
  final VoidCallback onTap;
  const _AnimatedCard({required this.item, required this.delay, required this.onTap});
  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: SlideTransition(position: _slide, child: GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 120), curve: Curves.easeOut, child: _CardFace(item: widget.item)),
    )));
  }
}

class _CardFace extends StatelessWidget {
  final _CategoryItem item;
  const _CardFace({required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
      decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: item.color.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(top: -18, right: -18, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)))),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 66, height: 66, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.28)), child: Icon(item.icon, color: Colors.white, size: 30)),
          const SizedBox(height: 12),
          Text(item.title, textAlign: TextAlign.center, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6, height: 1.3)),
        ]),
      ]),
    );
  }
}

class _CategoryItem {
  final String title;
  final IconData icon;
  final Color color;
  const _CategoryItem({required this.title, required this.icon, required this.color});
}