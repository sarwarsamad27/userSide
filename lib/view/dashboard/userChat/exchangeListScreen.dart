// view/dashboard/exchange/my_exchanges_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/chatModel/exchangeRequestModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/view/dashboard/userChat/exchangeDetailScreen.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';

class MyExchangesScreen extends StatefulWidget {
  const MyExchangesScreen({super.key});

  @override
  State<MyExchangesScreen> createState() => _MyExchangesScreenState();
}

class _MyExchangesScreenState extends State<MyExchangesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final buyerId = await LocalStorage.getUserId() ?? "";
      if (buyerId.isNotEmpty && mounted) {
        context.read<ExchangeProvider>().fetchMyRequests(buyerId);
      }
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
        elevation: 0,
        title: Text(
          "My Exchanges",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ExchangeProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            );
          }

          final requests = provider.listModel?.requests ?? [];

          if (requests.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            color: AppColor.primaryColor,
            onRefresh: () async {
              final buyerId = await LocalStorage.getUserId() ?? "";
              if (buyerId.isNotEmpty) {
                await provider.fetchMyRequests(buyerId);
              }
            },
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: requests.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _ExchangeCard(
                  request: requests[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExchangeDetailScreen(
                        exchangeId: requests[index].id ?? "",
                      ),
                    ),
                  ).then((_) async {
                    final buyerId = await LocalStorage.getUserId() ?? "";
                    if (buyerId.isNotEmpty && mounted) {
                      provider.fetchMyRequests(buyerId);
                    }
                  }),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz_rounded, size: 72.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "No Exchange Requests",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Your exchange requests will appear here",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _ExchangeCard extends StatelessWidget {
  final ExchangeRequest request;
  final VoidCallback onTap;

  const _ExchangeCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(request.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Header row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColor.primaryColor,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Exchange Request",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _formatDate(request.createdAt),
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: statusStyle.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: statusStyle.color.withOpacity(0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusStyle.icon,
                          size: 13.sp, color: statusStyle.color),
                      SizedBox(width: 4.w),
                      Text(
                        request.statusLabel,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: statusStyle.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(height: 1, color: Colors.grey[100]),
            SizedBox(height: 12.h),

            // Reason
            _infoRow(Icons.description_outlined, "Reason", request.reason ?? "N/A"),
            SizedBox(height: 8.h),

            // Resolution type
            if (request.resolutionType != null)
              _infoRow(
                request.resolutionType == "refund"
                    ? Icons.account_balance_wallet_outlined
                    : Icons.replay_circle_filled_outlined,
                "Resolution",
                request.resolutionType == "refund" ? "Wallet Refund" : "Replacement",
              ),

            // Courier cost
            if (request.courierPaidBy != null &&
                request.courierPaidBy!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _infoRow(
                Icons.local_shipping_outlined,
                "Courier Cost",
                request.courierCostLabel,
                iconColor: request.courierPaidBy == "buyer"
                    ? Colors.orange
                    : Colors.green,
              ),
            ],

            // Tracking number if return shipped
            if (request.returnTrackingNumber != null &&
                request.returnTrackingNumber!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _infoRow(
                Icons.local_shipping,
                "Return Tracking",
                request.returnTrackingNumber!,
              ),
            ],

            // Refund amount
            if (request.refundAmount != null && request.refundAmount! > 0) ...[
              SizedBox(height: 8.h),
              _infoRow(
                Icons.currency_rupee,
                "Refund Amount",
                "Rs ${request.refundAmount!.toStringAsFixed(0)}",
                iconColor: Colors.green,
              ),
            ],

            // Action hint
            SizedBox(height: 12.h),
            if (request.status == "Accepted")
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16.sp, color: Colors.blue[700]),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Action needed: Ship the product and upload proof",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 18.sp, color: Colors.blue[700]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: iconColor ?? Colors.grey[500]),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final d = DateTime.parse(dateStr);
      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return "";
    }
  }
}

class _StatusStyle {
  final Color color;
  final IconData icon;
  const _StatusStyle(this.color, this.icon);
}

_StatusStyle _statusStyle(String? status) {
  switch (status) {
    case "Pending":
      return const _StatusStyle(Colors.orange, Icons.pending);
    case "Accepted":
      return const _StatusStyle(Colors.blue, Icons.check_circle_outline);
    case "Denied":
      return _StatusStyle(Colors.red[700]!, Icons.cancel);
    case "ReturnShipped":
      return const _StatusStyle(Colors.indigo, Icons.local_shipping);
    case "ReturnReceived":
      return const _StatusStyle(Colors.teal, Icons.inventory);
    case "Inspecting":
      return const _StatusStyle(Colors.purple, Icons.search);
    case "ApprovedInspection":
      return const _StatusStyle(Colors.green, Icons.verified);
    case "Disputed":
      return _StatusStyle(Colors.red[400]!, Icons.warning_amber);
    case "ReplacementShipped":
      return const _StatusStyle(Colors.indigo, Icons.local_shipping);
    case "Refunded":
      return const _StatusStyle(Colors.green, Icons.account_balance_wallet);
    case "Completed":
      return const _StatusStyle(Colors.green, Icons.check_circle);
    default:
      return const _StatusStyle(Colors.grey, Icons.help_outline);
  }
}