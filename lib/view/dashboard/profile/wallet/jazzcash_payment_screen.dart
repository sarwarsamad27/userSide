import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';

// ── JazzCash Payment Screen ───────────────────────────────────────────────────
// Opens the JazzCash hosted-checkout in the system browser.
// When user returns to the app, [onPaymentDone] is called so the caller
// can refresh the wallet balance.
class JazzCashPaymentScreen extends StatefulWidget {
  final double amount;
  final String userId;
  final bool isCompany;
  final VoidCallback onPaymentDone;

  const JazzCashPaymentScreen({
    super.key,
    required this.amount,
    required this.userId,
    required this.isCompany,
    required this.onPaymentDone,
  });

  @override
  State<JazzCashPaymentScreen> createState() => _JazzCashPaymentScreenState();
}

class _JazzCashPaymentScreenState extends State<JazzCashPaymentScreen>
    with WidgetsBindingObserver {
  bool _opened = false;
  bool _returned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when app comes back to foreground after browser
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _opened && !_returned) {
      setState(() => _returned = true);
      widget.onPaymentDone();
    }
  }

  Future<void> _open() async {
    final amt = widget.amount.toStringAsFixed(0);
    final url = Uri.parse(
      '${Global.JazzcashInitiate}'
      '?amount=$amt'
      '&userId=${widget.userId}'
      '&isCompany=${widget.isCompany}',
    );
    if (await canLaunchUrl(url)) {
      setState(() => _opened = true);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not open JazzCash. Please try again.'),
          backgroundColor: Colors.red,
        ));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColor.appimagecolor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A2E)),
          onPressed: () {
            widget.onPaymentDone();
            Navigator.pop(context);
          },
        ),
        title: Text('JazzCash Payment',
            style: TextStyle(color: const Color(0xFF1A1A2E),
                fontSize: 17.sp, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // JazzCash logo area
          Container(
            width: 90.r, height: 90.r,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCC0000).withValues(alpha: 0.3), width: 2),
            ),
            child: ClipOval(
              child: Image.asset('assets/images/JazzCashLogo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFFCC0000), size: 40)),
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),

          SizedBox(height: 24.h),

          Text('JazzCash Payment',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E)))
              .animate().fadeIn(delay: 200.ms),

          SizedBox(height: 8.h),

          Text('Rs ${widget.amount.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900,
                  color: const Color(0xFFCC0000)))
              .animate().fadeIn(delay: 300.ms),

          SizedBox(height: 32.h),

          _returned
              ? Column(children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text('Verifying payment…',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                ])
              : Column(children: [
                  Container(
                    padding: EdgeInsets.all(16.r),
                    margin: EdgeInsets.symmetric(horizontal: 32.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(children: [
                      Icon(Icons.open_in_browser_rounded,
                          size: 32.sp, color: const Color(0xFFCC0000)),
                      SizedBox(height: 10.h),
                      Text('JazzCash is opening in your browser.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                      SizedBox(height: 6.h),
                      Text('Complete payment there, then return here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
                    ]),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                  SizedBox(height: 24.h),

                  TextButton.icon(
                    onPressed: _open,
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFFCC0000)),
                    label: Text('Reopen JazzCash',
                        style: TextStyle(color: const Color(0xFFCC0000),
                            fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  ),
                ]),

          SizedBox(height: 16.h),

          if (_returned)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done', style: TextStyle(fontSize: 14.sp,
                  color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}
