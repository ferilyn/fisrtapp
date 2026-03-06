import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models.dart';
import 'camera_screen.dart';
import 'api_service.dart';

class InformationFormScreen extends StatefulWidget {
  final String categoryTitle;
  final List<CameraDescription> cameras;

  const InformationFormScreen({
    super.key,
    required this.categoryTitle,
    required this.cameras,
  });

  @override
  State<InformationFormScreen> createState() => _InformationFormScreenState();
}

class _InformationFormScreenState extends State<InformationFormScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  String _selectedDepartment = 'Admin';
  bool _isSubmitting = false;
  int _currentPage = 0;

  static const Map<String, Color> _categoryColors = {
    'A VISITOR': Color(0xFF9E9E9E),
    'A JOB CANDIDATE': Color(0xFF4ECDB4),
    'O.J.T.': Color(0xFFF4845F),
    'MAINTENANCE': Color(0xFF5B8FF9),
    'SUPPLIER DELIVERY': Color(0xFF72C472),
    'SUPPLIER COLLECTION': Color(0xFFBF7AF0),
  };

  Color get _accentColor =>
      _categoryColors[widget.categoryTitle] ?? const Color(0xFFB22DBE);

  final List<String> _departments = [
    'Admin', 'ARTECY', 'Barcode', 'Business Dev', 'CPD', 'Documentation',
    'Executives', 'Finance', 'HRD', 'ICT', 'Inventory', 'Logistic',
    'Operation', 'Pattern', 'Payables', 'Payroll', 'PNP', 'PSA',
    'Purchasing', 'RDM', 'Receivables', 'Receiving', 'Sales & Audit',
    'Sales & Marketing', 'Treasury', 'Warehouse'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _contactPersonController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _handleFinalSubmit() async {
    if (_formKey2.currentState!.validate()) {
      final dynamic result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(cameras: widget.cameras),
        ),
      );

      if (result != null && result is String && mounted) {
        setState(() => _isSubmitting = true);

        final record = PersonRecord(
          fullName: _nameController.text.trim(),
          company: _companyController.text.trim(),
          contact: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          department: _selectedDepartment,
          contactPerson: _contactPersonController.text.trim(),
          purpose: _purposeController.text.trim(),
          category: widget.categoryTitle,
          dateSignIn: DateTime.now().toIso8601String(),
          imageBase64: result,
        );

        bool success = await _apiService.saveVisitor(record);

        if (mounted) {
          setState(() => _isSubmitting = false);
          if (success) {
            _showSuccessDialog();
          } else {
            _showErrorSnackBar("Submission failed. Check API connection.");
          }
        }
      } else if (result == null) {
        _showErrorSnackBar("Photo capture cancelled.");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, animation, _, __) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: curved.value,
          child: Opacity(
            opacity: animation.value,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CheckmarkWidget(color: _accentColor),
                    const SizedBox(height: 24),
                    Text(
                      "Registration\nSuccessful!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Visitor has been logged in.",
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "DONE",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepDot(0, "Personal"),
        _stepLine(),
        _stepDot(1, "Visit"),
      ],
    );
  }

  Widget _stepDot(int step, String label) {
    final bool active = _currentPage == step;
    final bool done = _currentPage > step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (active || done) ? _accentColor : Colors.grey.shade300,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                    "${step + 1}",
                    style: GoogleFonts.montserrat(
                      color: (active || done) ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: (active || done) ? _accentColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _stepLine() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: _currentPage > 0 ? _accentColor : Colors.grey.shade300,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                widget.categoryTitle,
                style: GoogleFonts.pacifico(fontSize: 18, color: Colors.white),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accentColor.withOpacity(0.85), const Color(0xFFB22DBE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: _buildStepIndicator(),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    children: [
                      _buildPersonalPage(),
                      _buildVisitPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isSubmitting) _BouncingDotsOverlay(),
        ],
      ),
    );
  }

  Widget _buildPersonalPage() {
    final bool isOJT = widget.categoryTitle == 'O.J.T.';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      child: Form(
        key: _formKey1,
        child: Column(
          children: [
            _sectionCard(
              title: "Personal Information",
              icon: Icons.person_rounded,
              children: [
                _buildInputField(
                  controller: _nameController,
                  label: "Full Name",
                  icon: Icons.badge_rounded,
                  minLength: 3,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  controller: _companyController,
                  label: isOJT ? "School Name" : "Company Name",
                  icon: isOJT ? Icons.school_rounded : Icons.business_rounded,
                  minLength: 2,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  controller: _phoneController,
                  label: "Contact Number",
                  icon: Icons.phone_rounded,
                  isPhone: true,
                  minLength: 11,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  controller: _emailController,
                  label: "Email Address",
                  icon: Icons.email_rounded,
                  isEmail: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPrimaryButton(
              label: "CONTINUE",
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                if (_formKey1.currentState!.validate()) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitPage() {
    // Added the missing isOJT check here to prevent errors
    final bool isOJT = widget.categoryTitle == 'O.J.T.';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      child: Form(
        key: _formKey2,
        child: Column(
          children: [
            _sectionCard(
              title: "Visit Details",
              icon: Icons.place_rounded,
              children: [
                _buildLabel("Department to Visit", Icons.apartment_rounded),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: _inputDecoration(),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  items: _departments
                      .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedDepartment = val!),
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  controller: _contactPersonController,
                  label: isOJT ? "Coordinator / Instructor" : "Person to Visit",
                  icon: Icons.contact_mail_rounded,
                  minLength: 3,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  controller: _purposeController,
                  label: isOJT ? "OJT Purpose" : "Reason for Visit",
                  icon: Icons.notes_rounded,
                  minLength: 5,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text("BACK", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _accentColor, width: 2),
                        foregroundColor: _accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPrimaryButton(
                    label: "TAKE PHOTO",
                    icon: Icons.camera_alt_rounded,
                    onPressed: _handleFinalSubmit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.07) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _accentColor.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _accentColor.withOpacity(0.15)),
                child: Icon(icon, color: _accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: _accentColor.withOpacity(0.2), height: 1),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, bool isPhone = false, bool isEmail = false, int minLength = 1, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, icon),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
          inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
          style: GoogleFonts.montserrat(fontSize: 14),
          decoration: _inputDecoration(),
          validator: (val) {
            if (val == null || val.trim().isEmpty) return "This field is required";
            if (val.trim().length < minLength) return "Too short (min $minLength chars)";
            if (isEmail && !val.contains('@')) return "Enter a valid email";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _accentColor),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.07) : _accentColor.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor.withOpacity(0.3))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor.withOpacity(0.3))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor, width: 2)),
    );
  }

  Widget _buildPrimaryButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
        ),
      ),
    );
  }
}

// ── Overlays and Painter Classes ──
class _BouncingDotsOverlay extends StatefulWidget {
  @override
  State<_BouncingDotsOverlay> createState() => _BouncingDotsOverlayState();
}

class _BouncingDotsOverlayState extends State<_BouncingDotsOverlay> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<Color> _dotColors = const [Color(0xFF1A237E), Color(0xFF00897B), Color(0xFF29B6F6), Color(0xFFFFA726)];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 500)));
    _animations = _controllers.map((c) => Tween<double>(begin: 0, end: -28).animate(CurvedAnimation(parent: c, curve: Curves.easeOut))).toList();
    _startSequence();
  }

  void _startSequence() async {
    while (mounted) {
      for (int i = 0; i < _controllers.length; i++) {
        if (!mounted) break;
        await Future.delayed(Duration(milliseconds: i == 0 ? 0 : 120));
        if (mounted) _controllers[i].forward(from: 0).then((_) { if (mounted) _controllers[i].reverse(); });
      }
      await Future.delayed(const Duration(milliseconds: 700));
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 60, child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(4, (i) => AnimatedBuilder(animation: _animations[i], builder: (_, __) => Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Transform.translate(offset: Offset(0, _animations[i].value), child: Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: _dotColors[i])))))))),
              const SizedBox(height: 16),
              Text("Submitting...", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckmarkWidget extends StatefulWidget {
  final Color color;
  const _CheckmarkWidget({required this.color});
  @override
  State<_CheckmarkWidget> createState() => _CheckmarkWidgetState();
}

class _CheckmarkWidgetState extends State<_CheckmarkWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _checkAnim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _checkAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _ctrl, builder: (_, __) => Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color), child: CustomPaint(painter: _CheckPainter(progress: _checkAnim.value, color: Colors.white))));
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  _CheckPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 7..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final path = Path()..moveTo(size.width * 0.28, size.height * 0.5)..lineTo(size.width * 0.45, size.height * 0.68)..lineTo(size.width * 0.72, size.height * 0.32);
    for (final metric in path.computeMetrics()) { canvas.drawPath(metric.extractPath(0, metric.length * progress), paint); }
  }
  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}