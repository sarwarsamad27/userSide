import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:user_side/models/order/myOrderModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/userChat/exchangeRequestSheet.dart';
import 'package:user_side/view/dashboard/userChat/refundRequestSheet.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/widgets/customBgContainer.dart';

class OrderDetailScreen extends StatelessWidget {
  final Orders order;
  const OrderDetailScreen({super.key, required this.order});

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("dd MMM yyyy, hh:mm a").format(parsed);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveredRef = order.createdAt;
    final eligible = canExchange(order.status, deliveredRef);
    final List<Product> products = [];
    if (order.product != null) {
      products.add(order.product!);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: const Text("Order Details"),
        centerTitle: true,
      ),
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: ListView(
            children: [
              /// ORDER BASIC INFO
              Text(
                "Order ID: ${order.orderId ?? 'N/A'}",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),

              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status: ${order.status ?? ""}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Estimated Delivery: 3-5 Days",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  Utils.deliveryManLottie(size: 80),
                ],
              ),

              Divider(height: 30.h),

              /// SELLER DETAILS
              Text(
                "Seller Details",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text("Brand: ${order.seller?.name ?? 'N/A'}"),
              Text("Email: ${order.seller?.email ?? 'N/A'}"),
              Text("Phone: ${order.seller?.phone ?? 'N/A'}"),
              Text("Address: ${order.seller?.address ?? 'N/A'}"),

              Divider(height: 30.h),

              /// BUYER DETAILS
              Text(
                "Your Details",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text("Name: ${order.buyerDetails?.name ?? 'N/A'}"),
              Text("Email: ${order.buyerDetails?.email ?? 'N/A'}"),
              Text("Phone: ${order.buyerDetails?.phone ?? 'N/A'}"),
              Text("Address: ${order.buyerDetails?.address ?? 'N/A'}"),
              Text("Note: ${order.buyerDetails?.additionalNote ?? 'N/A'}"),
              Text(
                "Date & Time:                 ${order.createdAt != null ? formatDate(order.createdAt!) : 'N/A'}",
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 13.sp,
                ),
              ),
              Divider(height: 30.h),

              /// PRODUCT DETAILS
              Text(
                "Products",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              ...products.map((p) {
                final exReq = p.exchangeRequest;
                final refReq = p.refundRequest;

                return Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child:
                                (p.images?.isNotEmpty == true &&
                                    (p.images!.first).isNotEmpty)
                                ? Image.network(
                                    Global.imageUrl +
                                        (p.images!.first.startsWith('/')
                                            ? ""
                                            : "/") +
                                        p.images!.first,
                                    height: 80.h,
                                    width: 80.w,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _fallbackImg(),
                                    loadingBuilder: (context, child, lp) {
                                      if (lp == null) return child;
                                      return _loadingImg();
                                    },
                                  )
                                : _fallbackImg(),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name ?? "N/A",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text("Qty: ${p.quantity ?? 0}"),
                                Text("Price: Rs ${p.price ?? 0}"),
                                Text("Total: Rs ${p.totalPrice ?? 0}"),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (exReq != null) ...[
                        SizedBox(height: 10.h),
                        _RequestStatusBadge(
                          type: "Exchange",
                          status: exReq.status ?? "Pending",
                          note: exReq.companyNote,
                        ),
                      ],
                      if (refReq != null) ...[
                        SizedBox(height: 10.h),
                        _RequestStatusBadge(
                          type: "Refund",
                          status: refReq.status ?? "Pending",
                          note: refReq.companyNote,
                        ),
                      ],

                      if (eligible && exReq == null && refReq == null) ...[
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            _ActionBtn(
                              label: "Exchange",
                              icon: Icons.swap_horiz,
                              color: Colors.blue,
                              onTap: () => _openRequestForm(
                                context,
                                "exchange",
                                products,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            _ActionBtn(
                              label: "Refund",
                              icon: Icons.money_off,
                              color: Colors.red,
                              onTap: () =>
                                  _openRequestForm(context, "refund", products),
                            ),
                          ],
                        ),
                      ] else if (order.status == "Delivered" &&
                          exReq == null &&
                          refReq == null) ...[
                        SizedBox(height: 10.h),
                        Text(
                          "Return/Refund window expired (10 days after delivery).",
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              Divider(height: 30.h),

              /// PRICE SUMMARY
              Text("Shipment Charges: Rs ${order.shipmentCharges ?? 0}"),
              Text(
                "Grand Total: Rs ${order.grandTotal ?? 0}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackImg() => Container(
    height: 80.h,
    width: 80.w,
    alignment: Alignment.center,
    color: Colors.grey.shade200,
    child: Icon(Icons.image_outlined, size: 28.sp, color: Colors.grey),
  );

  Widget _loadingImg() => Container(
    height: 80.h,
    width: 80.w,
    alignment: Alignment.center,
    color: Colors.grey.shade200,
    child: SizedBox(
      height: 20.sp,
      width: 20.sp,
      child: const CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  void _openRequestForm(
    BuildContext context,
    String type,
    List<Product> prods,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => type == "exchange"
          ? ExchangeRequestSheet(order: order, products: prods)
          : RefundRequestSheet(order: order, products: prods),
    );
  }

  bool canExchange(String? status, String? createdAt) {
    if (status != "Delivered") return false;
    if (createdAt == null) return false;
    try {
      final delivered = DateTime.parse(createdAt);
      // Align with backend (10 days)
      final expiry = delivered.add(const Duration(days: 10));
      return DateTime.now().isBefore(expiry);
    } catch (_) {
      return false;
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestStatusBadge extends StatelessWidget {
  final String type, status;
  final String? note;

  const _RequestStatusBadge({
    required this.type,
    required this.status,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Colors.orange;
    if (status == "Accepted" || status == "Completed" || status == "Refunded")
      color = Colors.green;
    if (status == "Denied" || status == "Disputed") color = Colors.red;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16.sp, color: color),
              SizedBox(width: 8.w),
              Text(
                "$type Request: $status",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (note != null && note!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              "Note: $note",
              style: TextStyle(fontSize: 12.sp, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }
}
