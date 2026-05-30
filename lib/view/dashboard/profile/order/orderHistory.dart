// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:user_side/resources/utiles.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/socketServices.dart';
import 'package:user_side/view/auth/AuthLoginGate.dart';
import 'package:user_side/view/dashboard/profile/order/orderHistoryDetail.dart';
import 'package:user_side/view/dashboard/profile/order/reviewScreen.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/getMyOrder_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/review_provider.dart';
import 'package:user_side/models/order/myOrderModel.dart';

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
              _scrollController.position.maxScrollExtent - 200 &&
          !provider.isLoading &&
          !provider.isMoreLoading) {
        provider.fetchMyOrders();
      }
    });

    Future.microtask(() async {
      final buyerId = await LocalStorage.getUserId();
      if (buyerId != null && mounted) {
        final exchProvider =
            Provider.of<ExchangeProvider>(context, listen: false);
        exchProvider.fetchMyRequests(buyerId);
        exchProvider.fetchMyRefunds(buyerId);
      }
      // Socket — order_status_updated se local update (no API re-fetch)
      _setupSocket(buyerId);
    });
  }

  void _setupSocket(String? buyerId) async {
    if (buyerId == null) return;
    final socket = await SocketService().ensureConnected(
      baseUrl: Global.imageUrl,
      auth: {'buyerId': buyerId},
    );
    socket?.on('order_status_updated', (data) {
      if (!mounted || data == null) return;
      try {
        final orderId = data['orderId']?.toString();
        final status = data['status']?.toString();
        if (orderId == null || status == null) return;
        final prov = Provider.of<GetMyOrderProvider>(context, listen: false);
        prov.updateOrderStatus(
          orderId,
          status: status,
          cancelledBy: data['order']?['cancelledBy']?.toString(),
          cancelReason: data['order']?['cancelReason']?.toString(),
        );
      } catch (_) {}
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

  // ── Cancel Order ──────────────────────────────────────────────────────────
  Future<void> _showCancelDialog(
    BuildContext context,
    Orders order,
    GetMyOrderProvider provider,
  ) async {
    final reasonController = TextEditingController();
    String? selectedReason;
    bool isLoading = false;

    const quickReasons = [
      'Changed my mind',
      'Found a better price',
      'Ordered by mistake',
      'Delivery time too long',
      'Other',
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
                top: 20.h,
                left: 20.w,
                right: 20.w,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cancel Order",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "ID: ${order.orderId ?? ''}",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  Text(
                    "Select a reason",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Quick reason chips
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: quickReasons.map((reason) {
                      final isSelected = selectedReason == reason;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedReason = reason;
                            if (reason != 'Other') reasonController.clear();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.red.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Custom reason text field (show only when "Other" selected)
                  if (selectedReason == 'Other') ...[
                    SizedBox(height: 14.h),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      style: TextStyle(fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: "Describe your reason...",
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF6F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.red.withOpacity(0.4),
                          ),
                        ),
                        contentPadding: EdgeInsets.all(12.w),
                      ),
                    ),
                  ],

                  SizedBox(height: 20.h),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading || selectedReason == null
                          ? null
                          : () async {
                              final finalReason =
                                  selectedReason == 'Other'
                                  ? (reasonController.text.trim().isEmpty
                                      ? 'No reason provided'
                                      : reasonController.text.trim())
                                  : selectedReason!;

                              setModalState(() => isLoading = true);

                              final success = await _cancelOrder(
                                orderId: order.id!,
                                reason: finalReason,
                              );

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);

                              if (success) {
                                // Update locally — no API re-hit
                                provider.updateOrderStatus(
                                  order.id!,
                                  status: 'Cancelled',
                                  cancelledBy: 'buyer',
                                  cancelReason: finalReason,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Order cancelled successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to cancel order'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.grey[200],
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Confirm Cancellation",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final token = await LocalStorage.getToken();
      final response = await http.post(
        Uri.parse(Global.CancelOrder),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'orderId': orderId, 'reason': reason}),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['success'] == true;
    } catch (_) {
      return false;
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
            if (provider.isLoading && provider.orderList.isEmpty) {
              return Center(child: Utils.shoppingLoadingLottie(size: 200));
            }

            final sortedOrders = [...provider.orderList];
            sortedOrders.sort((a, b) {
              final aDate =
                  DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
              final bDate =
                  DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
              return bDate.compareTo(aDate);
            });

            return Column(
              children: [
                // ── SEARCH BAR ──────────────────────────────────────────
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
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
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
                              setState(() => _searchQuery = '');
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

                // ── ALL ORDERS LIST ──────────────────────────────────────
                Expanded(
                  child: _buildOrderList(
                    orders: sortedOrders,
                    provider: provider,
                    reviewProvider: reviewProvider,
                    exchProvider: exchProvider,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Order List Builder ─────────────────────────────────────────────────────
  Widget _buildOrderList({
    required List<Orders> orders,
    required GetMyOrderProvider provider,
    required ReviewProvider reviewProvider,
    required ExchangeProvider exchProvider,
  }) {
    final filtered = _searchQuery.isEmpty
        ? orders
        : orders.where((o) {
            final name = o.product?.name?.toLowerCase() ?? '';
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    if (orders.isEmpty && !provider.isLoading) return _buildEmpty();
    if (filtered.isEmpty) return _buildNoResult();

    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: () => provider.fetchMyOrders(isRefresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        itemCount: filtered.length +
            (_searchQuery.isEmpty && provider.isMoreLoading ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          if (index == filtered.length) {
            return Center(child: Utils.loadingLottie(size: 50));
          }
          final order = filtered[index];
          return _buildOrderCard(
            order: order,
            provider: provider,
            reviewProvider: reviewProvider,
            exchProvider: exchProvider,
          );
        },
      ),
    );
  }

  // ── Order Card ─────────────────────────────────────────────────────────────
  Widget _buildOrderCard({
    required Orders order,
    required GetMyOrderProvider provider,
    required ReviewProvider reviewProvider,
    required ExchangeProvider exchProvider,
  }) {
    final product = order.product;
    final bool isDelivered = order.status == 'Delivered';
    final bool isPending = order.status == 'Pending';
    final String? productId = product?.productId;
    final String orderId = order.id ?? '';
    final bool canShowAddReview = isDelivered &&
        productId != null &&
        orderId.isNotEmpty &&
        !reviewProvider.isReviewed(orderId);

    final oid = order.id ?? '';
    final oReadableId = order.orderId ?? '';
    final pid = order.product?.productId;
    final myEx = exchProvider.listModel?.requests
        .where((e) =>
            (e.orderId == oid || e.orderId == oReadableId) &&
            (pid == null || e.productId == pid))
        .firstOrNull;
    final myRef = exchProvider.refundListModel?.requests
        .where((r) =>
            (r.orderId == oid || r.orderId == oReadableId) &&
            (pid == null || r.productId == pid))
        .firstOrNull;
    final hasExchange = myEx != null;
    final hasRefund = myRef != null;
    final exchangeStatus = myEx?.status;
    final refundStatus = myRef?.status;

    final Color statusColor = _statusColor(order.status);
    final IconData statusIcon = _statusIcon(order.status);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top color bar
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID + Status Row
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
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 11.sp, color: statusColor),
                          SizedBox(width: 4.w),
                          Text(
                            order.status ?? '',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Product Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: product?.images?.isNotEmpty == true
                          ? Image.network(
                              Global.getImageUrl(product!.images!.first),
                              height: 80.h,
                              width: 80.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fallbackImg(),
                            )
                          : _fallbackImg(),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.name ?? 'Product',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  "Rs ${product?.price ?? 0}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              if (product?.quantity != null)
                                Text(
                                  "× ${product!.quantity}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 11.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  order.createdAt != null
                                      ? formatDate(order.createdAt!)
                                      : '',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Cancelled by + reason block ─────────────────────────
                if (order.status == 'Cancelled') ...[
                  SizedBox(height: 12.h),
                  _buildCancelInfoBlock(order),
                ],

                // ── Exchange / Refund badge ─────────────────────────────
                if ((hasExchange || hasRefund) &&
                    order.status != 'Cancelled' &&
                    order.status != 'Pending' &&
                    order.status != 'Dispatched') ...[
                  SizedBox(height: 10.h),
                  _buildRequestBadge(
                    hasExchange: hasExchange,
                    hasRefund: hasRefund,
                    exchangeStatus: exchangeStatus,
                    refundStatus: refundStatus,
                  ),
                ],

                SizedBox(height: 12.h),
                Container(height: 1, color: Colors.grey[100]),
                SizedBox(height: 10.h),

                // Bottom row
                Row(
                  children: [
                    // Cancel button for Pending orders
                    if (isPending)
                      GestureDetector(
                        onTap: () => _showCancelDialog(context, order, provider),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cancel_outlined,
                                size: 13.sp,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Add Review for Delivered
                    if (canShowAddReview)
                      GestureDetector(
                        onTap: () async {
                          final submitted = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewScreen(
                                productId: productId,
                                orderId: orderId,
                              ),
                            ),
                          );
                          if (submitted == true) {
                            await provider.fetchMyOrders(isRefresh: true);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 13.sp,
                                color: Colors.amber[700],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "Add Review",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const Spacer(),

                    // View Details
                    GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(order: order),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 13.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                "View Details",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
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
    );
  }

  // ── Cancel Info Block ──────────────────────────────────────────────────────
  Widget _buildCancelInfoBlock(Orders order) {
    final isByBuyer = order.cancelledBy == 'buyer';
    final isBySeller = order.cancelledBy == 'seller';
    final reason = order.cancelReason;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cancel_rounded, size: 13.sp, color: Colors.red),
              SizedBox(width: 6.w),
              Text(
                isByBuyer
                    ? 'Cancelled by You'
                    : isBySeller
                        ? 'Cancelled by Seller'
                        : 'Cancelled',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          if (reason != null && reason.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason: ',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
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
    final label = isExchange ? 'Exchange' : 'Refund';

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
            '$label Request · ${_premiumStatusLabel(status)}',
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

  // ── Empty States ───────────────────────────────────────────────────────────
  Widget _buildEmpty() => Center(
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

  Widget _buildNoResult() => Center(
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

  Widget _fallbackImg() => Container(
        height: 80.h,
        width: 80.w,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14.r),
        ),
        child:
            Icon(Icons.image_outlined, size: 28.sp, color: Colors.grey[400]),
      );

  // ── Helpers ────────────────────────────────────────────────────────────────
  Color _statusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Dispatched':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Returned':
        return Colors.red;
      case 'Cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'Pending':
        return Icons.hourglass_empty_rounded;
      case 'Dispatched':
        return Icons.local_shipping_rounded;
      case 'Delivered':
        return Icons.check_circle_rounded;
      case 'Returned':
        return Icons.assignment_return_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _requestStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.blue;
      case 'Denied':
      case 'Rejected':
        return Colors.red;
      case 'ReturnShipped':
        return Colors.indigo;
      case 'ReturnReceived':
        return Colors.teal;
      case 'Inspecting':
        return Colors.purple;
      case 'ApprovedInspection':
        return Colors.green;
      case 'ReplacementShipped':
        return Colors.indigo;
      case 'Refunded':
      case 'Completed':
        return Colors.green;
      case 'Disputed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _premiumStatusLabel(String? status) {
    switch (status) {
      case 'Pending':
        return 'Awaiting Review';
      case 'Accepted':
        return 'Accepted ✓';
      case 'Denied':
      case 'Rejected':
        return 'Declined';
      case 'ReturnShipped':
        return 'Return In Transit';
      case 'ReturnReceived':
        return 'Parcel Received';
      case 'Inspecting':
        return 'Under Inspection';
      case 'ApprovedInspection':
        return 'Inspection Passed ✓';
      case 'ReplacementShipped':
        return 'Replacement Shipped 🚀';
      case 'Refunded':
        return 'Refund Credited 💳';
      case 'Completed':
        return 'Complete ✅';
      case 'Disputed':
        return 'Under Dispute';
      default:
        return status ?? 'Unknown';
    }
  }
}
