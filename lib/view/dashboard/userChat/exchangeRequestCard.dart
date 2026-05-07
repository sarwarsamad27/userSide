// view/dashboard/userChat/exchangeRequestCard.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/userChat_provider.dart';
import '../../../models/chatModel/chatModel.dart';
import 'full_image.dart';

class ExchangeRequestCard extends StatelessWidget {
  final ChatMessage message;
  const ExchangeRequestCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final data = message.exchangeData;
    final p = context.read<UserChatProvider>();

    if (data == null) return _buildSystemMessage(message.text ?? "Exchange request");

    final statusInfo = _getStatusInfo(data.status);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.08),
            AppColor.primaryColor.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.swap_horiz, color: AppColor.primaryColor, size: 22.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Exchange Request",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    Text(
                      p.formatTime(data.createdAt),
                      style: TextStyle(fontSize: 11.sp, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              // ✅ Status chip
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
                    Text(
                      statusInfo.label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: statusInfo.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.black12),
          SizedBox(height: 10.h),

          // ── Info Rows ───────────────────────────────────────
          _buildInfoRow(Icons.receipt_long, "Order ID", data.orderId ?? "N/A"),
          SizedBox(height: 6.h),
          _buildInfoRow(Icons.inventory_2, "Product", data.productName ?? "N/A"),
          SizedBox(height: 6.h),
          _buildInfoRow(Icons.description, "Reason", data.reason ?? "N/A", maxLines: 3),

          // ✅ Resolution type
          if (data.resolutionType != null) ...[
            SizedBox(height: 6.h),
            _buildInfoRow(
              data.resolutionType == "refund"
                  ? Icons.account_balance_wallet_outlined
                  : Icons.inventory_2_outlined,
              "Resolution",
              data.resolutionType == "refund" ? "Wallet Refund" : "Replacement",
            ),
          ],

          // ✅ Courier cost
          if (data.courierPaidBy != null) ...[
            SizedBox(height: 8.h),
            _buildCourierBanner(data.courierPaidBy!),
          ],

          // ── Images ─────────────────────────────────────────
          if (data.images.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text("Images",
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

          // ── Status-based Action Banner ──────────────────────
          _buildStatusBanner(context, data, p),
        ],
      ),
    );
  }

  // ✅ Status-based banners
  Widget _buildStatusBanner(BuildContext context, ExchangeRequestData data, UserChatProvider p) {
    final status = data.status ?? '';

    switch (status.toLowerCase()) {
      case 'pending':
        return _infoContainer(
          color: Colors.orange,
          icon: Icons.hourglass_top_rounded,
          text: "Your exchange request is being reviewed by the seller.",
        );

      case 'accepted':
        return _infoContainer(
          color: Colors.green,
          icon: Icons.check_circle_outline,
          text: "Request accepted! Please ship the product back to the seller.",
        );

      case 'denied':
        return _infoContainer(
          color: Colors.red,
          icon: Icons.cancel_outlined,
          text: "Request rejected${data.companyNote?.isNotEmpty == true ? ': ${data.companyNote}' : '.'}",
        );

      case 'returnshipped':
        return _infoContainer(
          color: Colors.indigo,
          icon: Icons.local_shipping_rounded,
          text: "Return parcel is in transit. Seller will confirm receipt.",
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
          text: "Product is under inspection by the seller.",
        );

      case 'approvedinspection':
        return _infoContainer(
          color: Colors.green,
          icon: Icons.verified_rounded,
          text: data.resolutionType == "refund"
              ? "Inspection passed! Refund will be credited soon."
              : "Inspection passed! Replacement will be shipped soon.",
        );

      case 'disputed':
        return _infoContainer(
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
          text: "Inspection disputed. Admin will resolve within 48 hours.",
        );

      case 'replacementshipped':
        return _infoContainer(
          color: Colors.indigo,
          icon: Icons.local_shipping_rounded,
          text: "Replacement has been shipped! Track your delivery.",
        );

      case 'refunded':
        return _infoContainer(
          color: Colors.green,
          icon: Icons.account_balance_wallet_rounded,
          text: "Refund has been credited to your wallet! 💰",
        );

      case 'completed':
        return _infoContainer(
          color: Colors.green,
          icon: Icons.check_circle_rounded,
          text: "Exchange process completed successfully! ✅",
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCourierBanner(String courierPaidBy) {
    Color color;
    String text;
    IconData icon;

    switch (courierPaidBy) {
      case "seller":
        color = Colors.green;
        icon = Icons.local_shipping_rounded;
        text = "Courier cost: Seller's responsibility";
        break;
      case "buyer":
        color = Colors.orange;
        icon = Icons.local_shipping_outlined;
        text = "Return courier cost: Your responsibility";
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 8.w),
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

  Widget _infoContainer({
    required Color color,
    required IconData icon,
    required String text,
  }) {
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
      case 'Denied': return _StatusInfo(Colors.red, Icons.cancel_outlined, "Rejected");
      case 'ReturnShipped': return _StatusInfo(Colors.indigo, Icons.local_shipping_rounded, "Return Shipped");
      case 'ReturnReceived': return _StatusInfo(Colors.teal, Icons.inventory_2_rounded, "Received");
      case 'Inspecting': return _StatusInfo(Colors.purple, Icons.search_rounded, "Inspecting");
      case 'ApprovedInspection': return _StatusInfo(Colors.green, Icons.verified_rounded, "Approved");
      case 'Disputed': return _StatusInfo(Colors.red, Icons.warning_amber_rounded, "Disputed");
      case 'ReplacementShipped': return _StatusInfo(Colors.indigo, Icons.local_shipping_rounded, "Replacement Sent");
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