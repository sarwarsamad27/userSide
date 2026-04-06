import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
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

    if (data == null) {
      return _buildSystemMessage(message.text ?? "Refund request");
    }

    Color statusColor;
    IconData statusIcon;
    String statusText;

    final normalizedStatus = (data.status ?? '').toLowerCase();
    if (normalizedStatus == 'accepted' || normalizedStatus == 'approved') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Accepted';
    } else if (normalizedStatus == 'rejected' ||
        normalizedStatus == 'denied' ||
        normalizedStatus == 'reject') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Rejected';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = 'Pending';
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
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
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.blue,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Refund Request",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      p.formatTime(data.createdAt),
                      style: TextStyle(fontSize: 11.sp, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14.sp, color: statusColor),
                    SizedBox(width: 4.w),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.black12),
          SizedBox(height: 12.h),

          _buildInfoRow(Icons.shopping_bag, "Order ID", data.orderId ?? "N/A"),
          SizedBox(height: 8.h),
          _buildInfoRow(
            Icons.inventory_2,
            "Product",
            data.productName ?? "N/A",
          ),
          SizedBox(height: 8.h),
          if (data.reasonCategory != null) ...[
            _buildInfoRow(Icons.category, "Category", data.reasonCategoryLabel),
            SizedBox(height: 8.h),
          ],
          _buildInfoRow(
            Icons.description,
            "Reason",
            data.reason ?? "N/A",
            maxLines: 4,
          ),

          if (data.images.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              "Product Photos",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
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
                final url = p.imgUrl(data.images[i]);
                return InkWell(
                  onTap: () => _openImageViewer(context, data.images, i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black12,
                        child: Icon(
                          Icons.broken_image,
                          size: 26.sp,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          if (normalizedStatus == 'accepted' ||
              normalizedStatus == 'approved') ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => p.downloadRefundSlip(data.refundId ?? ""),
                icon: const Icon(Icons.download, size: 18),
                label: const Text("Download Refund Slip"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFE87A36,
                  ), // Match exactly the exchange slip orange
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.green, size: 20),
                  SizedBox(width: 10.w),
                  const Expanded(
                    child: Text(
                      "Wallet will be credited after the item is collected and inspected.",
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openImageViewer(
    BuildContext context,
    List<String> paths,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImageViewerScreen(
          imageUrls: paths.map((p) {
            if (p.startsWith("http://") || p.startsWith("https://")) return p;
            return "${context.read<UserChatProvider>().imgUrl(p)}";
          }).toList(),
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: Colors.black54),
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemMessage(String text) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
