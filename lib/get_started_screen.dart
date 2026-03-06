import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _contentCtrl;

  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late Animation<double> _blob3Anim;

  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    // Blob floating animation — loops forever
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _blob1Anim = Tween<double>(begin: 0.0, end: 18.0).animate(
      CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut),
    );
    _blob2Anim = Tween<double>(begin: 0.0, end: -14.0).animate(
      CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut),
    );
    _blob3Anim = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut),
    );

    // Content entrance animation
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _contentCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _contentCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _contentCtrl, curve: const Interval(0.25, 0.6, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _contentCtrl, curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic)),
    );

    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _contentCtrl, curve: const Interval(0.45, 0.75, curve: Curves.easeOut)),
    );

    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _contentCtrl, curve: const Interval(0.65, 1.0, curve: Curves.easeOut)),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _contentCtrl, curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic)),
    );

    // Start entrance after short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── GRADIENT BACKGROUND ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4A0080), // deep purple
                  Color(0xFF7B1FA2), // medium purple
                  Color(0xFFB22DBE), // bright purple
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── ANIMATED BLOBS ──
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) {
              return Stack(
                children: [
                  // Top-left blob
                  Positioned(
                    top: -80 + _blob1Anim.value,
                    left: -80,
                    child: _blob(280, Colors.white.withOpacity(0.08)),
                  ),
                  // Top-right blob
                  Positioned(
                    top: 60 + _blob2Anim.value,
                    right: -60,
                    child: _blob(220, Colors.white.withOpacity(0.06)),
                  ),
                  // Mid-left blob
                  Positioned(
                    top: size.height * 0.35 + _blob3Anim.value,
                    left: -100,
                    child: _blob(260, Colors.white.withOpacity(0.05)),
                  ),
                  // Bottom-right blob
                  Positioned(
                    bottom: -60 + _blob1Anim.value,
                    right: -80,
                    child: _blob(300, Colors.white.withOpacity(0.07)),
                  ),
                  // Bottom-left small blob
                  Positioned(
                    bottom: 120 + _blob2Anim.value,
                    left: -40,
                    child: _blob(180, Colors.white.withOpacity(0.06)),
                  ),
                  // Decorative ring top-right
                  Positioned(
                    top: 100,
                    right: 30,
                    child: _ring(120, Colors.white.withOpacity(0.08)),
                  ),
                  // Decorative ring bottom
                  Positioned(
                    bottom: 200,
                    left: 40,
                    child: _ring(80, Colors.white.withOpacity(0.06)),
                  ),
                ],
              );
            },
          ),

          // ── MAIN CONTENT ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── LOGO CIRCLE ──
                  FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: Column(
                        children: [
                          // Glow ring around logo
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.15),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/image/started.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.business_rounded,
                                    size: 70,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── TITLE ──
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Column(
                        children: [
                          Text(
                            "Visitor",
                            style: GoogleFonts.pacifico(
                              fontSize: 44,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            "Management",
                            style: GoogleFonts.pacifico(
                              fontSize: 34,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.1,
                            ),
                          ),
                          Text(
                            "System",
                            style: GoogleFonts.pacifico(
                              fontSize: 28,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── SUBTITLE ──
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Text(
                      "Secure, fast and easy visitor\nregistration for workplace.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.65),
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── FEATURE PILLS ──
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _featurePill(Icons.speed_rounded, "Fast"),
                        const SizedBox(width: 12),
                        _featurePill(Icons.shield_rounded, "Secure"),
                        const SizedBox(width: 12),
                        _featurePill(Icons.camera_alt_rounded, "Photo"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── GET STARTED BUTTON ──
                  FadeTransition(
                    opacity: _buttonFade,
                    child: SlideTransition(
                      position: _buttonSlide,
                      child: Column(
                        children: [
                          // Main button
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF7B1FA2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 8,
                                shadowColor: Colors.black38,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Get Started",
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Already have account
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            child: Text(
                              "Already have access? Sign In",
                              style: GoogleFonts.montserrat(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BLOB SHAPE ──
  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // ── RING SHAPE ──
  Widget _ring(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }

  // ── FEATURE PILL ──
  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}