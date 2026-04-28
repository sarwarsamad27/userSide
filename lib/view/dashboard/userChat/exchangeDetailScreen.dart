// view/dashboard/exchange/exchange_detail_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_side/models/chatModel/exchangeRequestModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/view/dashboard/profile/order/leopards_tracking_screen.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';
import 'dart:convert';

class ExchangeDetailScreen extends StatefulWidget {
  final String exchangeId;
  const ExchangeDetailScreen({super.key, required this.exchangeId});

  @override
  State<ExchangeDetailScreen> createState() => _ExchangeDetailScreenState();
}

class _ExchangeDetailScreenState extends State<ExchangeDetailScreen> {
  ExchangeRequest? _exchange;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExchange());
  }

  Future<void> _loadExchange() async {
    setState(() => _loading = true);
    final buyerId = await LocalStorage.getUserId() ?? "";
    if (buyerId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    await context.read<ExchangeProvider>().fetchMyRequests(buyerId);
    if (!mounted) return;
    final list = context.read<ExchangeProvider>().listModel?.requests ?? [];
    final found = list.where((r) => r.id == widget.exchangeId).firstOrNull;
    setState(() {
      _exchange = found;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Exchange Details",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            )
          : _exchange == null
          ? _buildNotFound()
          : RefreshIndicator(
              onRefresh: _loadExchange,
              color: AppColor.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusTimeline(),
                    SizedBox(height: 16.h),
                    _buildInfoCard(),
                    SizedBox(height: 16.h),
                    if (_exchange!.courierPaidBy != null) _buildCourierCard(),
                    if (_exchange!.isAccepted) ...[
                      SizedBox(height: 16.h),
                      _buildReturnProofSection(),
                    ],
                    if (_exchange!.isReturnShipped ||
                        _exchange!.isReturnReceived ||
                        _exchange!.isInspecting ||
                        _exchange!.isApprovedInspection) ...[
                      SizedBox(height: 16.h),
                      _buildReturnTrackingCard(),
                    ],
                    if (_exchange!.isReplacementShipped) ...[
                      SizedBox(height: 16.h),
                      _buildReplacementTrackingCard(),
                    ],
                    if (_exchange!.isRefunded || _exchange!.isCompleted) ...[
                      SizedBox(height: 16.h),
                      _buildCompletionCard(),
                    ],
                    if (_exchange!.isDisputed) ...[
                      SizedBox(height: 16.h),
                      _buildDisputeCard(),
                    ],
                    if (_exchange!.images.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _buildImagesSection(
                        "Your Product Photos",
                        _exchange!.images,
                      ),
                    ],
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Status Timeline ──────────────────────────────────────────
  Widget _buildStatusTimeline() {
    final steps = [
      _TimelineStep("Requested", "Pending"),
      _TimelineStep("Accepted", "Accepted"),
      _TimelineStep("Return Shipped", "ReturnShipped"),
      _TimelineStep("Received", "ReturnReceived"),
      _TimelineStep("Inspecting", "Inspecting"),
      if (_exchange!.resolutionType == "replacement")
        _TimelineStep("Replacement Shipped", "ReplacementShipped")
      else
        _TimelineStep("Refunded", "Refunded"),
      _TimelineStep("Completed", "Completed"),
    ];

    final statusOrder = [
      "Pending",
      "Accepted",
      "ReturnShipped",
      "ReturnReceived",
      "Inspecting",
      "ApprovedInspection",
      if (_exchange!.resolutionType == "replacement")
        "ReplacementShipped"
      else
        "Refunded",
      "Completed",
    ];

    final currentIndex = statusOrder.indexOf(_exchange!.status ?? "");

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Progress",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final stepIndex = statusOrder.indexOf(step.status);
            final isDone = currentIndex >= stepIndex && stepIndex != -1;
            final isCurrent =
                _exchange!.status == step.status ||
                (_exchange!.status == "ApprovedInspection" &&
                    step.status == "Inspecting");
            final isLast = i == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColor.primaryColor
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(
                                color: AppColor.primaryColor,
                                width: 2.w,
                              )
                            : null,
                      ),
                      child: Icon(
                        isDone ? Icons.check : Icons.circle,
                        size: 14.sp,
                        color: isDone ? Colors.white : Colors.grey[400],
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2.w,
                        height: 32.h,
                        color: isDone
                            ? AppColor.primaryColor
                            : Colors.grey[200],
                      ),
                  ],
                ),
                SizedBox(width: 12.w),
                Padding(
                  padding: EdgeInsets.only(top: 2.h, bottom: isLast ? 0 : 24.h),
                  child: Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCurrent
                          ? AppColor.primaryColor
                          : isDone
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          }),

          // Denied state
          if (_exchange!.isDenied)
            Container(
              margin: EdgeInsets.only(top: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Request Rejected${_exchange!.companyNote?.isNotEmpty == true ? ': ${_exchange!.companyNote}' : ''}",
                      style: TextStyle(fontSize: 13.sp, color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return _buildCard(
      title: "Request Details",
      icon: Icons.info_outline,
      children: [
        _infoRow("Reason", _exchange!.reason ?? "N/A"),
        _infoRow(
          "Reason Type",
          _reasonCategoryLabel(_exchange!.reasonCategory),
        ),
        if (_exchange!.resolutionType != null)
          _infoRow(
            "Resolution",
            _exchange!.resolutionType == "refund"
                ? "Wallet Refund"
                : "Replacement Product",
          ),
        if (_exchange!.companyNote?.isNotEmpty == true)
          _infoRow("Company Note", _exchange!.companyNote!),
      ],
    );
  }

  // ── Courier Card ──────────────────────────────────────────────
  Widget _buildCourierCard() {
    final isBuyerPays = _exchange!.courierPaidBy == "buyer";
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isBuyerPays ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isBuyerPays ? Colors.orange[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: isBuyerPays ? Colors.orange[700] : Colors.green[700],
            size: 22.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Courier Cost",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: isBuyerPays ? Colors.orange[800] : Colors.green[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _exchange!.courierCostLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isBuyerPays ? Colors.orange[700] : Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Return Proof Section ──────────────────────────────────────
  Widget _buildReturnProofSection() {
    final ex = _exchange!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ex.returnTrackingNumber?.isNotEmpty == true ||
            ex.returnSlipLink?.isNotEmpty == true) ...[
          _buildLeopardsCard(ex),
          SizedBox(height: 12.h),
        ],
        // ── Proof photos upload ─────────────────────────────────
        _ReturnProofWidget(exchange: ex, onSuccess: _loadExchange),
      ],
    );
  }

  // ── Return Tracking Card ──────────────────────────────────────
  Widget _buildReturnTrackingCard() {
    return _buildCard(
      title: "Return Shipping",
      icon: Icons.local_shipping,
      children: [
        if (_exchange!.returnTrackingNumber?.isNotEmpty == true)
          _infoRow(
            "Tracking #",
            _exchange!.returnTrackingNumber!,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LeopardsTrackingScreen(
                  trackNumber: _exchange!.returnTrackingNumber!,
                ),
              ),
            ),
          ),
        if (_exchange!.returnCourierName?.isNotEmpty == true)
          _infoRow("Courier", _exchange!.returnCourierName!),
        if (_exchange!.returnShippedAt != null)
          _infoRow("Shipped At", _formatDate(_exchange!.returnShippedAt)),
        if (_exchange!.receivedAt != null)
          _infoRow("Received At", _formatDate(_exchange!.receivedAt)),
        if (_exchange!.inspectionNote?.isNotEmpty == true)
          _infoRow("Inspection Note", _exchange!.inspectionNote!),
      ],
    );
  }

  // ── Replacement Tracking Card ─────────────────────────────────
  Widget _buildReplacementTrackingCard() {
    return _buildCard(
      title: "Replacement Shipping 🚀",
      icon: Icons.replay_circle_filled_outlined,
      iconColor: Colors.green,
      children: [
        if (_exchange!.replacementTrackingNumber?.isNotEmpty == true)
          _infoRow(
            "Tracking #",
            _exchange!.replacementTrackingNumber!,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LeopardsTrackingScreen(
                  trackNumber: _exchange!.replacementTrackingNumber!,
                ),
              ),
            ),
          ),
        if (_exchange!.replacementCourierName?.isNotEmpty == true)
          _infoRow("Courier", _exchange!.replacementCourierName!),
        if (_exchange!.replacementShippedAt != null)
          _infoRow("Shipped At", _formatDate(_exchange!.replacementShippedAt)),

        // ✅ Leopards replacement slip download
        if (_exchange!.replacementSlipLink?.isNotEmpty == true) ...[
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(_exchange!.replacementSlipLink!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: Icon(Icons.download_rounded, size: 16.sp),
              label: const Text("Download Replacement Slip"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Completion Card ───────────────────────────────────────────
  Widget _buildCompletionCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 32.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _exchange!.isRefunded ? "Refund Processed" : "Completed",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                if (_exchange!.refundAmount != null &&
                    _exchange!.refundAmount! > 0)
                  Text(
                    "Rs ${_exchange!.refundAmount!.toStringAsFixed(0)} refunded to your wallet",
                    style: TextStyle(fontSize: 13.sp, color: Colors.green[700]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Dispute Card ──────────────────────────────────────────────
  Widget _buildDisputeCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red[700], size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                "Inspection Disputed",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
          if (_exchange!.disputeNote?.isNotEmpty == true) ...[
            SizedBox(height: 8.h),
            Text(
              _exchange!.disputeNote!,
              style: TextStyle(fontSize: 13.sp, color: Colors.red[700]),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            "Admin will review and resolve within 48 hours.",
            style: TextStyle(fontSize: 12.sp, color: Colors.red[400]),
          ),
        ],
      ),
    );
  }

  // ── Images Section ────────────────────────────────────────────
  Widget _buildImagesSection(String title, List<String> images) {
    return _buildCard(
      title: title,
      icon: Icons.photo_library_outlined,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: images.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
          ),
          itemBuilder: (_, i) {
            final url = images[i].startsWith("http")
                ? images[i]
                : Global.getImageUrl(images[i]);
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 24.sp,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: iconColor ?? AppColor.primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Divider(height: 20.h, color: Colors.grey[100]),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110.w,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: onTap != null ? AppColor.primaryColor : Colors.black87,
                  fontWeight: FontWeight.w600,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "Request not found",
            style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? s) {
    if (s == null) return "N/A";
    try {
      final d = DateTime.parse(s);
      return "${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return s;
    }
  }

  String _reasonCategoryLabel(String? cat) {
    switch (cat) {
      case "seller_fault":
        return "Wrong Item Received";
      case "defective":
        return "Defective / Damaged";
      case "buyer_preference":
        return "Changed My Mind";
      case "size_color":
        return "Wrong Size / Color";
      default:
        return cat ?? "N/A";
    }
  }

  Widget _buildLeopardsCard(ExchangeRequest ex) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.blue[700], size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                "📦 Return Booked via Leopards",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          if (ex.returnSlipLink?.isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            Text(
              "Please submit this product to your nearest Leopards drop-off point. Use the return label below.",
              style: TextStyle(fontSize: 12.sp, color: Colors.blue[600]),
            ),
          ],
          if (ex.returnTrackingNumber?.isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 14.sp,
                  color: Colors.blue[400],
                ),
                SizedBox(width: 6.w),
                Text(
                  "Track #",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                SizedBox(width: 4.w),
                Text(
                  ex.returnTrackingNumber!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ],
          if (ex.returnSlipLink?.isNotEmpty == true) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(ex.returnSlipLink!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: Icon(Icons.download_rounded, size: 16.sp),
                label: const Text("Download Return Label"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  side: BorderSide(color: Colors.blue[400]!),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Return Proof Widget ───────────────────────────────────────────────────────
class _ReturnProofWidget extends StatefulWidget {
  final ExchangeRequest exchange;
  final VoidCallback onSuccess;

  const _ReturnProofWidget({required this.exchange, required this.onSuccess});

  @override
  State<_ReturnProofWidget> createState() => _ReturnProofWidgetState();
}

class _ReturnProofWidgetState extends State<_ReturnProofWidget> {
  final _picker = ImagePicker();
  List<XFile> _images = [];
  final _trackingController = TextEditingController();
  final _courierController = TextEditingController(text: "Leopards");

  @override
  void initState() {
    super.initState();
    if (widget.exchange.returnTrackingNumber?.isNotEmpty == true) {
      _trackingController.text = widget.exchange.returnTrackingNumber!;
    }
    if (widget.exchange.returnCourierName?.isNotEmpty == true) {
      _courierController.text = widget.exchange.returnCourierName!;
    }
  }

  @override
  void dispose() {
    _trackingController.dispose();
    _courierController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) {
      PremiumToast.error(context, "Maximum 5 images");
      return;
    }
    final files = await _picker.pickMultiImage(imageQuality: 75);
    if (files.isEmpty) return;
    final remaining = 5 - _images.length;
    setState(() {
      _images = [..._images, ...files.take(remaining)];
    });
  }

  Future<List<String>> _toBase64() async {
    final List<String> result = [];
    for (final x in _images) {
      final bytes = await File(x.path).readAsBytes();
      result.add("data:image/jpg;base64,${base64Encode(bytes)}");
    }
    return result;
  }

  Future<void> _submit() async {
    final buyerId = await LocalStorage.getUserId() ?? "";
    if (buyerId.isEmpty) return;

    final images = await _toBase64();

    final ok = await context.read<ExchangeProvider>().uploadReturnProof(
      exchangeId: widget.exchange.id ?? "",
      buyerId: buyerId,
      trackingNumber: widget.exchange.returnTrackingNumber ?? "",
      courierName: widget.exchange.returnCourierName ?? "Leopards",
      proofImages: images,
    );

    if (!mounted) return;

    if (ok) {
      PremiumToast.success(context, "Parcel photos uploaded!");
      widget.onSuccess();
    } else {
      final err =
          context.read<ExchangeProvider>().errorMessage ?? "Upload failed";
      PremiumToast.error(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploading = context.select<ExchangeProvider, bool>(
      (p) => p.uploadingProof,
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_camera_outlined,
                color: Colors.blue[700],
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Attach Proof Photos",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "Take photos of the packed parcel before handing it to the courier.",
            style: TextStyle(fontSize: 12.sp, color: Colors.blue[600]),
          ),
          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Parcel Photos (${_images.length}/5)",
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: uploading ? null : _pickImages,
                icon: Icon(Icons.add_photo_alternate, size: 18.sp),
                label: const Text("Add"),
              ),
            ],
          ),
          if (_images.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 8.w,
              ),
              itemBuilder: (_, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      File(_images[i].path),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: uploading
                          ? null
                          : () => setState(() => _images.removeAt(i)),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: uploading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: uploading
                  ? Utils.loadingLottie(size: 24)
                  : Text(
                      "Submit Return Proof",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: ctrl,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18.sp),
            hintText: "Enter $label",
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep {
  final String label;
  final String status;
  const _TimelineStep(this.label, this.status);
}
