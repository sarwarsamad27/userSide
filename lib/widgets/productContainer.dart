import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'dart:math'; // ✅ ADD THIS IMPORT
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';

class CategoryTile extends StatefulWidget {
  final String name;
  final String image;
  final VoidCallback onTap;
  final bool isPremium;
  final double? averageDiscount;

  const CategoryTile({
    required this.name,
    required this.image,
    required this.onTap,
    this.isPremium = true,
    this.averageDiscount,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation for Lottie
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotateController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String finalImageUrl = (widget.image.isNotEmpty)
        ? "${Global.imageUrl}${widget.image}"
        : "";

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 170.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: Stack(
                children: [
                  // Main Image
                  Positioned.fill(
                    child: finalImageUrl.isEmpty
                        ? buildPlaceholder()
                        : Image.network(
                            finalImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                buildPlaceholder(),
                          ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.15),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // ✅ Premium Star Badge
                  if (widget.isPremium &&
                      widget.averageDiscount != null &&
                      widget.averageDiscount! > 0)
                    Positioned(
                      top: -5.h,
                      right: -5.w,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glowing background circle
                            Container(
                              width: 65.w,
                              height: 65.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.amber.withOpacity(0.6),
                                    Colors.orange.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // Star background with gradient
                            CustomPaint(
                              size: Size(55.w, 55.h),
                              painter: StarPainter(
                                color1: Colors.amber.shade400,
                                color2: Colors.orange.shade600,
                              ),
                            ),

                            // Rotating Lottie in background
                            // RotationTransition(
                            //   turns: _rotateAnimation,
                            //   child: SizedBox(
                            //     width: 45.w,
                            //     height: 45.h,
                            //     child: Lottie.asset(
                            //       'assets/gif/Coupon.json',
                            //       fit: BoxFit.contain,
                            //       repeat: true,
                            //     ),
                            //   ),
                            // ),

                            // Discount text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'UPTO',
                                  style: TextStyle(
                                    fontSize: 6.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${widget.averageDiscount!.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.6),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'OFF',
                                  style: TextStyle(
                                    fontSize: 6.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Name container
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: AppColor.primaryColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Text(
              widget.name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimaryColor,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

// ✅ Custom Star Painter
class StarPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  StarPainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color1, color2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * pi / 180;
      final innerAngle = ((i * 72) + 36 - 90) * pi / 180;

      if (i == 0) {
        path.moveTo(
          centerX + outerRadius * cos(outerAngle),
          centerY + outerRadius * sin(outerAngle),
        );
      } else {
        path.lineTo(
          centerX + outerRadius * cos(outerAngle),
          centerY + outerRadius * sin(outerAngle),
        );
      }

      path.lineTo(
        centerX + innerRadius * cos(innerAngle),
        centerY + innerRadius * sin(innerAngle),
      );
    }

    path.close();
    canvas.drawPath(path, paint);

    // Add border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
