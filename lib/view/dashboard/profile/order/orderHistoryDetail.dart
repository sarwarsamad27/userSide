// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_side/models/order/myOrderModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/profile/order/refundDetailScreen.dart';
import 'package:user_side/view/dashboard/userChat/exchangeDetailScreen.dart';
import 'package:user_side/view/dashboard/userChat/exchangeRequestSheet.dart';
import 'package:user_side/view/dashboard/userChat/refundRequestSheet.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final Orders order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Orders _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshExchangeStatus());
  }

  Future<void> _refreshExchangeStatus() async {
    final buyerId = await LocalStorage.getUserId() ?? '';
    if (buyerId.isEmpty || !mounted) return;
    await context.read<ExchangeProvider>().fetchMyRequests(buyerId);
    await context.read<ExchangeProvider>().fetchMyRefunds(buyerId);
    if (!mounted) return;

    final exchanges = context.read<ExchangeProvider>().listModel?.requests ?? [];
    final refunds = context.read<ExchangeProvider>().refundListModel?.requests ?? [];

    final myExchange = exchanges.where((e) => e.orderId == _order.id).firstOrNull;
    final myRefund = refunds.where((r) => r.orderId == _order.id).firstOrNull;

    if (myExchange != null || myRefund != null) {
      setState(() {
        _order = Orders(
          id: _order.id,
          orderId: _order.orderId,
          status: _order.status,
          createdAt: _order.createdAt,
          product: _order.product,
          seller: _order.seller,
          buyerDetails: _order.buyerDetails,
          shipmentCharges: _order.shipmentCharges,
          grandTotal: _order.grandTotal,
          leopardsBooked: _order.leopardsBooked,
          trackNumber: _order.trackNumber,
          slipLink: _order.slipLink,
          leopardsStatus: _order.leopardsStatus,
          exchangeRequest: myExchange != null
              ? ExchangeRequestData(
                  id: myExchange.id,
                  status: myExchange.status,
                  reason: myExchange.reason,
                  reasonCategory: myExchange.reasonCategory,
                  companyNote: myExchange.companyNote,
                  resolutionType: myExchange.resolutionType,
                  courierPaidBy: myExchange.courierPaidBy,
                  returnTrackingNumber: myExchange.returnTrackingNumber,
                  replacementTrackingNumber: myExchange.replacementTrackingNumber,
                  replacementSlipLink: myExchange.replacementSlipLink,
                  refundAmount: myExchange.refundAmount,
                  pdfPath: myExchange.pdfPath,
                )
              : _order.exchangeRequest,
          refundRequest: myRefund != null
              ? RefundRequestData(
                  id: myRefund.id,
                  status: myRefund.status,
                  reason: myRefund.reason,
                  reasonCategory: myRefund.reasonCategory,
                  companyNote: myRefund.companyNote,
                  refundAmount: myRefund.refundAmount,
                  returnTrackingNumber: myRefund.returnTrackingNumber,
                  pdfPath: myRefund.pdfPath,
                )
              : _order.refundRequest,
        );
      });
    }
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("dd MMM yyyy, hh:mm a").format(parsed);
    } catch (_) {
      return date;
    }
  }

  bool canExchangeOrRefund(String? status, String? createdAt) {
    if (status != "Delivered") return false;
    if (createdAt == null) return false;
    try {
      final delivered = DateTime.parse(createdAt);
      return DateTime.now().isBefore(delivered.add(const Duration(days: 10)));
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eligible = canExchangeOrRefund(_order.status, _order.createdAt);
    final List<Product> products = [];
    if (_order.product != null) products.add(_order.product!);
    final exReq = _order.exchangeRequest;
    final refReq = _order.refundRequest;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text("Order Details",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: RefreshIndicator(
        color: AppColor.primaryColor,
        onRefresh: _refreshExchangeStatus,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // ── ORDER STATUS CARD ────────────────────────────
            _buildOrderHeaderCard(),
            SizedBox(height: 14.h),

            // ── LEOPARDS TRACKING ────────────────────────────
            if (_order.trackNumber != null) ...[
              _buildTrackingCard(),
              SizedBox(height: 14.h),
            ],

            // ── EXCHANGE STATUS ──────────────────────────────
            if (exReq != null) ...[
              _buildExchangeCard(exReq),
              SizedBox(height: 14.h),
            ],

            // ── REFUND STATUS ────────────────────────────────
            if (refReq != null) ...[
              _buildRefundCard(refReq),
              SizedBox(height: 14.h),
            ],

            // ── SELLER CARD ──────────────────────────────────
            _buildInfoCard(
              title: "Seller Details",
              imagePath: _order.seller?.image != null
                  ? Global.getImageUrl(_order.seller!.image)
                  : null,
              icon: Icons.storefront_rounded,
              iconColor: Colors.purple,
              children: [
                _infoRow(Icons.badge_outlined, "Brand", _order.seller?.name ?? 'N/A'),
                _infoRow(Icons.email_outlined, "Email", _order.seller?.email ?? 'N/A'),
                _infoRow(Icons.phone_outlined, "Phone", _order.seller?.phone ?? 'N/A'),
                _infoRow(Icons.location_on_outlined, "Address", _order.seller?.address ?? 'N/A'),
              ],
            ),
            SizedBox(height: 14.h),

            // ── BUYER CARD ───────────────────────────────────
            _buildInfoCard(
              title: "Your Details",
              icon: Icons.person_outline_rounded,
              iconColor: Colors.blue,
              children: [
                _infoRow(Icons.person_outline, "Name", _order.buyerDetails?.name ?? 'N/A'),
                _infoRow(Icons.email_outlined, "Email", _order.buyerDetails?.email ?? 'N/A'),
                _infoRow(Icons.phone_outlined, "Phone", _order.buyerDetails?.phone ?? 'N/A'),
                _infoRow(Icons.location_on_outlined, "Address", _order.buyerDetails?.address ?? 'N/A'),
                _infoRow(Icons.calendar_today_outlined, "Date",
                    _order.createdAt != null ? formatDate(_order.createdAt!) : 'N/A'),
              ],
            ),
            SizedBox(height: 14.h),

            // ── PRODUCTS CARD ────────────────────────────────
            _buildProductsCard(products, eligible, exReq, refReq),
            SizedBox(height: 14.h),

            // ── PRICE SUMMARY ────────────────────────────────
            _buildPriceSummaryCard(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // ── Order Header Card ─────────────────────────────────────────
  Widget _buildOrderHeaderCard() {
    final statusColor = _orderStatusColor(_order.status);
    final statusIcon = _orderStatusIcon(_order.status);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: AppColor.primaryColor, size: 18.sp),
              SizedBox(width: 6.w),
              Text("Order ID: ${_order.orderId ?? 'N/A'}",
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColor.primaryColor)),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_orderStatusTitle(_order.status),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: statusColor)),
                    Text(_orderStatusSubtitle(_order.status),
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Leopards Tracking Card ────────────────────────────────────
  Widget _buildTrackingCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: Colors.indigo, size: 20.sp),
              SizedBox(width: 8.w),
              Text("Tracking Info",
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.indigo)),
            ],
          ),
          SizedBox(height: 10.h),
          _infoRow(Icons.tag, "Track #", _order.trackNumber ?? "N/A"),

          // ✅ Download slip button
          if (_order.slipLink?.isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(_order.slipLink!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: Icon(Icons.download_rounded, size: 16.sp),
                label: const Text("Download Shipping Slip"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: const BorderSide(color: Colors.indigo),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Exchange Card ─────────────────────────────────────────────
  Widget _buildExchangeCard(ExchangeRequestData exReq) {
    final info = _exchangeStatusInfo(exReq.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: info.color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.06),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz_rounded, color: info.color, size: 20.sp),
                SizedBox(width: 8.w),
                Text("Exchange Request",
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
                const Spacer(),
                _statusChip(info.title, info.color, info.icon),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeline(_exchangeStatuses, exReq.status),
                SizedBox(height: 16.h),

                if (exReq.reason?.isNotEmpty == true)
                  _detailTile(Icons.description_outlined, "Reason", exReq.reason!, Colors.grey[700]!),
                if (exReq.companyNote?.isNotEmpty == true)
                  _detailTile(Icons.comment_outlined, "Seller Note", exReq.companyNote!, Colors.orange[700]!),
                if (exReq.resolutionType != null)
                  _detailTile(
                    exReq.resolutionType == "refund"
                        ? Icons.account_balance_wallet_outlined
                        : Icons.inventory_2_outlined,
                    "Resolution",
                    exReq.resolutionType == "refund" ? "💳 Wallet Refund" : "📦 Replacement",
                    Colors.indigo,
                  ),
                if (exReq.courierPaidBy != null)
                  _detailTile(
                    Icons.local_shipping_outlined,
                    "Courier Cost",
                    exReq.courierPaidBy == "seller" ? "✅ Seller Pays" : "⚠️ You Pay Return",
                    exReq.courierPaidBy == "buyer" ? Colors.orange[700]! : Colors.green[700]!,
                  ),
                if (exReq.returnTrackingNumber?.isNotEmpty == true)
                  _detailTile(Icons.track_changes_outlined, "Return Tracking",
                      exReq.returnTrackingNumber!, Colors.blue),
                if (exReq.replacementTrackingNumber?.isNotEmpty == true)
                  _detailTile(Icons.local_shipping_rounded, "Replacement Tracking",
                      exReq.replacementTrackingNumber!, Colors.green),
                if (exReq.refundAmount != null && exReq.refundAmount! > 0)
                  _detailTile(Icons.currency_rupee_rounded, "Refunded",
                      "Rs ${exReq.refundAmount!.toStringAsFixed(0)} → Your Wallet ✅", Colors.green[700]!),

                // ✅ View Detail Button
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExchangeDetailScreen(exchangeId: exReq.id ?? ""),
                      ),
                    ).then((_) => _refreshExchangeStatus()),
                    icon: Icon(Icons.arrow_forward_rounded, size: 16.sp),
                    label: const Text("View Full Details"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.primaryColor,
                      side: BorderSide(color: AppColor.primaryColor),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Refund Card ───────────────────────────────────────────────
  Widget _buildRefundCard(RefundRequestData refReq) {
    final info = _refundStatusInfo(refReq.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: info.color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.06),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.assignment_return_rounded, color: info.color, size: 20.sp),
                SizedBox(width: 8.w),
                Text("Refund Request",
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
                const Spacer(),
                _statusChip(info.title, info.color, info.icon),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeline(_refundStatuses, refReq.status),
                SizedBox(height: 16.h),

                if (refReq.reason?.isNotEmpty == true)
                  _detailTile(Icons.description_outlined, "Reason", refReq.reason!, Colors.grey[700]!),
                if (refReq.companyNote?.isNotEmpty == true)
                  _detailTile(Icons.comment_outlined, "Seller Note", refReq.companyNote!, Colors.orange[700]!),
                if (refReq.returnTrackingNumber?.isNotEmpty == true)
                  _detailTile(Icons.track_changes_outlined, "Return Tracking",
                      refReq.returnTrackingNumber!, Colors.blue),
                if (refReq.refundAmount != null && refReq.refundAmount! > 0)
                  _detailTile(Icons.currency_rupee_rounded, "Refunded",
                      "Rs ${refReq.refundAmount!.toStringAsFixed(0)} → Your Wallet ✅", Colors.green[700]!),

                // ✅ View Detail Button
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RefundDetailScreen(refundId: refReq.id ?? ""),
                      ),
                    ).then((_) => _refreshExchangeStatus()),
                    icon: Icon(Icons.arrow_forward_rounded, size: 16.sp),
                    label: const Text("View Full Details"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Products Card ─────────────────────────────────────────────
  Widget _buildProductsCard(
    List<Product> products,
    bool eligible,
    ExchangeRequestData? exReq,
    RefundRequestData? refReq,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: AppColor.primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text("Products",
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
            ],
          ),
          Divider(height: 20.h, color: Colors.grey[100]),
          ...products.map((p) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: (p.images?.isNotEmpty == true)
                          ? Image.network(
                              Global.getImageUrl(p.images!.first),
                              height: 80.h, width: 80.w, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fallbackImg(),
                            )
                          : _fallbackImg(),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name ?? "N/A",
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 6.h),
                          _productChip("Qty: ${p.quantity ?? 0}", Colors.blue),
                          SizedBox(height: 4.h),
                          _productChip("Price: Rs ${p.price ?? 0}", Colors.green),
                          SizedBox(height: 4.h),
                          _productChip("Total: Rs ${p.totalPrice ?? 0}", AppColor.primaryColor),
                        ],
                      ),
                    ),
                  ],
                ),

                // ✅ Exchange / Refund Buttons
                if (eligible && exReq == null && refReq == null) ...[
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      _actionButton(
                        label: "Exchange",
                        icon: Icons.swap_horiz_rounded,
                        color: Colors.blue,
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => ExchangeRequestSheet(order: _order, products: products),
                          );
                          if (mounted) _refreshExchangeStatus();
                        },
                      ),
                      SizedBox(width: 10.w),
                      _actionButton(
                        label: "Refund",
                        icon: Icons.money_off_rounded,
                        color: Colors.red,
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => RefundRequestSheet(order: _order, products: products),
                          );
                          if (mounted) _refreshExchangeStatus();
                        },
                      ),
                    ],
                  ),
                ] else if (_order.status == "Delivered" && exReq == null && refReq == null) ...[
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 14.sp, color: Colors.grey[400]),
                      SizedBox(width: 6.w),
                      Text("Return window expired (10 days after delivery)",
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey[400])),
                    ],
                  ),
                ],

                // ✅ Cancelled status message
                if (_order.status == "Cancelled") ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined, color: Colors.red, size: 18.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "This order has been cancelled.",
                            style: TextStyle(fontSize: 12.sp, color: Colors.red[700], fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // ── Price Summary Card ────────────────────────────────────────
  Widget _buildPriceSummaryCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primaryColor.withOpacity(0.9), AppColor.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColor.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Shipment Charges", style: TextStyle(fontSize: 13.sp, color: Colors.white70)),
              Text("Rs ${_order.shipmentCharges ?? 0}",
                  style: TextStyle(fontSize: 13.sp, color: Colors.white70, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 8.h),
          Container(height: 1, color: Colors.white24),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Grand Total",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white)),
              Text("Rs ${_order.grandTotal ?? 0}",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────
  Widget _buildInfoCard({
    required String title,
    IconData? icon,
    String? imagePath,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(imagePath != null ? 0 : 8.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(imagePath,
                            width: 36.sp, height: 36.sp, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(icon ?? Icons.store_outlined, color: iconColor, size: 22.sp)),
                      )
                    : Icon(icon ?? Icons.store_outlined, color: iconColor, size: 22.sp),
              ),
              SizedBox(width: 10.w),
              Text(title,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
            ],
          ),
          Divider(height: 20.h, color: Colors.grey[100]),
          ...children,
        ],
      ),
    );
  }

  // ── Timeline ──────────────────────────────────────────────────
  static const List<_StatusStep> _exchangeStatuses = [
    _StatusStep("Requested", "Pending", Icons.send_rounded),
    _StatusStep("Accepted", "Accepted", Icons.check_circle_outline),
    _StatusStep("Ship Item", "ReturnShipped", Icons.local_shipping_rounded),
    _StatusStep("Received", "ReturnReceived", Icons.inventory_2_rounded),
    _StatusStep("Inspection", "Inspecting", Icons.search_rounded),
    _StatusStep("Resolved", "ReplacementShipped", Icons.replay_circle_filled_rounded),
    _StatusStep("Done", "Completed", Icons.check_circle_rounded),
  ];

  static const List<_StatusStep> _refundStatuses = [
    _StatusStep("Requested", "Pending", Icons.send_rounded),
    _StatusStep("Accepted", "Accepted", Icons.check_circle_outline),
    _StatusStep("Ship Item", "ReturnShipped", Icons.local_shipping_rounded),
    _StatusStep("Received", "ReturnReceived", Icons.inventory_2_rounded),
    _StatusStep("Inspection", "Inspecting", Icons.search_rounded),
    _StatusStep("Refunded", "Refunded", Icons.account_balance_wallet_rounded),
    _StatusStep("Done", "Completed", Icons.check_circle_rounded),
  ];

  Widget _buildTimeline(List<_StatusStep> steps, String? currentStatus) {
    final isDenied = currentStatus == "Denied" || currentStatus == "Rejected";
    if (isDenied) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red[700], size: 20.sp),
            SizedBox(width: 8.w),
            Text("Request Denied",
                style: TextStyle(fontSize: 13.sp, color: Colors.red[700], fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    final statusOrder = steps.map((s) => s.statusKey).toList();
    final currentIndex = statusOrder.indexOf(currentStatus ?? '');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isDone = currentIndex >= i;
          final isCurrent = currentIndex == i;
          final isLast = i == steps.length - 1;

          return Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isCurrent ? 34.w : 28.w,
                    height: isCurrent ? 34.w : 28.w,
                    decoration: BoxDecoration(
                      color: isDone ? AppColor.primaryColor : Colors.grey[200],
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [BoxShadow(color: AppColor.primaryColor.withOpacity(0.4), blurRadius: 8)]
                          : null,
                    ),
                    child: Icon(step.icon,
                        size: isCurrent ? 17.sp : 14.sp,
                        color: isDone ? Colors.white : Colors.grey[400]),
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    width: 52.w,
                    child: Text(step.label,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: isDone ? AppColor.primaryColor : Colors.grey[400],
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              if (!isLast)
                Container(
                  width: 18.w, height: 2,
                  margin: EdgeInsets.only(bottom: 22.h),
                  color: i < currentIndex ? AppColor.primaryColor : Colors.grey[200],
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: Colors.grey[400]),
          SizedBox(width: 8.w),
          SizedBox(
            width: 70.w,
            child: Text(label,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 12.sp, color: Colors.black87, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                SizedBox(height: 3.h),
                Text(value,
                    style: TextStyle(fontSize: 13.sp, color: color, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          SizedBox(width: 4.w),
          Text(label,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _productChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(label, style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(label,
                  style: TextStyle(fontSize: 13.sp, color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackImg() => Container(
    height: 80.h, width: 80.w,
    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
    child: Icon(Icons.image_outlined, size: 28.sp, color: Colors.grey[400]),
  );

  // ── Status Data ───────────────────────────────────────────────
  _StatusInfo _exchangeStatusInfo(String? status) {
    switch (status) {
      case "Pending": return _StatusInfo("Awaiting Review", Colors.orange, Icons.pending_rounded);
      case "Accepted": return _StatusInfo("Accepted ✓", Colors.blue, Icons.check_circle_outline);
      case "Denied": return _StatusInfo("Declined", Colors.red, Icons.cancel_rounded);
      case "ReturnShipped": return _StatusInfo("Return In Transit", Colors.indigo, Icons.local_shipping_rounded);
      case "ReturnReceived": return _StatusInfo("Parcel Received", Colors.teal, Icons.inventory_2_rounded);
      case "Inspecting": return _StatusInfo("Under Inspection", Colors.purple, Icons.search_rounded);
      case "ApprovedInspection": return _StatusInfo("Inspection Passed ✓", Colors.green, Icons.verified_rounded);
      case "Disputed": return _StatusInfo("Under Dispute", Colors.red, Icons.warning_amber_rounded);
      case "ReplacementShipped": return _StatusInfo("Replacement Shipped 🚀", Colors.indigo, Icons.local_shipping_rounded);
      case "Refunded": return _StatusInfo("Refund Credited 💳", Colors.green, Icons.account_balance_wallet_rounded);
      case "Completed": return _StatusInfo("Complete ✅", Colors.green, Icons.check_circle_rounded);
      default: return _StatusInfo(status ?? "Unknown", Colors.grey, Icons.help_outline);
    }
  }

  _StatusInfo _refundStatusInfo(String? status) {
    switch (status) {
      case "Pending": return _StatusInfo("Refund Requested", Colors.orange, Icons.pending_rounded);
      case "Accepted": return _StatusInfo("Accepted ✓", Colors.blue, Icons.check_circle_outline);
      case "Rejected": return _StatusInfo("Declined", Colors.red, Icons.cancel_rounded);
      case "ReturnShipped": return _StatusInfo("Return In Transit", Colors.indigo, Icons.local_shipping_rounded);
      case "ReturnReceived": return _StatusInfo("Parcel Received", Colors.teal, Icons.inventory_2_rounded);
      case "Inspecting": return _StatusInfo("Under Inspection", Colors.purple, Icons.search_rounded);
      case "ApprovedInspection": return _StatusInfo("Inspection Passed ✓", Colors.green, Icons.verified_rounded);
      case "Disputed": return _StatusInfo("Under Dispute", Colors.red, Icons.warning_amber_rounded);
      case "Refunded": return _StatusInfo("Refund Credited 💳", Colors.green, Icons.account_balance_wallet_rounded);
      case "Completed": return _StatusInfo("Complete ✅", Colors.green, Icons.check_circle_rounded);
      default: return _StatusInfo(status ?? "Unknown", Colors.grey, Icons.help_outline);
    }
  }

  IconData _orderStatusIcon(String? s) {
    switch (s) {
      case "Pending": return Icons.hourglass_empty_rounded;
      case "Dispatched": return Icons.local_shipping_rounded;
      case "Delivered": return Icons.check_circle_rounded;
      case "Returned": return Icons.assignment_return_rounded;
      case "Cancelled": return Icons.cancel_rounded; // ✅ NEW
      default: return Icons.receipt_long_rounded;
    }
  }

  String _orderStatusTitle(String? s) {
    switch (s) {
      case "Pending": return "Order Placed ⏳";
      case "Dispatched": return "On The Way 🚀";
      case "Delivered": return "Delivered ✅";
      case "Returned": return "Returned 📦";
      case "Cancelled": return "Cancelled ❌"; // ✅ NEW
      default: return s ?? "Unknown";
    }
  }

  String _orderStatusSubtitle(String? s) {
    switch (s) {
      case "Pending": return "Being prepared for dispatch";
      case "Dispatched": return "Estimated delivery: 3-5 days";
      case "Delivered": return "Exchange available within 10 days";
      case "Returned": return "Return has been processed";
      case "Cancelled": return "This order has been cancelled"; // ✅ NEW
      default: return "";
    }
  }

  Color _orderStatusColor(String? s) {
    switch (s) {
      case "Pending": return Colors.orange;
      case "Dispatched": return Colors.blue;
      case "Delivered": return Colors.green;
      case "Returned": return Colors.indigo;
      case "Cancelled": return Colors.red; // ✅ NEW
      default: return Colors.grey;
    }
  }
}

// ── Helper Classes ────────────────────────────────────────────────────────────
class _StatusInfo {
  final String title;
  final Color color;
  final IconData icon;
  const _StatusInfo(this.title, this.color, this.icon);
}

class _StatusStep {
  final String label;
  final String statusKey;
  final IconData icon;
  const _StatusStep(this.label, this.statusKey, this.icon);
}