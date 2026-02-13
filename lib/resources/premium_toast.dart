import 'dart:async';
import 'package:flutter/material.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/notificationScreen/notification_route.dart';

class PremiumToast {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void show(
    BuildContext? context,
    String message, {
    Color? backgroundColor,
    IconData? icon,
    Color? iconColor,
    bool isError = false,
    bool isSuccess = false,
    bool isWarning = false,
  }) {
    _removeToast();

    // ✅ NEW: Try to get context from global navigator if not provided
    final actualContext =
        context ?? NotificationRouter.navigatorKey.currentContext;

    if (actualContext == null) {
      debugPrint("PremiumToast: No context available to show toast.");
      return;
    }

    final overlay = Overlay.maybeOf(actualContext);
    if (overlay == null) return;

    // Determine style based on type
    Color bgColor = backgroundColor ?? Colors.grey.shade900;
    IconData toastIcon = icon ?? Icons.info_outline;
    Color tIconColor = iconColor ?? Colors.white;

    if (isError) {
      bgColor = AppColor.errorColor;
      toastIcon = Icons.error_outline;
    } else if (isSuccess) {
      bgColor = AppColor.successColor;
      toastIcon = Icons.check_circle_outline;
    } else if (isWarning) {
      bgColor = Colors.orange;
      toastIcon = Icons.warning_amber_rounded;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: bgColor,
        icon: toastIcon,
        iconColor: tIconColor,
        onDismiss: _removeToast,
      ),
    );

    overlay.insert(_overlayEntry!);

    _timer = Timer(const Duration(seconds: 3), () {
      _removeToast();
    });
  }

  static void _removeToast() {
    _timer?.cancel();
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry?.remove();
    }
    _overlayEntry = null;
  }

  static void success(BuildContext? context, String message) {
    show(context, message, isSuccess: true);
  }

  static void error(BuildContext? context, String message) {
    show(context, message, isError: true);
  }

  static void warning(BuildContext? context, String message) {
    show(context, message, isWarning: true);
  }

  static void info(BuildContext? context, String message) {
    show(context, message);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onDismiss;

  const _ToastWidget({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _offset = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50.h,
      left: 20.w,
      right: 20.w,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _offset,
            child: GestureDetector(
              onVerticalDragEnd: (_) {
                widget.onDismiss();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: widget.iconColor, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
