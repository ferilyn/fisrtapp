import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraScreen({super.key, this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isInitialized = false;
  XFile? _capturedFile;
  int _countdown = 5;
  bool _isTimerRunning = false;
  Timer? _timer;

  // Pulse animation for countdown
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (widget.cameras != null && widget.cameras!.isNotEmpty) {
      _controller = CameraController(
        widget.cameras![0],
        ResolutionPreset.high,
      );
      try {
        await _controller!.initialize();
        if (mounted) setState(() => _isInitialized = true);
      } catch (e) {
        debugPrint("Camera Error: $e");
      }
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _countdown = 5;
      _capturedFile = null;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        _takePicture();
      }
    });
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final file = await _controller!.takePicture();
      setState(() {
        _capturedFile = file;
        _isTimerRunning = false;
      });
    }
  }

  Future<void> _handleComplete() async {
    if (_capturedFile != null) {
      final bytes = await _capturedFile!.readAsBytes();
      final String base64Image = base64Encode(bytes);
      if (!mounted) return;
      Navigator.pop(context, base64Image);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  // Countdown color based on value
  Color get _countdownColor {
    if (_countdown > 3) return const Color(0xFF4ECDB4); // teal
    if (_countdown > 1) return const Color(0xFFF4845F); // coral
    return const Color(0xFFFF4D6D);                     // red
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E0A24) : const Color(0xFFF3E8FF),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Capture Photo",
          style: GoogleFonts.pacifico(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFCB8CE6), Color(0xFFB22DBE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
        child: Column(
          children: [
            // ── STATUS PILL ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isTimerRunning
                  ? _statusPill(
                      "Get ready! Capturing in $_countdown...",
                      _countdownColor,
                      Icons.timer_rounded,
                    )
                  : _capturedFile != null
                      ? _statusPill(
                          "Photo captured! Looking good?",
                          const Color(0xFF72C472),
                          Icons.check_circle_rounded,
                        )
                      : _statusPill(
                          "Position yourself in the frame",
                          const Color(0xFF5B8FF9),
                          Icons.info_rounded,
                        ),
            ),
            const SizedBox(height: 16),

            // ── CAMERA / PREVIEW BOX ──
            Container(
              height: 420,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB22DBE).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: _isTimerRunning
                      ? _countdownColor
                      : const Color(0xFFB22DBE).withOpacity(0.5),
                  width: _isTimerRunning ? 3 : 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    // Camera / preview
                    _capturedFile != null
                        ? Image.file(
                            File(_capturedFile!.path),
                            fit: BoxFit.cover,
                          )
                        : _isInitialized
                            ? CameraPreview(_controller!)
                            : Container(
                                color: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(
                                      color: Color(0xFFB22DBE),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Initializing camera...",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                    // Face guide overlay (only when live)
                    if (_capturedFile == null && _isInitialized)
                      Center(
                        child: Container(
                          width: 200,
                          height: 240,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(120),
                          ),
                        ),
                      ),

                    // Countdown overlay
                    if (_isTimerRunning)
                      Container(
                        color: Colors.black.withOpacity(0.35),
                        child: Center(
                          child: ScaleTransition(
                            scale: _pulseAnim,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _countdownColor.withOpacity(0.15),
                                border: Border.all(
                                  color: _countdownColor,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$_countdown',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w900,
                                    color: _countdownColor,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 20,
                                        color: Colors.black45,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // "Captured!" flash overlay
                    if (_capturedFile != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF72C472), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "Photo Captured",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── BUTTONS ──
            if (_capturedFile == null) ...[
              // START TIMER button
              _primaryButton(
                label: _isTimerRunning
                    ? "CAPTURING IN $_countdown..."
                    : "START 5s TIMER",
                icon: _isTimerRunning
                    ? Icons.hourglass_top_rounded
                    : Icons.timer_rounded,
                color: const Color(0xFFB22DBE),
                onPressed: _isTimerRunning ? null : _startTimer,
              ),
            ] else ...[
              // USE THIS PHOTO
              _primaryButton(
                label: "USE THIS PHOTO",
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF72C472),
                onPressed: _handleComplete,
              ),
              const SizedBox(height: 12),
              // RETAKE
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _capturedFile = null),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    "RETAKE PHOTO",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFFB22DBE), width: 2),
                    foregroundColor: const Color(0xFFB22DBE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Tip text
            Text(
              _capturedFile != null
                  ? "Make sure your face is clearly visible"
                  : "Tap the button and look at the camera",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STATUS PILL ──
  Widget _statusPill(String text, Color color, IconData icon) {
    return Container(
      key: ValueKey(text),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.montserrat(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── PRIMARY BUTTON ──
  Widget _primaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: Colors.white),
        label: Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? color.withOpacity(0.5)
              : color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: onPressed == null ? 0 : 6,
          shadowColor: color.withOpacity(0.5),
        ),
      ),
    );
  }
}