import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/viewModel/provider/walletProvider/walletProvider.dart';
import 'package:url_launcher/url_launcher.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _amountController = TextEditingController();
  final _numberController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedMethod = '';
  bool _otpSent = false; // OTP screen show karo ya amount screen

  final List<double> _quickAmounts = [500, 1000, 2000, 5000];

  @override
  void dispose() {
    _amountController.dispose();
    _numberController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String get _buyerId => context.read<AuthSession>().userId ?? '';

  // ── Safepay Checkout — No OTP ──────────────────────────────────────────────
  Future<void> _initSafepay() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<WalletProvider>();
    final amount = double.parse(_amountController.text);
    
    final url = await provider.initSafepayCheckout(
      buyerId: _buyerId,
      amount: amount,
    );

    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Popping back to wallet so they can see update after webhook
        if (mounted) Navigator.pop(context);
      } else {
        _showError('Could not open checkout page');
      }
    } else {
      _showError(provider.errorMessage);
    }
  }

  // Step 1: Send OTP
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod.isEmpty) {
      _showError('Please select a payment method');
      return;
    }

    // Safepay handles its own flow
    if (_selectedMethod == 'safepay') {
      await _initSafepay();
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await context.read<WalletProvider>().sendAddMoneyOtp(
      buyerId: _buyerId,
      amount: double.parse(_amountController.text),
      method: _selectedMethod,
      phoneNumber: _numberController.text,
    );

    if (success) {
      setState(() => _otpSent = true);
    } else {
      _showError(context.read<WalletProvider>().errorMessage);
    }
  }

  // Step 2: Verify OTP
  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length < 6) {
      _showError('Enter 6-digit OTP');
      return;
    }
    FocusScope.of(context).unfocus();

    final result = await context.read<WalletProvider>().verifyAddMoneyOtp(
      buyerId: _buyerId,
      phoneNumber: _numberController.text,
      otp: _otpController.text.trim(),
    );

    if (result != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: result.amount,
            method: _selectedMethod,
            phoneNumber: result.phoneNumber,
            txnId: result.txnId,
          ),
        ),
      );
    } else {
      _showError(context.read<WalletProvider>().errorMessage);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, wallet, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: AppColor.appimagecolor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF1A1A2E),
                size: 20,
              ),
              onPressed: () {
                if (_otpSent) {
                  setState(() => _otpSent = false); // OTP se back
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              _otpSent ? 'Enter OTP' : 'Add Money',
              style: TextStyle(
                color: const Color(0xFF1A1A2E),
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),
          body: _otpSent ? _buildOtpScreen(wallet) : _buildAmountScreen(wallet),
        );
      },
    );
  }

  // ── Amount + Method Screen ────────────────────────────────────────────────
  Widget _buildAmountScreen(WalletProvider wallet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            _SectionLabel(label: 'Enter Amount'),
            SizedBox(height: 10.h),

            // Amount input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey.shade300,
                  ),
                  prefixText: 'Rs  ',
                  prefixStyle: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20.r),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  final amt = double.tryParse(val) ?? 0;
                  if (amt < 100) return 'Minimum amount is Rs 100';
                  if (amt > 50000) return 'Maximum amount is Rs 50,000';
                  return null;
                },
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

            SizedBox(height: 12.h),

            // Quick amounts
            Wrap(
              spacing: 8.w,
              children: _quickAmounts.map((amt) {
                final selected =
                    _amountController.text == amt.toStringAsFixed(0);
                return GestureDetector(
                  onTap: () => setState(
                    () => _amountController.text = amt.toStringAsFixed(0),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1A1A2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1A1A2E)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      'Rs ${amt.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 28.h),

            _SectionLabel(label: 'Select Payment Method'),
            SizedBox(height: 12.h),

            _PaymentMethodCard(
              id: 'easypaisa',
              name: 'EasyPaisa',
              description: 'Pay via EasyPaisa mobile account',

              color: const Color(0xFF00A650),
              bgColor: const Color(0xFFE8F5E9),
              isSelected: _selectedMethod == 'easypaisa',
              onTap: () => setState(() => _selectedMethod = 'easypaisa'),
            ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),

            SizedBox(height: 10.h),

            _PaymentMethodCard(
              id: 'jazzcash',
              name: 'JazzCash',
              description: 'Pay via JazzCash mobile account',
              isJazzcash: true,
              color: const Color(0xFFCC0000),
              bgColor: const Color(0xFFFFF0F0),
              isSelected: _selectedMethod == 'jazzcash',
              onTap: () => setState(() => _selectedMethod = 'jazzcash'),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

            SizedBox(height: 10.h),

            _PaymentMethodCard(
              id: 'safepay',
              name: 'Safepay',
              description: 'Pay via Credit/Debit card',
              isSafepay: true,
              color: const Color(0xFF0052CC),
              bgColor: const Color(0xFFE8F0FE),
              isSelected: _selectedMethod == 'safepay',
              onTap: () => setState(() => _selectedMethod = 'safepay'),
            ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1),

            SizedBox(height: 28.h),

            if (_selectedMethod.isNotEmpty && _selectedMethod != 'safepay') ...[
              _SectionLabel(
                label: _selectedMethod == 'easypaisa'
                    ? 'EasyPaisa Number'
                    : 'JazzCash Number',
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: '03XX-XXXXXXX',
                    hintStyle: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey.shade300,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedMethod == 'easypaisa'
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '+92',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: _selectedMethod == 'easypaisa'
                                ? const Color(0xFF00A650)
                                : const Color(0xFFCC0000),
                          ),
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 18.h,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter number';
                    if (val.length < 10) return 'Enter valid number';
                    return null;
                  },
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
              SizedBox(height: 28.h),
            ],

            SizedBox(height: 16.h),

            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: wallet.otpLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.appimagecolor,
                  disabledBackgroundColor: AppColor.appimagecolor.withOpacity(
                    0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: wallet.otpLoading
                    ? SizedBox(
                        width: 24.r,
                        height: 24.r,
                        child: Utils.loadingLottie(size: 100),
                      )
                    : Text(
                        _selectedMethod == 'safepay' ? 'Proceed to Pay' : 'Send OTP',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),

            SizedBox(height: 12.h),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14.r,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    '256-bit SSL Secured Payment',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // ── OTP Verification Screen ───────────────────────────────────────────────
  Widget _buildOtpScreen(WalletProvider wallet) {


    final isJazzcash = _selectedMethod == 'jazzcash';
    final String logoPath = isJazzcash
    ? 'assets/images/JazzCashLogo.jpg'
    : 'assets/images/easypaisaLogo.jpg';
    final methodLabel = _selectedMethod == 'easypaisa'
        ? 'EasyPaisa'
        : 'JazzCash';
    final color = _selectedMethod == 'easypaisa'
        ? const Color(0xFF00A650)
        : const Color(0xFFCC0000);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          SizedBox(height: 20.h),

        CircleAvatar(
  radius: 70.r,
  backgroundColor: color.withOpacity(0.1),
  backgroundImage: AssetImage(logoPath),
).animate().scale(
  curve: Curves.elasticOut,
  duration: 600.ms,
),

          SizedBox(height: 20.h),

          Text(
            'OTP Sent!',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter the 6-digit OTP sent to\n${_numberController.text} via $methodLabel',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),

          SizedBox(height: 36.h),

          // OTP field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
                color: const Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: TextStyle(
                  fontSize: 22.sp,
                  color: Colors.grey.shade300,
                  letterSpacing: 6,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20.r),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: wallet.verifyLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.appimagecolor,
                disabledBackgroundColor: AppColor.appimagecolor.withOpacity(
                  0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: wallet.verifyLoading
                  ? SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: Utils.loadingLottie(size: 100),
                    )
                  : Text(
                      'Verify & Add Money',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ).animate().fadeIn(delay: 100.ms),

          SizedBox(height: 16.h),

          // Resend OTP
          TextButton(
            onPressed: wallet.otpLoading ? null : _sendOtp,
            child: Text(
              wallet.otpLoading ? 'Sending...' : 'Resend OTP',
              style: TextStyle(
                fontSize: 14.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable widgets (same as before) ───────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1A1A2E),
      letterSpacing: 0.2,
    ),
  );
}

class _PaymentMethodCard extends StatelessWidget {
  final String id, name, description;
  final bool isJazzcash;
  final bool isSafepay;
  final Color color, bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.id,
    required this.name,
    required this.description,
    this.isJazzcash = false,
    this.isSafepay = false,
    required this.color,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String logoPath = isJazzcash
    ? 'assets/images/JazzCashLogo.jpg'
    : 'assets/images/easypaisaLogo.jpg';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: isSafepay
                    ? Icon(
                        Icons.credit_card_rounded,
                        color: color,
                        size: 24.r,
                      )
                    : Image.asset(
                        logoPath,
                        width: 26.r,
                        height: 26.r,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 14.r)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment Success Screen ───────────────────────────────────────────────────
class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String method;
  final String phoneNumber;
  final String txnId;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.method,
    required this.phoneNumber,
    required this.txnId,
  });

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final isEasypaisa = method == 'easypaisa';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF00C853),
                  size: 60.r,
                ),
              ).animate().scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                curve: Curves.elasticOut,
                duration: 800.ms,
              ),

              SizedBox(height: 24.h),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

              SizedBox(height: 8.h),
              Text(
                'Rs ${amount.toStringAsFixed(0)} has been added to your wallet',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              ).animate().fadeIn(delay: 500.ms),

              SizedBox(height: 32.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ReceiptRow(
                      label: 'Amount',
                      value: 'Rs ${amount.toStringAsFixed(0)}',
                      valueColor: const Color(0xFF00C853),
                      isBold: true,
                    ),
                    Divider(height: 20.h, color: Colors.grey.shade100),
                    _ReceiptRow(
                      label: 'Payment Method',
                      value: isEasypaisa ? 'EasyPaisa' : 'JazzCash',
                    ),
                    SizedBox(height: 12.h),
                    _ReceiptRow(label: 'Phone', value: phoneNumber),
                    SizedBox(height: 12.h),
                    _ReceiptRow(label: 'Transaction ID', value: txnId),
                    SizedBox(height: 12.h),
                    _ReceiptRow(
                      label: 'Date & Time',
                      value: _formatDateTime(DateTime.now()),
                    ),
                    SizedBox(height: 12.h),
                    _ReceiptRow(
                      label: 'Status',
                      value: '✅ Completed',
                      valueColor: const Color(0xFF00C853),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.15),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.appimagecolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Back to Wallet',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isBold;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}
