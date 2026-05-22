// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/chatModel/exchangeRequestModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/view/dashboard/profile/order/leopards_tracking_screen.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RefundDetailScreen extends StatefulWidget {
  final String refundId;
  const RefundDetailScreen({super.key, required this.refundId});

  @override
  State<RefundDetailScreen> createState() => _RefundDetailScreenState();
}

class _RefundDetailScreenState extends State<RefundDetailScreen> {
  ExchangeRequest? _refund;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRefund());
  }

  Future<void> _loadRefund() async {
    setState(() => _loading = true);
    final buyerId = await LocalStorage.getUserId() ?? "";
    if (buyerId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    await context.read<ExchangeProvider>().fetchMyRefunds(buyerId);
    if (!mounted) return;
    final list =
        context.read<ExchangeProvider>().refundListModel?.requests ?? [];
    final found = list.where((r) => r.id == widget.refundId).firstOrNull;
    setState(() {
      _refund = found;
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
          "Refund Details",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            )
          : _refund == null
          ? _buildNotFound()
          : RefreshIndicator(
              onRefresh: _loadRefund,
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

                    // Refund Slip (PDF) — only if no return label yet
                    if (_refund!.pdfPath?.isNotEmpty == true &&
                        _refund!.returnSlipLink?.isEmpty == true) ...[
                      _buildSlipDownloadCard(
                        label: "Download Refund Slip",
                        pdfUrl: _refund!.pdfPath!,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Accepted: return proof + download label
                    if (_refund!.isAccepted) ...[
                      _buildReturnProofSection(),
                      SizedBox(height: 16.h),
                    ],

                    // ReturnShipped: show tracking info
                    if (_refund!.isReturnShipped) ...[
                      _buildReturnTrackingCard(),
                      SizedBox(height: 16.h),
                    ],

                    // ReturnReceived: parcel received, refund being processed
                    if (_refund!.isReturnReceived) ...[
                      _buildReceivedProcessingCard(),
                      SizedBox(height: 16.h),
                    ],

                    // Refunded: wallet credited
                    if (_refund!.isRefunded || _refund!.isCompleted) ...[
                      _buildRefundCompleteCard(),
                      SizedBox(height: 16.h),
                    ],

                    // Rejected
                    if (_refund!.isDenied) ...[
                      _buildRejectedCard(),
                      SizedBox(height: 16.h),
                    ],

                    // ✅ Images
                    if (_refund!.images.isNotEmpty) ...[
                      _buildImagesSection(
                        "Your Product Photos",
                        _refund!.images,
                      ),
                      SizedBox(height: 16.h),
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
      _Step("Requested", "Pending", Icons.send_rounded),
      _Step("Accepted", "Accepted", Icons.check_circle_outline),
      _Step("Ship Item", "ReturnShipped", Icons.local_shipping_rounded),
      _Step("Received", "ReturnReceived", Icons.inventory_2_rounded),
    ];

    // Refunded/Completed map to index >= 3 so all 4 steps show filled
    final statusOrder = [
      "Pending",
      "Accepted",
      "ReturnShipped",
      "ReturnReceived",
      "Refunded",
      "Completed",
    ];

    final currentIndex = statusOrder.indexOf(_refund!.status ?? "");
    final isDenied = _refund!.isDenied;

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
            "Refund Progress",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),

          if (isDenied)
            Container(
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
                      "Refund Rejected${_refund!.companyNote?.isNotEmpty == true ? ': ${_refund!.companyNote}' : ''}",
                      style: TextStyle(fontSize: 13.sp, color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(steps.length, (i) {
                  final step = steps[i];
                  final stepIndex = statusOrder.indexOf(step.status);
                  final isDone = currentIndex >= stepIndex && stepIndex != -1;
                  final isCurrent =
                      _refund!.status == step.status ||
                      (_refund!.status == "ApprovedInspection" &&
                          step.status == "Inspecting");
                  final isLast = i == steps.length - 1;

                  return Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isCurrent ? 34.w : 28.w,
                            height: isCurrent ? 34.w : 28.w,
                            decoration: BoxDecoration(
                              color: isDone ? Colors.blue : Colors.grey[200],
                              shape: BoxShape.circle,
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              step.icon,
                              size: isCurrent ? 17.sp : 14.sp,
                              color: isDone ? Colors.white : Colors.grey[400],
                            ),
                          ),
                          SizedBox(height: 5.h),
                          SizedBox(
                            width: 52.w,
                            child: Text(
                              step.label,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: isDone ? Colors.blue : Colors.grey[400],
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (!isLast)
                        Container(
                          width: 18.w,
                          height: 2,
                          margin: EdgeInsets.only(bottom: 22.h),
                          color: i < currentIndex
                              ? Colors.blue
                              : Colors.grey[200],
                        ),
                    ],
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return _buildCard(
      title: "Refund Details",
      icon: Icons.info_outline,
      children: [
        _infoRow("Reason", _refund!.reason ?? "N/A"),
        _infoRow("Category", _reasonLabel(_refund!.reasonCategory)),
        if (_refund!.resolutionType != null)
          _infoRow(
            "Resolution",
            _refund!.resolutionType == "refund"
                ? "Wallet Refund"
                : "Replacement",
          ),
        if (_refund!.refundAmount != null && _refund!.refundAmount! > 0)
          _infoRow(
            "Refund Amount",
            "Rs ${_refund!.refundAmount!.toStringAsFixed(0)}",
            valueColor: Colors.green,
          ),
        if (_refund!.companyNote?.isNotEmpty == true)
          _infoRow("Seller Note", _refund!.companyNote!),
        if (_refund!.courierPaidBy != null) ...[
          SizedBox(height: 8.h),
          _buildCourierBanner(_refund!.courierPaidBy!),
        ],
      ],
    );
  }

  Widget _buildCourierBanner(String courierPaidBy) {
    final isBuyer = courierPaidBy == "buyer";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isBuyer ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isBuyer ? Colors.orange[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 16.sp,
            color: isBuyer ? Colors.orange[700] : Colors.green[700],
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isBuyer
                  ? "Return courier cost: Your responsibility"
                  : "Seller will cover all courier costs",
              style: TextStyle(
                fontSize: 12.sp,
                color: isBuyer ? Colors.orange[700] : Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Return Proof Section ──────────────────────────────────────
  Widget _buildReturnProofSection() {
    final refund = _refund!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (refund.returnTrackingNumber?.isNotEmpty == true ||
            refund.returnSlipLink?.isNotEmpty == true) ...[
          _buildLeopardsCard(refund),
          SizedBox(height: 12.h),
        ],

        // ── Proof photos upload ─────────────────────────────────
        _RefundReturnProofWidget(refund: refund, onSuccess: _loadRefund),
      ],
    );
  }

  // ── Return Tracking Card ──────────────────────────────────────
  Widget _buildReturnTrackingCard() {
    return _buildCard(
      title: "Return Shipping Info",
      icon: Icons.local_shipping_rounded,
      children: [
        if (_refund!.returnTrackingNumber?.isNotEmpty == true)
          _infoRow(
            "Tracking #",
            _refund!.returnTrackingNumber!,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LeopardsTrackingScreen(
                  trackNumber: _refund!.returnTrackingNumber!,
                ),
              ),
            ),
          ),
        if (_refund!.returnCourierName?.isNotEmpty == true)
          _infoRow("Courier", _refund!.returnCourierName!),
        if (_refund!.receivedAt != null)
          _infoRow("Received At", _formatDate(_refund!.receivedAt)),
        if (_refund!.inspectionNote?.isNotEmpty == true)
          _infoRow("Inspection Note", _refund!.inspectionNote!),
      ],
    );
  }

  // ── Received Processing Card ──────────────────────────────────
  Widget _buildReceivedProcessingCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.teal[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_rounded, color: Colors.teal[700], size: 32.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Parcel Received",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Your return has been received. Refund will be credited to your wallet shortly.",
                  style: TextStyle(fontSize: 13.sp, color: Colors.teal[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Refund Complete Card ──────────────────────────────────────
  Widget _buildRefundCompleteCard() {
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
                  "Refund Credited to Wallet",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                if (_refund!.refundAmount != null &&
                    _refund!.refundAmount! > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    "Rs ${_refund!.refundAmount!.toStringAsFixed(0)} has been added to your wallet",
                    style: TextStyle(fontSize: 13.sp, color: Colors.green[700]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Rejected Card ─────────────────────────────────────────────
  Widget _buildRejectedCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel, color: Colors.red, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Refund Rejected",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                if (_refund!.companyNote?.isNotEmpty == true) ...[
                  SizedBox(height: 4.h),
                  Text(
                    _refund!.companyNote!,
                    style: TextStyle(fontSize: 13.sp, color: Colors.red[700]),
                  ),
                ],
              ],
            ),
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
              Icon(icon, size: 20.sp, color: AppColor.primaryColor),
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

  Widget _infoRow(
    String label,
    String value, {
    Color? valueColor,
    VoidCallback? onTap,
  }) {
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
                  color: onTap != null
                      ? AppColor.primaryColor
                      : (valueColor ?? Colors.black87),
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

  // ── Download Slip Button ──────────────────────────────────────
  Widget _buildSlipDownloadCard({
    required String label,
    required String pdfUrl,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        final fileName = "refund_${widget.refundId}_slip.pdf";
        context.read<ExchangeProvider>().downloadSlipDirect(
          pdfUrl: pdfUrl,
          fileName: fileName,
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
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
            "Refund request not found",
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

  String _reasonLabel(String? cat) {
    switch (cat) {
      case "seller_fault":
        return "Wrong Item Received";
      case "defective":
        return "Defective / Damaged";
      case "buyer_preference":
        return "Changed My Mind";
      case "size_color":
        return "Wrong Size / Color";
      case "size_issue":
        return "Size Issue";
      case "wrong_item":
        return "Different Product";
      default:
        return cat ?? "N/A";
    }
  }

  Widget _buildLeopardsCard(ExchangeRequest rf) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.indigo[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.indigo[700],
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Leopards Return Label",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[900],
                      ),
                    ),
                    Text(
                      "Ready for download",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.indigo[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            "Please print this label and attach it firmly to your parcel. You can drop off the parcel at any Leopards Courier center.",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          if (rf.returnTrackingNumber?.isNotEmpty == true) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.tag, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    "Tracking Number:",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    rf.returnTrackingNumber!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (rf.returnSlipLink?.isNotEmpty == true) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final trackNo = rf.returnTrackingNumber ?? '';
                  final fullUrl = trackNo.isNotEmpty
                      ? Global.downloadSlip(trackNo)
                      : Global.getImageUrl(rf.returnSlipLink);
                  final uri = Uri.parse(fullUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: Icon(Icons.picture_as_pdf_rounded, size: 20.sp),
                label: Text(
                  "Download Return Label",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 14.sp, color: Colors.grey),
                SizedBox(width: 6.w),
                Text(
                  "This button will be removed after proof submission",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Return Proof Widget
// ─────────────────────────────────────────────────────────────────────────────
class _RefundReturnProofWidget extends StatefulWidget {
  final ExchangeRequest refund;
  final VoidCallback onSuccess;

  const _RefundReturnProofWidget({
    required this.refund,
    required this.onSuccess,
  });

  @override
  State<_RefundReturnProofWidget> createState() =>
      _RefundReturnProofWidgetState();
}

class _RefundReturnProofWidgetState extends State<_RefundReturnProofWidget> {
  final _picker = ImagePicker();
  List<XFile> _images = [];
  final _trackingController = TextEditingController();
  final _courierController = TextEditingController(text: "Leopards");

  @override
  void initState() {
    super.initState();
    if (widget.refund.returnTrackingNumber?.isNotEmpty == true) {
      _trackingController.text = widget.refund.returnTrackingNumber!;
    }
    if (widget.refund.returnCourierName?.isNotEmpty == true) {
      _courierController.text = widget.refund.returnCourierName!;
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
    setState(() => _images = [..._images, ...files.take(remaining)]);
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
    final provider = context.read<ExchangeProvider>(); // capture before async
    final buyerId = await LocalStorage.getUserId() ?? "";
    if (buyerId.isEmpty) return;

    final images = await _toBase64();

    final ok = await provider.uploadRefundReturnProof(
      refundId: widget.refund.id ?? "",
      buyerId: buyerId,
      trackingNumber: widget.refund.returnTrackingNumber ?? "",
      courierName: widget.refund.returnCourierName ?? "Leopards",
      proofImages: images,
    );

    if (!mounted) return;

    if (ok) {
      PremiumToast.success(context, "Parcel photos uploaded! ✅");
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
}

class _Step {
  final String label;
  final String status;
  final IconData icon;
  const _Step(this.label, this.status, this.icon);
}
