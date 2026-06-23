import 'package:flutter/material.dart';
import 'package:user_side/models/order/myOrderModel.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/offline_queue.dart';
import 'package:user_side/viewModel/repository/orderRepository/getOrder_repository.dart';

class GetMyOrderProvider with ChangeNotifier {
  final GetMyOrderRepository _repo = GetMyOrderRepository();

  bool isLoading = false;
  bool isMoreLoading = false;
  bool _isFetching = false; // guard against concurrent fetches

  int page = 1;
  final int limit = 10;

  bool hasMore = true;

  List<Orders> orderList = [];

  /// COD orders queued offline, not yet synced to the server. Kept as raw
  /// queue data (not converted to Orders) so they render in their own
  /// simple summary card rather than flowing through the full order-card
  /// logic (cancel/exchange/review), which assumes a real backend order id.
  List<Map<String, dynamic>> pendingOrders = [];

  Future<void> refreshPendingOrders() async {
    final items = await OfflineQueue.getAll();
    pendingOrders = items.where((e) => e['type'] == 'cod_order').toList();
    notifyListeners();
  }

  // Called from socket — update a single order's status in-place, no API hit
  void updateOrderStatus(
    String orderId, {
    String? status,
    String? cancelledBy,
    String? cancelReason,
  }) {
    final idx = orderList.indexWhere(
      (o) => o.id == orderId || o.orderId == orderId,
    );
    if (idx == -1) return;
    if (status != null) orderList[idx].status = status;
    if (cancelledBy != null) orderList[idx].cancelledBy = cancelledBy;
    if (cancelReason != null) orderList[idx].cancelReason = cancelReason;
    notifyListeners();
  }

  Future<void> fetchMyOrders({bool isRefresh = false}) async {
    // Prevent concurrent fetches — the scroll listener can fire many times
    if (_isFetching) return;
    _isFetching = true;

    await refreshPendingOrders();

    try {
      final buyerId = await LocalStorage.getUserId();
      if (buyerId == null) return;

      if (isRefresh) {
        page = 1;
        hasMore = true;
        orderList.clear();
        notifyListeners();
      }

      if (!hasMore) return;

      if (page == 1) {
        isLoading = true;
      } else {
        isMoreLoading = true;
      }
      notifyListeners();

      final data = await _repo.getMyOrder(buyerId, limit, page);

      if (data.success == true) {
        final incoming = data.orders ?? [];
        orderList.addAll(incoming);

        // Deduplicate by id — safety net in case of any double-fetch
        final seen = <String>{};
        orderList.retainWhere((o) => seen.add(o.id ?? o.orderId ?? ''));

        hasMore = (data.page! < data.totalPages!);
        if (hasMore) page++;
      }
    } finally {
      isLoading = false;
      isMoreLoading = false;
      _isFetching = false;
      notifyListeners();
    }
  }
}
