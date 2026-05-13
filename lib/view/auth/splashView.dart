import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/models/notification_services/notification_services.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/view/dashboard/DashboardScreen.dart';

class _Particle {
  double x, y, radius, speed, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

// ─────────────────────────────────────────────
//  Floating particles painter
// ─────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter(this.particles, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = color.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ─────────────────────────────────────────────
//  Shimmer painter for the logo ring
// ─────────────────────────────────────────────
class _ShimmerRingPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color primaryColor;
  final Color accentColor;

  _ShimmerRingPainter(this.progress, this.primaryColor, this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background ring
    final bgPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    // Animated arc
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        colors: [
          accentColor.withOpacity(0),
          accentColor,
          primaryColor,
          accentColor.withOpacity(0),
        ],
        stops: const [0.0, 0.25, 0.5, 1.0],
        transform: GradientRotation(2 * pi * progress),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + 2 * pi * progress,
      pi * 1.4,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ShimmerRingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
//  SPLASH SCREEN
// 102: // ─────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────
  late AnimationController _ringCtrl; // spinning shimmer ring
  late AnimationController _revealCtrl; // staggered content reveal
  late AnimationController _particleCtrl; // particle float loop
  late AnimationController _pulseCtrl; // subtle logo pulse

  // ── Reveal animations ────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _badgeFade;
  late Animation<double> _dividerWidth;

  // ── Pulse ────────────────────────────────────
  late Animation<double> _pulse;

  // ── Particles ────────────────────────────────
  final List<_Particle> _particles = [];
  final _rng = Random();
  late Timer _particleTimer;

  // ── Palette (BRAND THEME) ────────────────────
  static const Color _bg = AppColor.screenBgColor;
  static const Color _primary = AppColor.primaryColor;
  static const Color _accent = AppColor.secondaryColor;
  static const Color _surface = AppColor.whiteColor;
  static const Color _text = AppColor.textPrimaryColor;

  @override
  void initState() {
    super.initState();

    // Notification token
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.registerTokenIfLoggedIn();
    });

    _initParticles();
    _initAnimations();

    // Navigate after 3.5 s
    Timer(const Duration(milliseconds: 3500), navigateNext);
  }

  // ── Particle init ─────────────────────────────
  void _initParticles() {
    for (int i = 0; i < 28; i++) {
      _particles.add(
        _Particle(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          radius: _rng.nextDouble() * 2.2 + 0.6,
          speed: _rng.nextDouble() * 0.0008 + 0.0003,
          opacity: _rng.nextDouble() * 0.35 + 0.05,
        ),
      );
    }

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _particleTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!mounted) return;
      setState(() {
        for (final p in _particles) {
          p.y -= p.speed;
          if (p.y < -0.02) {
            p.y = 1.02;
            p.x = _rng.nextDouble();
            p.opacity = _rng.nextDouble() * 0.35 + 0.05;
          }
        }
      });
    });
  }

  // ── Animation init ───────────────────────────
  void _initAnimations() {
    // Spinning ring
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Staggered reveal (0 → 1800 ms)
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _logoFade = _curved(_revealCtrl, 0.00, 0.30);
    _logoScale = CurvedAnimation(
      parent: _revealCtrl,
      curve: const Interval(0.00, 0.40, curve: Curves.elasticOut),
    );

    _titleFade = _curved(_revealCtrl, 0.30, 0.60);
    _titleSlide = _slide(_revealCtrl, 0.30, 0.60);

    _taglineFade = _curved(_revealCtrl, 0.50, 0.80);
    _taglineSlide = _slide(_revealCtrl, 0.50, 0.80);

    _dividerWidth = _curved(_revealCtrl, 0.40, 0.70);
    _badgeFade = _curved(_revealCtrl, 0.70, 1.00);

    // Pulse loop
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  Animation<double> _curved(
    AnimationController ctrl,
    double start,
    double end,
  ) => CurvedAnimation(
    parent: ctrl,
    curve: Interval(start, end, curve: Curves.easeOut),
  );

  Animation<Offset> _slide(
    AnimationController ctrl,
    double start,
    double end,
  ) => Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
    CurvedAnimation(
      parent: ctrl,
      curve: Interval(start, end, curve: Curves.easeOut),
    ),
  );

  // ── Navigation ───────────────────────────────
  Future<void> navigateNext() async {
    final token = await LocalStorage.getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeNavBarScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeNavBarScreen()),
      );
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _revealCtrl.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    _particleTimer.cancel();
    super.dispose();
  }

  // ── BUILD ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ① Soft glow background
          _buildBackground(),

          // ② Floating particles (Subtle brand color)
          Positioned.fill(
            child: CustomPaint(
              painter: _ParticlePainter(_particles, _primary),
            ),
          ),

          // ③ Main content
          _buildContent(),

          // ④ Bottom badge
          _buildBottomBadge(),
        ],
      ),
    );
  }

  // ── Background ───────────────────────────────
  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Light radial glow at top-center
          Positioned(
            top: -120.h,
            left: -80.w,
            right: -80.w,
            child: Container(
              height: 520.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [_primary.withOpacity(0.12), _bg.withOpacity(0.0)],
                  radius: 0.75,
                ),
              ),
            ),
          ),
          // Subtle bottom glow
          Positioned(
            bottom: -60.h,
            left: 0,
            right: 0,
            child: Container(
              height: 300.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _primary.withOpacity(0.04)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main content ─────────────────────────────
  Widget _buildContent() {
    return Center(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),

            // Logo container with spinning ring
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: ScaleTransition(
                  scale: _pulse,
                  child: SizedBox(
                    width: 148.w,
                    height: 148.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: 148.w,
                          height: 148.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        // Shimmer spinning ring
                        AnimatedBuilder(
                          animation: _ringCtrl,
                          builder: (_, __) => CustomPaint(
                            size: Size(148.w, 148.w),
                            painter: _ShimmerRingPainter(
                              _ringCtrl.value,
                              _primary,
                              _primary.withOpacity(0.3),
                            ),
                          ),
                        ),
                        // Logo disc
                        Container(
                          width: 118.w,
                          height: 118.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _surface,
                            border: Border.all(
                              color: _primary.withOpacity(0.1),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.shopping_bag_rounded,
                              color: _primary,
                              size: 54.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 44.h),

            // App name
            FadeTransition(
              opacity: _titleFade,
              child: SlideTransition(
                position: _titleSlide,
                child: Column(
                  children: [
                    Text(
                      "SHOOKOO",
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w900,
                        color: _primary,
                        letterSpacing: 8,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Accent word
                    Text(
                      "STORE",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _text.withOpacity(0.6),
                        letterSpacing: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Animated divider
            AnimatedBuilder(
              animation: _dividerWidth,
              builder: (_, __) => Container(
                width: _dividerWidth.value * 120.w,
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, _primary.withOpacity(0.5), Colors.transparent],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Tagline
            FadeTransition(
              opacity: _taglineFade,
              child: SlideTransition(
                position: _taglineSlide,
                child: Text(
                  "Everything you need, in one place",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _text.withOpacity(0.4),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom badge ─────────────────────────────
  Widget _buildBottomBadge() {
    return Positioned(
      bottom: 48.h,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _badgeFade,
        child: Column(
          children: [
            // Loading dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return _LoadingDot(
                  delay: Duration(milliseconds: i * 200),
                  color: _primary,
                );
              }),
            ),
            SizedBox(height: 16.h),
            Text(
              "Crafted with ♥ for you",
              style: TextStyle(
                fontSize: 11.sp,
                color: _text.withOpacity(0.3),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Animated loading dot
// ─────────────────────────────────────────────
class _LoadingDot extends StatefulWidget {
  final Duration delay;
  final Color color;

  const _LoadingDot({required this.delay, required this.color});

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(_anim.value),
        ),
      ),
    );
  }
}
