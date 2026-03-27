// ─── sendMoney.dart ───────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/viewModel/provider/walletProvider/walletProvider.dart';

class SendMoneyScreen extends StatefulWidget {
  final double balance;
  const SendMoneyScreen({super.key, required this.balance});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _amountController = TextEditingController();
  final _numberController = TextEditingController();
  final _noteController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedMethod = '';
  bool _otpSent = false;

  @override
  void dispose() {
    _amountController.dispose();
    _numberController.dispose();
    _noteController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String get _buyerId => context.read<AuthSession>().userId ?? '';

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod.isEmpty) {
      _showError('Please select where to send');
      return;
    }
    final amt = double.tryParse(_amountController.text) ?? 0;
    if (amt > widget.balance) {
      _showError('Insufficient wallet balance');
      return;
    }
    FocusScope.of(context).unfocus();

    final success = await context.read<WalletProvider>().sendMoneyOtp(
      buyerId: _buyerId,
      amount: amt,
      method: _selectedMethod,
      recipientNumber: _numberController.text,
      note: _noteController.text,
    );

    if (success) {
      setState(() => _otpSent = true);
    } else {
      _showError(context.read<WalletProvider>().errorMessage);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length < 6) {
      _showError('Enter 6-digit OTP');
      return;
    }
    FocusScope.of(context).unfocus();

    final result = await context.read<WalletProvider>().verifySendMoneyOtp(
      buyerId: _buyerId,
      otp: _otpController.text.trim(),
    );

    if (result != null && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _SendSuccessSheet(
          amount: result.amount,
          method: result.method,
          number: result.phoneNumber,
          note: result.note ?? '',
          txnId: result.txnId,
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
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
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
                    setState(() => _otpSent = false);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text(
                _otpSent ? 'Enter OTP' : 'Send Money',
                style: TextStyle(
                  color: const Color(0xFF1A1A2E),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            ),
            body: _otpSent ? _buildOtpScreen(wallet) : _buildFormScreen(wallet),
          ),
        );
      },
    );
  }

  Widget _buildFormScreen(WalletProvider wallet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance display
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColor.appimagecolor,
                    Color.fromARGB(255, 235, 168, 123),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white54,
                    size: 20.r,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Available: Rs ${widget.balance.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            SizedBox(height: 20.h),

            _Label('Amount to Send'),
            SizedBox(height: 10.h),

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
              child: TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontSize: 24.sp,
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.w300,
                  ),
                  prefixText: 'Rs  ',
                  prefixStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18.r),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  final amt = double.tryParse(val) ?? 0;
                  if (amt < 10) return 'Minimum Rs 10';
                  return null;
                },
              ),
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 20.h),
            _Label('Send Via'),
            SizedBox(height: 10.h),

            _PaymentMethodCard(
              isSelected: _selectedMethod == 'easypaisa',
              label: 'EasyPaisa',
              description: 'Transfer instantly securely via OTP',
              logoPath: 'assets/images/easypaisaLogo.jpg',
              color: const Color(0xFF00A650),
              onTap: () => setState(() => _selectedMethod = 'easypaisa'),
            ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),
            SizedBox(height: 12.h),
            _PaymentMethodCard(
              isSelected: _selectedMethod == 'jazzcash',
              label: 'JazzCash',
              description: 'Professional mobile wallet transfer',
              logoPath: 'assets/images/JazzCashLogo.jpg',
              color: const Color(0xFFCC0000),
              onTap: () => setState(() => _selectedMethod = 'jazzcash'),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

            SizedBox(height: 20.h),
            _Label('Recipient Number'),
            SizedBox(height: 10.h),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  hintText: '03XXXXXXXXX',
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: Colors.grey.shade400,
                    size: 20.r,
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
            ).animate().fadeIn(delay: 200.ms),

            SizedBox(height: 20.h),
            _Label('Note (Optional)'),
            SizedBox(height: 10.h),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _noteController,
                maxLength: 50,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1A2E),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Payment for order...',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade300,
                  ),
                  prefixIcon: Icon(
                    Icons.note_outlined,
                    color: Colors.grey.shade400,
                    size: 20.r,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  counterText: '',
                ),
              ),
            ).animate().fadeIn(delay: 250.ms),

            SizedBox(height: 32.h),

            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: wallet.otpLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.appimagecolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: wallet.otpLoading
                    ? SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: Utils.loadingLottie(size: 100),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpScreen(WalletProvider wallet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: const Color(0xFF2979FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.send_rounded,
              color: const Color(0xFF2979FF),
              size: 36.r,
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
          SizedBox(height: 20.h),
          Text(
            'Confirm Transfer',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter OTP sent to\n${_numberController.text}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 36.h),

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
          ),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: wallet.verifyLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2979FF),
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
                      'Confirm & Send',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: wallet.otpLoading ? null : _sendOtp,
            child: Text(
              wallet.otpLoading ? 'Sending...' : 'Resend OTP',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF2979FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1A1A2E),
    ),
  );
}
class _PaymentMethodCard extends StatelessWidget {
  final bool isSelected;
  final String label;
  final String description;
  final String logoPath;
  final Color color;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.isSelected,
    required this.label,
    required this.description,
    required this.logoPath,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withOpacity(0.12) : Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.r,
              height: 50.r,
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Image.asset(logoPath, fit: BoxFit.contain),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
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


class _SendSuccessSheet extends StatelessWidget {
  final double amount;
  final String method, number, note, txnId;

  const _SendSuccessSheet({
    required this.amount,
    required this.method,
    required this.number,
    required this.note,
    required this.txnId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              color: const Color(0xFF2979FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF2979FF),
              size: 44.r,
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
          SizedBox(height: 16.h),
          Text(
            'Money Sent!',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Rs ${amount.toStringAsFixed(0)} sent to $number',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              children: [
                _Row('Method', method),
                SizedBox(height: 10.h),
                _Row('Transaction ID', txnId),
                if (note.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _Row('Note', note),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(
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
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
      ),
    ],
  );
}
