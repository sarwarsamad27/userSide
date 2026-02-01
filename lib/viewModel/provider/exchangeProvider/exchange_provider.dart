// exchange_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user_side/models/chatModel/exchangeRequestModel.dart';
import 'package:user_side/viewModel/repository/chatRepository/chat_repository.dart';

class ExchangeProvider extends ChangeNotifier {
  final ExchangeRepository repository = ExchangeRepository();

  bool loading = false;
  bool creating = false;

  ExchangeRequestListModel? listModel;
  ExchangeRequestModel? createModel;

  Future<void> fetchMyRequests(String buyerId) async {
    loading = true;
    notifyListeners();

    try {
      listModel = await repository.listMyExchangeRequests(buyerId);
    } catch (e) {
      listModel = ExchangeRequestListModel(message: "Error: $e", requests: []);
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> createRequest({
    required String buyerId,
    required String orderId,
    required String productId,
    required String reason,
    List<String>? images, // ✅ NEW
  }) async {
    creating = true;
    notifyListeners();

    bool ok = false;

    try {
      createModel = await repository.createExchangeRequest(
        buyerId: buyerId,
        orderId: orderId,
        productId: productId,
        reason: reason,
        images: images ?? [],
      );
      ok = (createModel?.exchangeRequest != null);
    } catch (e) {
      createModel = ExchangeRequestModel(message: "Error: $e");
    }

    creating = false;
    notifyListeners();
    return ok;
  }

  Future<File?> downloadPdf({
    required String requestId,
    required String buyerId,
    required Map<String, String> authHeaders,
    String? baseUrl,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    return repository.downloadExchangePdf(
      requestId: requestId,
      buyerId: buyerId,
      saveDir: dir,
      authHeaders: authHeaders,
      baseUrl: baseUrl,
    );
  }
}
