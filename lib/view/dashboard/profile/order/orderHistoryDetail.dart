import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:user_side/models/order/myOrderModel.dart';
import 'package:user_side/resources/global.dart';

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
    // Handle single product or multiple products
    final List<Product> products = [];
    if (order.product != null) {
      products.add(order.product!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView(
          children: [
            /// ORDER BASIC INFO
            Text(
              "Order ID: ${order.orderId ?? 'N/A'}",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              order.createdAt != null ? formatDate(order.createdAt!) : 'N/A',
              style: TextStyle(color: Colors.grey, fontSize: 13.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              "Status: ${order.status ?? 'Delivered'}",
              style: TextStyle(fontSize: 14.sp, color: Colors.green),
            ),

            Divider(height: 30.h),

            /// SELLER DETAILS
            Text(
              "Seller Details",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text("Name: ${order.seller?.name ?? 'N/A'}"),
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

            Divider(height: 30.h),

            /// PRODUCT DETAILS
            Text(
              "Products",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            ...products.map(
              (p) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        (p.images?.isNotEmpty == true)
                            ? Global.imageUrl + p.images!.first
                            : "",
                        height: 80.h,
                        width: 80.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name ?? "N/A",
                            style: TextStyle(
                                fontSize: 15.sp, fontWeight: FontWeight.w600),
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
              ),
            ),

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
    );
  }
}
