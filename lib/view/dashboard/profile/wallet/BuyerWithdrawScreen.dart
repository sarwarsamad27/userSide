// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/viewModel/provider/walletProvider/walletProvider.dart';

class BuyerWithdrawScreen extends StatefulWidget {
  final double balance;
  const BuyerWithdrawScreen({super.key, required this.balance});

  @override
  State<BuyerWithdrawScreen> createState() => _BuyerWithdrawScreenState();
}

class _BuyerWithdrawScreenState extends State<BuyerWithdrawScreen> {
  final _nameController   = TextEditingController();
  final _phoneController  = TextEditingController();
  final _amountController = TextEditingController();
  final _otpController    = TextEditingController();
  final _formKey          = GlobalKey<FormState>();
  bool _otpSent = false;
  String _method = 'JazzCash';

  static const Color _primary = Color(0xFFCC0000);
  static const Color _jcBg    = Color(0xFFFFF0F0);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String get _buyerId => context.read<AuthSession>().userId ?? '';

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final amt = double.tryParse(_amountController.text) ?? 0;
    if (amt > widget.balance) {
      _showError('Insufficient wallet balance');
      return;
    }
    FocusScope.of(context).unfocus();

    final ok = await context.read<WalletProvider>().sendBuyerWithdrawOtp(
      buyerId: _buyerId,
      amount: amt,
      method: _method,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (ok) {
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

    final result = await context.read<WalletProvider>().verifyBuyerWithdrawOtp(
      buyerId: _buyerId,
      otp: _otpController.text.trim(),
    );

    if (result != null && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _WithdrawSuccessSheet(
          amount: result.amount,
          method: _method,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          txnId: result.txnId,
        ),
      );
    } else {
      _showError(context.read<WalletProvider>().errorMessage);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ));
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
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {
                  if (_otpSent) {
                    setState(() => _otpSent = false);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text(
                _otpSent ? 'Verify OTP' : 'Withdraw Funds',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
            ),
            body: _otpSent ? _buildOtpScreen(wallet) : _buildFormScreen(wallet),
          ),
        );
      },
    );
  }

  // ── Form Screen ───────────────────────────────────────────────────────────
  Widget _buildFormScreen(WalletProvider wallet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Balance Banner ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.primaryColor.withOpacity(0.9), AppColor.primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(color: AppColor.primaryColor.withOpacity(0.3),
                      blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 22.r),
                  ),
                  SizedBox(width: 14.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Available Balance',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.white70)),
                      Text(
                        'Rs ${widget.balance.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            SizedBox(height: 24.h),

            // ── Method Selector ────────────────────────────────────────────
            _SectionLabel('Withdraw Via'),
            SizedBox(height: 10.h),
            Row(
              children: ['JazzCash', 'EasyPaisa', 'Bank'].map((m) {
                final isSelected = _method == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _method = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                          right: m != 'Bank' ? 8.w : 0),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.primaryColor
                              : Colors.grey.shade200,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(
                                color: AppColor.primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4))]
                            : [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8)],
                      ),
                      child: Text(
                        m,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 20.h),

            // ── Amount ─────────────────────────────────────────────────────
            _SectionLabel('Amount to Withdraw'),
            SizedBox(height: 10.h),
            _buildInputBox(
              child: TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E)),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                      fontSize: 24.sp, color: Colors.grey.shade300,
                      fontWeight: FontWeight.w300),
                  prefixText: 'Rs  ',
                  prefixStyle: TextStyle(
                      fontSize: 18.sp, fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18.r),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  final amt = double.tryParse(val) ?? 0;
                  if (amt < 100) return 'Minimum Rs 100';
                  if (amt > widget.balance) return 'Insufficient balance';
                  return null;
                },
              ),
            ).animate().fadeIn(delay: 150.ms),

            SizedBox(height: 20.h),

            // ── Recipient Name ─────────────────────────────────────────────
            _SectionLabel('Account Holder Name'),
            SizedBox(height: 10.h),
            _buildInputBox(
              child: TextFormField(
                controller: _nameController,
                style: TextStyle(
                    fontSize: 15.sp, color: const Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Full name as per account',
                  hintStyle: TextStyle(
                      fontSize: 14.sp, color: Colors.grey.shade300),
                  prefixIcon: Icon(Icons.person_outline_rounded,
                      color: Colors.grey.shade400, size: 20.r),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 18.h),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter name' : null,
              ),
            ).animate().fadeIn(delay: 200.ms),

            SizedBox(height: 20.h),

            // ── Phone Number ───────────────────────────────────────────────
            _SectionLabel('Account Number / Phone'),
            SizedBox(height: 10.h),
            _buildInputBox(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E), letterSpacing: 1),
                decoration: InputDecoration(
                  hintText: '03XXXXXXXXX',
                  hintStyle: TextStyle(
                      fontSize: 15.sp, color: Colors.grey.shade300),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _jcBg,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text('+92',
                          style: TextStyle(
                              fontSize: 13.sp, fontWeight: FontWeight.w700,
                              color: _primary)),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 18.h),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter number';
                  if (val.length < 10) return 'Enter valid number';
                  return null;
                },
              ),
            ).animate().fadeIn(delay: 250.ms),

            SizedBox(height: 32.h),

            // ── Submit Button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: wallet.otpLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                child: wallet.otpLoading
                    ? Utils.loadingLottie(size: 40)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_outlined,
                              color: Colors.white, size: 18.r),
                          SizedBox(width: 8.w),
                          Text('Send Verification Code',
                              style: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            SizedBox(height: 12.h),
            Center(
              child: Text(
                'A 6-digit OTP will be sent to your number',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // ── OTP Screen ─────────────────────────────────────────────────────────────
  Widget _buildOtpScreen(WalletProvider wallet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          SizedBox(height: 20.h),

          // Icon
          Container(
            width: 90.r, height: 90.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primaryColor.withOpacity(0.8),
                    AppColor.primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Icon(Icons.lock_outlined, color: Colors.white, size: 38.r),
          ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),

          SizedBox(height: 20.h),
          Text('Verify Withdrawal',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E))),
          SizedBox(height: 8.h),
          Text(
            'Enter the OTP sent to\n${_phoneController.text}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),

          SizedBox(height: 12.h),
          // Amount preview
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColor.primaryColor.withOpacity(0.2)),
            ),
            child: Text(
              'Rs ${_amountController.text} via $_method',
              style: TextStyle(
                  fontSize: 15.sp, fontWeight: FontWeight.w700,
                  color: AppColor.primaryColor),
            ),
          ),

          SizedBox(height: 32.h),

          // OTP Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12, offset: const Offset(0, 3))],
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
                  fontSize: 28.sp, fontWeight: FontWeight.w800,
                  letterSpacing: 8, color: const Color(0xFF1A1A2E)),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: TextStyle(
                    fontSize: 22.sp, color: Colors.grey.shade300, letterSpacing: 6),
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
                backgroundColor: AppColor.primaryColor,
                disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
              child: wallet.verifyLoading
                  ? Utils.loadingLottie(size: 40)
                  : Text('Confirm Withdrawal',
                      style: TextStyle(fontSize: 16.sp,
                          fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),

          SizedBox(height: 16.h),
          TextButton(
            onPressed: wallet.otpLoading ? null : _sendOtp,
            child: Text(
              wallet.otpLoading ? 'Sending...' : 'Resend OTP',
              style: TextStyle(fontSize: 14.sp, color: AppColor.primaryColor,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E)));
}

// ── Success Sheet ─────────────────────────────────────────────────────────────
class _WithdrawSuccessSheet extends StatelessWidget {
  final double amount;
  final String method, name, phone, txnId;

  const _WithdrawSuccessSheet({
    required this.amount, required this.method,
    required this.name, required this.phone, required this.txnId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.r, 16.r, 24.r, 24.r),
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
          // Handle
          Container(
            width: 40.w, height: 4.h,
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(height: 24.h),

          // Success icon
          Container(
            width: 80.r, height: 80.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 40.r),
          ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),

          SizedBox(height: 16.h),
          Text('Request Submitted!',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E))),
          SizedBox(height: 6.h),
          Text(
            'Your withdrawal is pending admin approval',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),

          // Details card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                _DetailRow('Amount', 'Rs ${amount.toStringAsFixed(0)}',
                    valueColor: AppColor.primaryColor),
                SizedBox(height: 10.h),
                _DetailRow('Method', method),
                SizedBox(height: 10.h),
                _DetailRow('Recipient', name),
                SizedBox(height: 10.h),
                _DetailRow('Account', phone),
                SizedBox(height: 10.h),
                _DetailRow('Status', '⏳ Pending Approval',
                    valueColor: Colors.orange),
                SizedBox(height: 10.h),
                _DetailRow('Ref ID', txnId),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Info note
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'You will be notified once your withdrawal is approved. Funds will be transferred within 1-2 business days.',
                    style: TextStyle(fontSize: 11.sp, color: Colors.blue[700],
                        height: 1.5),
                  ),
                ),
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
                    borderRadius: BorderRadius.circular(14.r)),
                elevation: 0,
              ),
              child: Text('Done',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500)),
      Text(value,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF1A1A2E))),
    ],
  );
}