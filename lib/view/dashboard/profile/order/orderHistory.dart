import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/auth/AuthLoginGate.dart';
import 'package:user_side/view/dashboard/profile/order/orderHistoryDetail.dart';
import 'package:user_side/view/dashboard/profile/order/reviewScreen.dart';
import 'package:user_side/viewModel/provider/orderProvider/getMyOrder_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<GetMyOrderProvider>(context, listen: false);

    /// first page load
    provider.fetchMyOrders(isRefresh: true);

    /// pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        provider.fetchMyOrders();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    // ✅ USERID login guard (same pattern)
    return AuthGate(child: _buildScaffold(context));
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appimagecolor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Order History",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: CustomBgContainer(
        child: Consumer<GetMyOrderProvider>(
          builder: (context, provider, child) {
            /// INITIAL LOADING
            if (provider.isLoading && provider.orderList.isEmpty) {
              return const Center(
                child: SpinKitThreeBounce(
                  color: AppColor.whiteColor,
                  size: 30.0,
                ),
              );
            }

            /// NO DATA
            if (provider.orderList.isEmpty) {
              return const Center(child: Text("No orders found"));
            }

            return Padding(
              padding: EdgeInsets.all(16.w),
              child: ListView.separated(
                controller: _scrollController,
                itemCount:
                    provider.orderList.length +
                    (provider.isMoreLoading ? 1 : 0),
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  /// PAGINATION LOADER
                  if (index == provider.orderList.length) {
                    return const Center(
                      child: SpinKitThreeBounce(
                        color: AppColor.whiteColor,
                        size: 30.0,
                      ),
                    );
                  }

                  final order = provider.orderList[index];
                  final product = order.product;

                  final bool isReturned = order.status == "Returned";
                  final bool isDelivered = order.status == "Delivered";

                  final String? productId = product?.productId;

                  /// ✅ SHOW ONLY IF: Delivered AND review is null
                  final bool canShowAddReview =
                      isDelivered &&
                      productId != null &&
                      product?.review == null;

                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: product?.images?.isNotEmpty == true
                              ? Image.network(
                                  Global.imageUrl + product!.images!.first,
                                  height: 70.h,
                                  width: 70.w,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 70.h,
                                  width: 70.w,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[500],
                                    size: 30.sp,
                                  ),
                                ),
                        ),
                        SizedBox(width: 12.w),

                        /// INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// PRODUCT NAME
                              Text(
                                product?.name ?? "",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),

                              /// DATE
                              Text(
                                order.createdAt != null
                                    ? formatDate(order.createdAt!)
                                    : "",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 6.h),

                              /// STATUS + PRICE
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isReturned
                                          ? Colors.red.withOpacity(0.15)
                                          : Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      order.status ?? "",
                                      style: TextStyle(
                                        color: isReturned
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "Rs ${product?.price ?? ""}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),

                              /// ADD REVIEW (model-based)
                              if (canShowAddReview)
                                Padding(
                                  padding: EdgeInsets.only(top: 6.h),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final submitted =
                                          await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ReviewScreen(
                                                productId: productId!,
                                              ),
                                            ),
                                          );

                                      /// ✅ After submit, refresh orders so review comes in model
                                      if (submitted == true) {
                                        await provider.fetchMyOrders(
                                          isRefresh: true,
                                        );
                                      }
                                    },
                                    child: Text(
                                      "Add Review",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),

                              /// VIEW DETAILS
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            OrderDetailScreen(order: order),
                                      ),
                                    );
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
            );
          },
        ),
      ),
    );
  }
}
