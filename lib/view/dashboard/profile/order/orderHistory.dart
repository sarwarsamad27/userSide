// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/auth/AuthLoginGate.dart';
import 'package:user_side/view/dashboard/profile/order/orderHistoryDetail.dart';
import 'package:user_side/view/dashboard/profile/order/reviewScreen.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/getMyOrder_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/review_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<GetMyOrderProvider>(context, listen: false);
    if (provider.orderList.isEmpty) {
      provider.fetchMyOrders(isRefresh: true);
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        provider.fetchMyOrders();
      }
    });

    // Fetch exchange/refund lists once so list screen can match correctly
    Future.microtask(() async {
      final buyerId = await LocalStorage.getUserId();
      if (buyerId != null && mounted) {
        final exchProvider =
            Provider.of<ExchangeProvider>(context, listen: false);
        exchProvider.fetchMyRequests(buyerId);
        exchProvider.fetchMyRefunds(buyerId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
    return AuthGate(child: _buildScaffold(context));
  }

  Widget _buildScaffold(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
          title: Text(
            "My Orders",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: Consumer3<GetMyOrderProvider, ReviewProvider, ExchangeProvider>(
          builder: (context, provider, reviewProvider, exchProvider, child) {
            // ── INITIAL LOADING ─────────────────────────────────────
            if (provider.isLoading && provider.orderList.isEmpty) {
              return Center(child: Utils.shoppingLoadingLottie(size: 200));
            }

            // ── NO DATA ─────────────────────────────────────────────
            if (provider.orderList.isEmpty) {
              return _buildEmpty();
            }

            // ── SORT: newest first ───────────────────────────────────
            final sortedOrders = [...provider.orderList];
            sortedOrders.sort((a, b) {
              final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
              final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
              return bDate.compareTo(aDate);
            });

            // ── FILTER: search by product name ───────────────────────
            final filteredOrders = _searchQuery.isEmpty
                ? sortedOrders
                : sortedOrders.where((order) {
                    final name = order.product?.name?.toLowerCase() ?? '';
                    return name.contains(_searchQuery.toLowerCase());
                  }).toList();

            return RefreshIndicator(
              color: AppColor.primaryColor,
              onRefresh: () async {
                await provider.fetchMyOrders(isRefresh: true);
              },
              child: Column(
                children: [
                  // ── SEARCH BAR ─────────────────────────────────────
                  Container(
                    color: AppColor.primaryColor,
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 14.w),
                          Icon(
                            Icons.search_rounded,
                            size: 18.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: "Search by product name...",
                                hintStyle: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[400],
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 10.w),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16.sp,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── ORDER LIST ─────────────────────────────────────
                  Expanded(
                    child: filteredOrders.isEmpty
                        ? _buildNoResult()
                        : ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 20.h,
                            ),
                            itemCount:
                                filteredOrders.length +
                                (_searchQuery.isEmpty && provider.isMoreLoading
                                    ? 1
                                    : 0),
                            separatorBuilder: (_, __) => SizedBox(height: 14.h),
                            itemBuilder: (context, index) {
                              // ── PAGINATION LOADER ─────────────────
                              if (index == filteredOrders.length) {
                                return Center(
                                  child: Utils.loadingLottie(size: 50),
                                );
                              }

                              final order = filteredOrders[index];
                              final product = order.product;
                              final bool isReturned =
                                  order.status == "Returned";
                              final bool isDelivered =
                                  order.status == "Delivered";
                              final bool isPending = order.status == "Pending";
                              final bool isDispatched =
                                  order.status == "Dispatched";
                              final String? productId = product?.productId;
                              final String orderId = order.id ?? '';
                              final bool canShowAddReview =
                                  isDelivered &&
                                  productId != null &&
                                  orderId.isNotEmpty &&
                                  !reviewProvider.isReviewed(orderId);

                              // Match exchange/refund by orderId+productId from provider
                              // (avoids backend cross-contamination by productId alone)
                              final oid = order.id ?? '';
                              final pid = order.product?.productId;
                              final myEx = exchProvider.listModel?.requests
                                  .where((e) =>
                                      e.orderId == oid &&
                                      (pid == null || e.productId == pid))
                                  .firstOrNull;
                              final myRef =
                                  exchProvider.refundListModel?.requests
                                      .where((r) =>
                                          r.orderId == oid &&
                                          (pid == null || r.productId == pid))
                                      .firstOrNull;
                              final hasExchange = myEx != null;
                              final hasRefund = myRef != null;
                              final exchangeStatus = myEx?.status;
                              final refundStatus = myRef?.status;

                              // Status color
                              Color statusColor = _statusColor(order.status);
                              IconData statusIcon = _statusIcon(order.status);

                              return GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── TOP COLOR BAR ──────────────
                                      Container(
                                        height: 4.h,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.r),
                                            topRight: Radius.circular(20.r),
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.all(14.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // ── ORDER ID + STATUS ROW ──
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.receipt_long_rounded,
                                                  size: 13.sp,
                                                  color: AppColor.appimagecolor,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  "ID: ${order.orderId ?? 'N/A'}",
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColor.primaryColor,
                                                  ),
                                                ),
                                                const Spacer(),
                                                // Status Badge
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w,
                                                    vertical: 4.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20.r,
                                                        ),
                                                    border: Border.all(
                                                      color: statusColor
                                                          .withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        statusIcon,
                                                        size: 11.sp,
                                                        color: statusColor,
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Text(
                                                        order.status ?? "",
                                                        style: TextStyle(
                                                          fontSize: 11.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: statusColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 12.h),

                                            // ── PRODUCT ROW ────────────
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Product Image
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        14.r,
                                                      ),
                                                  child:
                                                      product
                                                              ?.images
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? Image.network(
                                                          Global.getImageUrl(
                                                            product!
                                                                .images!
                                                                .first,
                                                          ),
                                                          height: 80.h,
                                                          width: 80.w,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (_, __, ___) =>
                                                                  _fallbackImg(),
                                                        )
                                                      : _fallbackImg(),
                                                ),
                                                SizedBox(width: 14.w),

                                                // Product Info
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        product?.name ??
                                                            "Product",
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.black87,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(height: 6.h),

                                                      // Price + Date row
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      8.w,
                                                                  vertical: 3.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: AppColor
                                                                  .primaryColor
                                                                  .withOpacity(
                                                                    0.08,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8.r,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              "Rs ${product?.price ?? 0}",
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: AppColor
                                                                    .primaryColor,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 8.w),
                                                          if (product
                                                                  ?.quantity !=
                                                              null)
                                                            Text(
                                                              "× ${product!.quantity}",
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: Colors
                                                                    .grey[500],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 6.h),

                                                      // Date
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .access_time_rounded,
                                                            size: 11.sp,
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                          SizedBox(width: 4.w),
                                                          Expanded(
                                                            child: Text(
                                                              order.createdAt !=
                                                                      null
                                                                  ? formatDate(
                                                                      order
                                                                          .createdAt!,
                                                                    )
                                                                  : "",
                                                              style: TextStyle(
                                                                fontSize: 11.sp,
                                                                color: Colors
                                                                    .grey[500],
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // ── EXCHANGE / REFUND BADGE ─
                                            // Only show after delivery; never on Pending/Dispatched/Cancelled
                                            if ((hasExchange || hasRefund) &&
                                                order.status != "Cancelled" &&
                                                order.status != "Pending" &&
                                                order.status !=
                                                    "Dispatched") ...[
                                              SizedBox(height: 10.h),
                                              _buildRequestBadge(
                                                hasExchange: hasExchange,
                                                hasRefund: hasRefund,
                                                exchangeStatus: exchangeStatus,
                                                refundStatus: refundStatus,
                                              ),
                                            ],

                                            // ── DIVIDER ────────────────
                                            SizedBox(height: 12.h),
                                            Container(
                                              height: 1,
                                              color: Colors.grey[100],
                                            ),
                                            SizedBox(height: 10.h),

                                            // ── BOTTOM ROW ─────────────
                                            Row(
                                              children: [
                                                // Add Review
                                                if (canShowAddReview)
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final submitted =
                                                          await Navigator.push<
                                                            bool
                                                          >(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  ReviewScreen(
                                                                    productId:
                                                                        productId,
                                                                    orderId:
                                                                        orderId,
                                                                  ),
                                                            ),
                                                          );
                                                      if (submitted == true) {
                                                        await provider
                                                            .fetchMyOrders(
                                                              isRefresh: true,
                                                            );
                                                      }
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 10.w,
                                                            vertical: 6.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.amber
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.r,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.amber
                                                              .withOpacity(0.4),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.star_rounded,
                                                            size: 13.sp,
                                                            color: Colors
                                                                .amber[700],
                                                          ),
                                                          SizedBox(width: 4.w),
                                                          Text(
                                                            "Add Review",
                                                            style: TextStyle(
                                                              fontSize: 11.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .amber[700],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                const Spacer(),

                                                // View Details Button
                                                GestureDetector(
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          OrderDetailScreen(
                                                            order: order,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 14.w,
                                                          vertical: 8.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColor.primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20.r,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColor
                                                              .primaryColor
                                                              .withOpacity(0.3),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                          size: 13.sp,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 5.w),
                                                        Text(
                                                          "View Details",
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Exchange / Refund Badge ────────────────────────────────────────────────
  Widget _buildRequestBadge({
    required bool hasExchange,
    required bool hasRefund,
    String? exchangeStatus,
    String? refundStatus,
  }) {
    final isExchange = hasExchange;
    final status = isExchange ? exchangeStatus : refundStatus;
    final color = _requestStatusColor(status);
    final icon = isExchange
        ? Icons.swap_horiz_rounded
        : Icons.assignment_return_rounded;
    final label = isExchange ? "Exchange" : "Refund";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            "$label Request · ${_premiumStatusLabel(status)}",
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 72.w,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            "No Orders Yet",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Your order history will appear here",
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ── No Search Result ───────────────────────────────────────────────────────
  Widget _buildNoResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "No Results Found",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Try searching with a different product name",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ── Fallback Image ─────────────────────────────────────────────────────────
  Widget _fallbackImg() => Container(
    height: 80.h,
    width: 80.w,
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(14.r),
    ),
    child: Icon(Icons.image_outlined, size: 28.sp, color: Colors.grey[400]),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────
  Color _statusColor(String? status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Dispatched":
        return Colors.blue;
      case "Delivered":
        return Colors.green;
      case "Returned":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case "Pending":
        return Icons.hourglass_empty_rounded;
      case "Dispatched":
        return Icons.local_shipping_rounded;
      case "Delivered":
        return Icons.check_circle_rounded;
      case "Returned":
        return Icons.assignment_return_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _requestStatusColor(String? status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Accepted":
        return Colors.blue;
      case "Denied":
      case "Rejected":
        return Colors.red;
      case "ReturnShipped":
        return Colors.indigo;
      case "ReturnReceived":
        return Colors.teal;
      case "Inspecting":
        return Colors.purple;
      case "ApprovedInspection":
        return Colors.green;
      case "ReplacementShipped":
        return Colors.indigo;
      case "Refunded":
      case "Completed":
        return Colors.green;
      case "Disputed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _premiumStatusLabel(String? status) {
    switch (status) {
      case "Pending":
        return "Awaiting Review";
      case "Accepted":
        return "Accepted ✓";
      case "Denied":
      case "Rejected":
        return "Declined";
      case "ReturnShipped":
        return "Return In Transit";
      case "ReturnReceived":
        return "Parcel Received";
      case "Inspecting":
        return "Under Inspection";
      case "ApprovedInspection":
        return "Inspection Passed ✓";
      case "ReplacementShipped":
        return "Replacement Shipped 🚀";
      case "Refunded":
        return "Refund Credited 💳";
      case "Completed":
        return "Complete ✅";
      case "Disputed":
        return "Under Dispute";
      default:
        return status ?? "Unknown";
    }
  }
}
