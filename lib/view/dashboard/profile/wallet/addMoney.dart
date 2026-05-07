import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/viewModel/provider/walletProvider/walletProvider.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _amountCtrl = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _otpCtrl    = TextEditingController();

  bool _otpSent   = false;
  String? _txnRef;
  String? _error;

  static const Color _jcRed = Color(0xFFCC0000);

  final List<int> _quickAmounts = [500, 1000, 2000, 5000];

  String get _userId => context.read<AuthSession>().userId ?? '';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ── Step 1: send request to backend → backend calls JazzCash → JazzCash sends OTP ──
  Future<void> _sendOtp() async {
    setState(() => _error = null);
    final phone = _phoneCtrl.text.trim();
    final amt   = double.tryParse(_amountCtrl.text.trim()) ?? 0;

    if (!RegExp(r'^03[0-9]{9}$').hasMatch(phone)) {
      setState(() => _error = 'Valid number enter karein (03XXXXXXXXX)');
      return;
    }
    if (amt < 100) {
      setState(() => _error = 'Minimum Rs 100');
      return;
    }

    final ok = await context.read<WalletProvider>().sendAddMoneyOtp(
      buyerId:     _userId,
      amount:      amt,
      method:      'jazzcash_mwallet',
      phoneNumber: phone,
    );

    if (!mounted) return;
    if (ok) {
      setState(() {
        _txnRef  = context.read<WalletProvider>().lastTxnRefNo;
        _otpSent = true;
      });
    } else {
      final err = context.read<WalletProvider>().errorMessage;
      setState(() => _error = err.isNotEmpty ? err : 'OTP send karne mein error. Dobara try karein.');
    }
  }

  // ── Step 2: send OTP to backend → backend confirms with JazzCash → wallet credited ──
  Future<void> _verify() async {
    setState(() => _error = null);
    final otp = _otpCtrl.text.trim();
    if (otp.length < 4) {
      setState(() => _error = 'OTP enter karein');
      return;
    }

    final provider = context.read<WalletProvider>();
    final result = await provider.verifyAddMoneyOtp(
      buyerId:     _userId,
      phoneNumber: _phoneCtrl.text.trim(),
      otp:         otp,
      txnRefNo:    _txnRef ?? '',
    );

    if (!mounted) return;
    if (result != null) {
      PremiumToast.success(context, 'Rs ${_amountCtrl.text} wallet mein add ho gaye!');
      Navigator.pop(context, true);
    } else {
      final err = provider.errorMessage;
      setState(() => _error = err.isNotEmpty ? err : 'OTP galat ya expire ho gaya');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColor.appimagecolor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Money via JazzCash',
            style: TextStyle(color: const Color(0xFF1A1A2E),
                fontSize: 17.sp, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),

            // ── JazzCash header ───────────────────────────────────────────
            Center(
              child: Column(children: [
                Container(
                  width: 72.r, height: 72.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _jcRed.withValues(alpha: 0.3), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/images/JazzCashLogo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                            Icons.account_balance_wallet_rounded,
                            color: _jcRed, size: 36.sp)),
                  ),
                ),
                SizedBox(height: 12.h),
                if (!_otpSent)
                  Text('JazzCash se payment karein',
                      style: TextStyle(fontSize: 14.sp,
                          color: Colors.grey.shade600))
                else
                  Text('OTP aapke JazzCash number pe bheja gaya',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp,
                          color: Colors.grey.shade700)),
              ]),
            ),
            SizedBox(height: 28.h),

            if (!_otpSent) ...[
              // ── Amount ─────────────────────────────────────────────────
              _label('Amount'),
              SizedBox(height: 8.h),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  prefixText: 'Rs  ',
                  prefixStyle: TextStyle(fontSize: 18.sp,
                      fontWeight: FontWeight.w500, color: Colors.grey),
                  hintText: '100',
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.all(16.r),
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w, runSpacing: 8.h,
                children: _quickAmounts.map((a) => GestureDetector(
                  onTap: () => setState(() => _amountCtrl.text = '$a'),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: _amountCtrl.text == '$a'
                          ? const Color(0xFF1A1A2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text('Rs $a',
                        style: TextStyle(fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: _amountCtrl.text == '$a'
                                ? Colors.white
                                : const Color(0xFF1A1A2E))),
                  ),
                )).toList(),
              ),
              SizedBox(height: 20.h),

              // ── Phone ──────────────────────────────────────────────────
              _label('JazzCash Number'),
              SizedBox(height: 8.h),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 16.sp),
                decoration: InputDecoration(
                  hintText: '03XXXXXXXXX',
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.all(16.r),
                ),
              ),
              SizedBox(height: 28.h),

              SizedBox(
                width: double.infinity, height: 54.h,
                child: ElevatedButton(
                  onPressed: provider.otpLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _jcRed,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: provider.otpLoading
                      ? SpinKitThreeBounce(color: Colors.white, size: 22.sp)
                      : Text('OTP Bhejo',
                          style: TextStyle(fontSize: 16.sp,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ] else ...[
              // ── OTP Step ───────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(children: [
                  Icon(Icons.phone_android_rounded,
                      color: _jcRed, size: 20.sp),
                  SizedBox(width: 10.w),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('JazzCash Number',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    Text(_phoneCtrl.text,
                        style: TextStyle(fontSize: 15.sp,
                            fontWeight: FontWeight.w700)),
                  ]),
                  const Spacer(),
                  Text('Rs ${_amountCtrl.text}',
                      style: TextStyle(fontSize: 15.sp,
                          fontWeight: FontWeight.w700, color: _jcRed)),
                ]),
              ),
              SizedBox(height: 24.h),

              _label('6-Digit OTP'),
              SizedBox(height: 8.h),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700,
                    letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: TextStyle(letterSpacing: 8, color: Colors.grey.shade300),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.all(16.r),
                  counterText: '',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),

              SizedBox(
                width: double.infinity, height: 54.h,
                child: ElevatedButton(
                  onPressed: provider.verifyLoading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _jcRed,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: provider.verifyLoading
                      ? SpinKitThreeBounce(color: Colors.white, size: 22.sp)
                      : Text('Verify & Add Money',
                          style: TextStyle(fontSize: 16.sp,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _otpSent = false;
                    _txnRef  = null;
                    _otpCtrl.clear();
                    _error   = null;
                  }),
                  child: Text('Number change karein',
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                ),
              ),
            ],

            // ── Error ───────────────────────────────────────────────────
            if (_error != null) ...[
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(child: Text(_error!,
                      style: TextStyle(fontSize: 13.sp, color: Colors.red.shade700))),
                ]),
              ),
            ],
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E)));
}
