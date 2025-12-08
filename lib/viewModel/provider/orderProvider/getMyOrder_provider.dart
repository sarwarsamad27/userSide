import 'package:flutter/material.dart';
import 'package:user_side/models/order/myOrderModel.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/repository/orderRepository/getOrder_repository.dart';

class GetMyOrderProvider with ChangeNotifier {
  final GetMyOrderRepository _repo = GetMyOrderRepository();

  bool isLoading = false;
  bool isMoreLoading = false;

  int page = 1;
  final int limit = 10;

  bool hasMore = true;

  List<Orders> orderList = [];

  Future<void> fetchMyOrders({bool isRefresh = false}) async {
    final buyerId = await LocalStorage.getUserId();

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

    final data = await _repo.getMyOrder(buyerId!, limit, page);

    if (data.success == true) {
      /// list append
      orderList.addAll(data.orders ?? []);

      /// check more data
      hasMore = (data.page! < data.totalPages!);

      /// next page
      if (hasMore) page++;
    }

    isLoading = false;
    isMoreLoading = false;
    notifyListeners();
  }
}
