import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:user_side/models/walletModel/walletModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/view/dashboard/profile/wallet/walletScreen.dart';
import 'package:user_side/viewModel/provider/walletProvider/walletProvider.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _amountCtrl = TextEditingController();
  String? _error;

  static const Color _spBlue = Color(0xFF1E5AFF);

  // final List<int> _quickAmounts = [500, 1000, 2000, 5000];

  // 'safepay' (instant, automatic) or 'bank_transfer' (manual, admin
  // verifies a screenshot before crediting).
  // String _method = 'safepay';
  XFile? _screenshot;
  bool _submittingBankTransfer = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  // Future<void> _startCheckout() async {
  //   setState(() => _error = null);
  //   final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0;

  //   if (amt < 500) {
  //     setState(() => _error = 'Minimum Rs 500');
  //     return;
  //   }
  //   if (amt > 50000) {
  //     setState(() => _error = 'Maximum Rs 50,000');
  //     return;
  //   }

  //   final provider = context.read<WalletProvider>();
  //   final checkout = await provider.initSafepayCheckout(amount: amt);

  //   if (!mounted) return;
  //   if (!checkout.success) {
  //     setState(() => _error = provider.errorMessage.isNotEmpty
  //         ? provider.errorMessage
  //         : 'Could not start payment. Try again.');
  //     return;
  //   }

  //   final result = await Navigator.push<SafepayStatusModel>(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => _SafepayCheckoutScreen(
  //         checkoutUrl: checkout.url,
  //         trackId: checkout.trackId,
  //         amount: amt,
  //       ),
  //     ),
  //   );

  //   if (!mounted || result == null) return;

  //   if (result.isSuccess) {
  //     PremiumToast.success(context, 'Rs ${amt.toStringAsFixed(0)} wallet mein add ho gaye!');
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (_) => const WalletScreen()),
  //       (route) => route.isFirst,
  //     );
  //   } else if (!result.isPending) {
  //     setState(() => _error = result.message.isNotEmpty
  //         ? result.message
  //         : 'Payment could not be confirmed.');
  //   }
  //   // isPending (timed out while polling) — leave the user on this screen;
  //   // the webhook will still credit the wallet once Safepay confirms, and
  //   // the balance will simply update next time they check it.
  // }

  Future<void> _downloadQr() async {
    try {
      final byteData = await rootBundle.load('assets/images/QR_sarwar.jpeg');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shookoo_payment_qr.jpeg');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Shookoo payment QR code');
    } catch (_) {
      if (mounted) PremiumToast.error(context, 'Could not download QR code');
    }
  }

  Future<void> _pickScreenshot() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) setState(() => _screenshot = picked);
  }

  Future<void> _submitBankTransfer() async {
    setState(() => _error = null);
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0;

    if (amt < 100) {
      setState(() => _error = 'Minimum Rs 100');
      return;
    }
    if (amt > 50000) {
      setState(() => _error = 'Maximum Rs 50,000');
      return;
    }
    if (_screenshot == null) {
      setState(() => _error = 'Please attach a payment screenshot');
      return;
    }

    setState(() => _submittingBankTransfer = true);

    final bytes = await _screenshot!.readAsBytes();
    final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    final provider = context.read<WalletProvider>();
    final ok = await provider.submitBankTransfer(
      amount: amt,
      screenshotBase64: base64Image,
    );

    if (!mounted) return;
    setState(() => _submittingBankTransfer = false);

    if (ok) {
      PremiumToast.success(
        context,
        'Request submitted — awaiting admin verification',
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WalletScreen()),
        (route) => route.isFirst,
      );
    } else {
      setState(
        () => _error = provider.errorMessage.isNotEmpty
            ? provider.errorMessage
            : 'Could not submit request. Try again.',
      );
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1A1A2E),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Money',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),

            // ── Method chooser ──────────────────────────────────────────
            // Row(
            //   children: [
            //     Expanded(
            //       child: _methodChip(
            //         label: 'Safepay',
            //         icon: Icons.shield_outlined,
            //         selected: _method == 'safepay',
            //         onTap: () => setState(() {
            //           _method = 'safepay';
            //           _error = null;
            //         }),
            //       ),
            //     ),
            //     SizedBox(width: 10.w),
            //     Expanded(
            //       child: _methodChip(
            //         label: 'Bank Transfer',
            //         icon: Icons.account_balance_outlined,
            //         selected: _method == 'bank_transfer',
            //         onTap: () => setState(() {
            //           _method = 'bank_transfer';
            //           _error = null;
            //         }),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(height: 24.h),

            // if (_method == 'safepay') ...[
            //   Center(
            //     child: Column(children: [
            //       Container(
            //         width: 72.r,
            //         height: 72.r,
            //         decoration: BoxDecoration(
            //           color: const Color(0xFFEAF0FF),
            //           shape: BoxShape.circle,
            //           border: Border.all(
            //               color: _spBlue.withValues(alpha: 0.3), width: 2),
            //         ),
            //         child: Icon(Icons.shield_outlined, color: _spBlue, size: 34.sp),
            //       ),
            //       SizedBox(height: 12.h),
            //       Text('Secure payment via Safepay',
            //           style:
            //               TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
            //     ]),
            //   ),
            //   SizedBox(height: 28.h),

            //   _label('Amount'),
            //   SizedBox(height: 8.h),
            //   TextField(
            //     controller: _amountCtrl,
            //     keyboardType: TextInputType.number,
            //     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            //     style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
            //     decoration: InputDecoration(
            //       prefixText: 'Rs  ',
            //       prefixStyle: TextStyle(
            //           fontSize: 18.sp, fontWeight: FontWeight.w500, color: Colors.grey),
            //       hintText: '500',
            //       filled: true,
            //       fillColor: Colors.white,
            //       border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(14.r),
            //           borderSide: BorderSide.none),
            //       contentPadding: EdgeInsets.all(16.r),
            //     ),
            //     onChanged: (_) => setState(() {}),
            //   ),
            //   SizedBox(height: 10.h),
            //   Wrap(
            //     spacing: 8.w,
            //     runSpacing: 8.h,
            //     children: _quickAmounts
            //         .map((a) => GestureDetector(
            //               onTap: () => setState(() => _amountCtrl.text = '$a'),
            //               child: Container(
            //                 padding:
            //                     EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            //                 decoration: BoxDecoration(
            //                   color: _amountCtrl.text == '$a'
            //                       ? const Color(0xFF1A1A2E)
            //                       : Colors.white,
            //                   borderRadius: BorderRadius.circular(20.r),
            //                   border: Border.all(color: Colors.grey.shade200),
            //                 ),
            //                 child: Text('Rs $a',
            //                     style: TextStyle(
            //                         fontSize: 13.sp,
            //                         fontWeight: FontWeight.w600,
            //                         color: _amountCtrl.text == '$a'
            //                             ? Colors.white
            //                             : const Color(0xFF1A1A2E))),
            //               ),
            //             ))
            //         .toList(),
            //   ),
            //   SizedBox(height: 28.h),

            //   SizedBox(
            //     width: double.infinity,
            //     height: 54.h,
            //     child: ElevatedButton(
            //       onPressed: provider.otpLoading ? null : _startCheckout,
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: _spBlue,
            //         shape:
            //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            //       ),
            //       child: provider.otpLoading
            //           ? SpinKitThreeBounce(color: Colors.white, size: 22.sp)
            //           : Text('Continue to Payment',
            //               style: TextStyle(
            //                   fontSize: 16.sp,
            //                   fontWeight: FontWeight.w700,
            //                   color: Colors.white)),
            //     ),
            //   ),
            // ] else ...[
            // ── Bank Transfer: pay into our account, upload proof ──────
            Text(
              'Scan the QR or transfer to this account, then upload a screenshot as proof. An admin will verify it and credit your wallet.',
              style: TextStyle(fontSize: 12.5.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 16.h),
            Center(
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Image.asset(
                  'assets/images/QR_sarwar.jpeg',
                  height: 170.r,
                  width: 170.r,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Center(
              child: TextButton.icon(
                onPressed: _downloadQr,
                icon: Icon(
                  Icons.download_outlined,
                  size: 16.sp,
                  color: _spBlue,
                ),
                label: Text(
                  'Download QR',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: _spBlue,
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            const BankAccountDetailCard(),
            SizedBox(height: 22.h),

            _label('Amount Sent'),
            SizedBox(height: 8.h),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: 'Rs  ',
                prefixStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                hintText: '500',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(16.r),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 16.h),

            GestureDetector(
              onTap: _pickScreenshot,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _screenshot == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_outlined,
                            color: Colors.grey.shade600,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Upload Payment Screenshot',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(
                              File(_screenshot!.path),
                              width: 44.r,
                              height: 44.r,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Screenshot attached — tap to change',
                              style: TextStyle(
                                color: const Color(0xFF1A1A2E),
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18.sp,
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 28.h),

            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: _submittingBankTransfer ? null : _submitBankTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _spBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: _submittingBankTransfer
                    ? SpinKitThreeBounce(color: Colors.white, size: 22.sp)
                    : Text(
                        'Submit Deposit Request',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            if (_error != null) ...[
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(
    t,
    style: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1A1A2E),
    ),
  );

  // Widget _methodChip({
  //   required String label,
  //   required IconData icon,
  //   required bool selected,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 150),
  //       padding: EdgeInsets.symmetric(vertical: 12.h),
  //       decoration: BoxDecoration(
  //         color: selected ? const Color(0xFF1A1A2E) : Colors.white,
  //         borderRadius: BorderRadius.circular(12.r),
  //         border: Border.all(
  //           color: selected ? const Color(0xFF1A1A2E) : Colors.grey.shade200,
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(icon, color: selected ? Colors.white : Colors.grey.shade700, size: 16.sp),
  //           SizedBox(width: 6.w),
  //           Text(
  //             label,
  //             style: TextStyle(
  //               color: selected ? Colors.white : Colors.grey.shade700,
  //               fontSize: 12.5.sp,
  //               fontWeight: FontWeight.w700,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

/// Platform bank account shown for manual "Bank Transfer" deposits — see
/// the identical widget in personal_project's wallet.dart (seller side).
class BankAccountDetailCard extends StatelessWidget {
  const BankAccountDetailCard({super.key});

  static const _rows = [
    ('Bank', 'Meezan Bank'),
    ('Title', 'SARWAR'),
    ('Account No.', '10380111659062'),
    ('IBAN', 'PK57MEZN0010380111659062'),
    ('Branch', 'SHABBIRABAD BRANCH'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in _rows) ...[
            _detailRow(context, row.$1, row.$2),
            if (row != _rows.last) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: const Color(0xFF1A1A2E),
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied: $value'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Icon(Icons.copy, size: 15.sp, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Safepay Checkout WebView — shows the hosted checkout page while polling
//  the backend for the webhook-confirmed payment status. The wallet is only
//  ever credited server-side once Safepay's webhook confirms the payment —
//  this screen just watches for that to happen.
// ─────────────────────────────────────────────────────────────────────────────
class _SafepayCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;
  final String trackId;
  final double amount;

  const _SafepayCheckoutScreen({
    required this.checkoutUrl,
    required this.trackId,
    required this.amount,
  });

  @override
  State<_SafepayCheckoutScreen> createState() => _SafepayCheckoutScreenState();
}

class _SafepayCheckoutScreenState extends State<_SafepayCheckoutScreen> {
  late final WebViewController _controller;
  late final WalletProvider _provider;
  bool _loading = true;
  bool _verifying = false;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _provider = context.read<WalletProvider>();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          // Safepay redirects here once the checkout flow ends. We never
          // need this page's actual content (the webhook is the source of
          // truth for whether the payment succeeded) — only the fact that
          // a redirect happened, so we check status immediately instead of
          // waiting for the next poll tick. Intercepting this also avoids
          // the WebView failing to load a plain-http page on some Android
          // setups (ERR_CLEARTEXT_NOT_PERMITTED).
          onNavigationRequest: (request) {
            final path = Uri.tryParse(request.url)?.path ?? '';
            if (path.contains('/safepay/success') ||
                path.contains('/safepay/cancel')) {
              _checkStatusNow();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _enableThirdPartyCookies();
    _controller.loadRequest(Uri.parse(widget.checkoutUrl));

    _startPolling();
  }

  // Android WebView blocks third-party cookies by default. Safepay's 3D
  // Secure step (Cardinal Commerce device fingerprinting + step-up iframe)
  // is hosted on a different domain and relies on them to signal back to
  // the parent page — without this, the checkout silently hangs at
  // "Transaction submitted" and never proceeds to success/failure.
  Future<void> _enableThirdPartyCookies() async {
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      final cookieManager = WebViewCookieManager();
      if (cookieManager.platform is AndroidWebViewCookieManager) {
        await (cookieManager.platform as AndroidWebViewCookieManager)
            .setAcceptThirdPartyCookies(platform, true);
      }
    }
  }

  @override
  void dispose() {
    _provider.cancelPolling(widget.trackId);
    super.dispose();
  }

  Future<void> _checkStatusNow() async {
    if (_resolved) return;
    final result = await _provider.pollSafepayStatus(
      widget.trackId,
      maxAttempts: 1,
    );
    if (!mounted || result.isPending) return;
    await _finish(result);
  }

  Future<void> _startPolling() async {
    final result = await _provider.pollSafepayStatus(widget.trackId);
    if (!mounted) return;

    if (result.isPending) {
      // Stopped polling without a terminal result (timeout) — let the user
      // decide whether to keep waiting or leave; the webhook may still land.
      return;
    }

    await _finish(result);
  }

  Future<void> _finish(SafepayStatusModel result) async {
    if (_resolved || !mounted) return;
    _resolved = true;
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.appimagecolor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () =>
              Navigator.pop(context, SafepayStatusModel.error('Cancelled')),
        ),
        title: Text(
          'Rs ${widget.amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_verifying)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16.h),
                    Text(
                      'Confirming payment…',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
