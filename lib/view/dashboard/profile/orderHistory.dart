import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/widgets/customBgContainer.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data (you can replace with real API data later)
    final orders = [
      {
        "id": "#1001",
        "date": "5 Nov 2025",
        "status": "Delivered",
        "price": "1299",
        "image": "https://picsum.photos/200/300?random=1",
      },
      {
        "id": "#1002",
        "date": "2 Nov 2025",
        "status": "In Transit",
        "price": "899",
        "image": "https://picsum.photos/200/300?random=2",
      },
      {
        "id": "#1003",
        "date": "28 Oct 2025",
        "status": "Cancelled",
        "price": "599",
        "image": "https://picsum.photos/200/300?random=3",
      },
      {
        "id": "#1004",
        "date": "20 Oct 2025",
        "status": "Delivered",
        "price": "1999",
        "image": "https://picsum.photos/200/300?random=4",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Order History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.black,
          ),
        ),
      ),

      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🖼 Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        order["image"]!,
                        height: 70.h,
                        width: 70.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    /// 📦 Order Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ${order["id"]}",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Placed on ${order["date"]}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 6.h),

                          /// 🏷️ Status Chip
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(
                                    order["status"]!,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  order["status"]!,
                                  style: TextStyle(
                                    color: getStatusColor(order["status"]!),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                order["price"]!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),

                          /// 🔍 View Details Button
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton.icon(
                              onPressed: () {
                                // navigate to order details screen
                              },
                              icon: const Icon(
                                Icons.remove_red_eye_outlined,
                                size: 18,
                              ),
                              label: const Text("View Details"),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColor.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 🎨 Status color helper
  Color getStatusColor(String status) {
    switch (status) {
      case "Delivered":
        return Colors.green;
      case "In Transit":
        return Colors.orangeAccent;
      case "Cancelled":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
