import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:user_side/models/order/myOrderModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/userChat/exchangeRequestSheet.dart';
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
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
              ...products.map(
                (p) => Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child:
                            (p.images?.isNotEmpty == true &&
                                (p.images!.first).isNotEmpty)
                            ? Image.network(
                                Global.imageUrl + p.images!.first,
                                height: 80.h,
                                width: 80.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 80.h,
                                    width: 80.w,
                                    alignment: Alignment.center,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 28.sp,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 80.h,
                                        width: 80.w,
                                        alignment: Alignment.center,
                                        color: Colors.grey.shade200,
                                        child: SizedBox(
                                          height: 20.sp,
                                          width: 20.sp,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                        ),
                                      );
                                    },
                              )
                            : Container(
                                height: 80.h,
                                width: 80.w,
                                alignment: Alignment.center,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 28.sp,
                                  color: Colors.grey,
                                ),
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
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text("Qty: ${p.quantity ?? 0}"),
                            Text("Price: Rs ${p.price ?? 0}"),
                            Text("Total: Rs ${p.totalPrice ?? 0}"),

                            if (eligible) ...[
                              SizedBox(height: 10.h),
                              ElevatedButton(
                                onPressed: () async {
                                  // Open dialog form
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => ExchangeRequestSheet(
                                      order: order,
                                      products: products,
                                    ),
                                  );
                                },
                                child: const Text("Request Exchange"),
                              ),
                            ] else ...[
                              SizedBox(height: 10.h),
                              Text(
                                "Exchange option is available within 10 days after delivery.",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  bool canExchange(String? status, String? deliveredAtOrUpdatedAt) {
    if (status != "Delivered") return false;
    if (deliveredAtOrUpdatedAt == null) return false;

    try {
      final delivered = DateTime.parse(deliveredAtOrUpdatedAt);
      final expiry = delivered.add(const Duration(days: 10));
      return DateTime.now().isBefore(expiry);
    } catch (_) {
      return false;
    }
  }
}
