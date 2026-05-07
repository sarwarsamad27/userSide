// view/dashboard/userChat/refundRequestCard.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/userChat_provider.dart';
import '../../../models/chatModel/chatModel.dart';
import 'full_image.dart';

class RefundRequestCard extends StatelessWidget {
  final ChatMessage message;
  const RefundRequestCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final data = message.refundData;
    final p = context.read<UserChatProvider>();

    if (data == null) return _buildSystemMessage(message.text ?? "Refund request");

    final statusInfo = _getStatusInfo(data.status);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.08), Colors.blue.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusInfo.color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.account_balance_wallet_rounded, color: Colors.blue, size: 22.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Refund Request",
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.blue)),
                    Text(p.formatTime(data.createdAt),
                        style: TextStyle(fontSize: 11.sp, color: Colors.black45)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: statusInfo.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: statusInfo.color, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusInfo.icon, size: 12.sp, color: statusInfo.color),
                    SizedBox(width: 4.w),
                    Text(statusInfo.label,
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: statusInfo.color)),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.black12),
          SizedBox(height: 10.h),

          _buildInfoRow(Icons.receipt_long, "Order ID", data.orderId ?? "N/A"),
          SizedBox(height: 6.h),
          _buildInfoRow(Icons.inventory_2, "Product", data.productName ?? "N/A"),
          SizedBox(height: 6.h),
          if (data.reasonCategory != null) ...[
            _buildInfoRow(Icons.category, "Category", data.reasonCategoryLabel),
            SizedBox(height: 6.h),
          ],
          _buildInfoRow(Icons.description, "Reason", data.reason ?? "N/A", maxLines: 3),

          // ✅ Refund amount
          if (data.refundAmount != null && data.refundAmount! > 0) ...[
            SizedBox(height: 6.h),
            _buildInfoRow(Icons.currency_rupee_rounded, "Refund Amount",
                "Rs ${data.refundAmount!.toStringAsFixed(0)}"),
          ],

          // ── Images ──────────────────────────────────────────
          if (data.images.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text("Product Photos",
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 8.w,
              ),
              itemBuilder: (_, i) {
                final url = Global.getImageUrl(data.images[i]);
                return InkWell(
                  onTap: () => _openImageViewer(context, data.images, i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(url, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: Colors.black.withOpacity(0.05),
                            child: Icon(Icons.broken_image, size: 24.sp))),
                  ),
                );
              },
            ),
          ],

          SizedBox(height: 12.h),

          // ── Status Banner ────────────────────────────────────
          _buildStatusBanner(context, data, p),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, RefundRequestData data, UserChatProvider p) {
    final status = data.status ?? '';

    switch (status.toLowerCase()) {
      case 'pending':
        return _infoContainer(
          color: Colors.orange,
          icon: Icons.hourglass_top_rounded,
          text: "Your refund request is being reviewed.",
        );

      case 'accepted':
        return _infoContainer(
          color: Colors.green,
          icon: Icons.check_circle_outline,
          text: "Refund accepted! Please ship the product back.",
        );

      case 'rejected':
        return _infoContainer(
          color: Colors.red,
          icon: Icons.cancel_outlined,
          text: "Refund rejected${data.companyNote?.isNotEmpty == true ? ': ${data.companyNote}' : '.'}",
        );

      case 'returnshipped':
        return _infoContainer(
          color: Colors.indigo,
          icon: Icons.local_shipping_rounded,
          text: "Return parcel in transit. Awaiting seller confirmation.",
        );

      case 'returnreceived':
        return _infoContainer(
          color: Colors.teal,
          icon: Icons.inventory_2_rounded,
          text: "Seller received your parcel. Inspection in progress.",
        );

      case 'inspecting':
        return _infoContainer(
          color: Colors.purple,
          icon: Icons.search_rounded,
          text: "Product is under inspection.",
        );

      case 'approvedinspection':
        return _infoContainer(
          color: Colors.green,
          icon: Icons.verified_rounded,
          text: "Inspection passed! Refund will be credited soon.",
        );

      case 'disputed':
        return _infoContainer(
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
          text: "Inspection disputed. Admin will resolve within 48 hours.",
        );

      case 'refunded':
        return _infoContainer(
          color: Colors.green,
          icon: Icons.account_balance_wallet_rounded,
          text: data.refundAmount != null && data.refundAmount! > 0
              ? "Rs ${data.refundAmount!.toStringAsFixed(0)} has been credited to your wallet! 💰"
              : "Refund credited to your wallet! 💰",
        );

      case 'completed':
        return _infoContainer(
          color: Colors.green,
          icon: Icons.check_circle_rounded,
          text: "Refund process completed! ✅",
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _infoContainer({required Color color, required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(String? status) {
    switch (status) {
      case 'Pending': return _StatusInfo(Colors.orange, Icons.hourglass_top_rounded, "Pending");
      case 'Accepted': return _StatusInfo(Colors.green, Icons.check_circle_outline, "Accepted");
      case 'Rejected': return _StatusInfo(Colors.red, Icons.cancel_outlined, "Rejected");
      case 'ReturnShipped': return _StatusInfo(Colors.indigo, Icons.local_shipping_rounded, "Return Sent");
      case 'ReturnReceived': return _StatusInfo(Colors.teal, Icons.inventory_2_rounded, "Received");
      case 'Inspecting': return _StatusInfo(Colors.purple, Icons.search_rounded, "Inspecting");
      case 'ApprovedInspection': return _StatusInfo(Colors.green, Icons.verified_rounded, "Approved");
      case 'Disputed': return _StatusInfo(Colors.red, Icons.warning_amber_rounded, "Disputed");
      case 'Refunded': return _StatusInfo(Colors.green, Icons.account_balance_wallet_rounded, "Refunded");
      case 'Completed': return _StatusInfo(Colors.green, Icons.check_circle_rounded, "Completed");
      default: return _StatusInfo(Colors.orange, Icons.pending, "Pending");
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: Colors.black45),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openImageViewer(BuildContext context, List<String> paths, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImageViewerScreen(
          imageUrls: paths.map((path) {
            if (path.startsWith("http://") || path.startsWith("https://")) return path;
            return context.read<UserChatProvider>().imgUrl(path);
          }).toList(),
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20.r)),
        child: Text(text, style: TextStyle(fontSize: 12.sp, color: Colors.black54), textAlign: TextAlign.center),
      ),
    );
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;
  final String label;
  const _StatusInfo(this.color, this.icon, this.label);
}