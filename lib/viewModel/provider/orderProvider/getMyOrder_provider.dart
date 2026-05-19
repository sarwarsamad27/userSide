import 'package:flutter/material.dart';
import 'package:user_side/models/order/myOrderModel.dart';
import 'package:user_side/resources/local_storage.dart';
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

  Future<void> fetchMyOrders({bool isRefresh = false}) async {
    // Prevent concurrent fetches — the scroll listener can fire many times
    if (_isFetching) return;
    _isFetching = true;

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
