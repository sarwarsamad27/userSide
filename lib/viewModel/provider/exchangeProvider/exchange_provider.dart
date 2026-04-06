// viewModel/provider/exchangeProvider/exchange_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user_side/models/chatModel/exchangeRequestModel.dart';
import 'package:user_side/viewModel/repository/chatRepository/chat_repository.dart';

class ExchangeProvider extends ChangeNotifier {
  final ExchangeRepository _repo = ExchangeRepository();

  // ── State ─────────────────────────────────────────────────────
  bool loading = false;
  bool creating = false;
  bool uploadingProof = false;

  ExchangeRequestListModel? listModel;
  RefundRequestListModel? refundListModel; // ✅
  ExchangeRequestModel? createModel;
  RefundRequestModel? createRefundModel; // ✅
  ExchangeRequestModel? proofModel;

  String? errorMessage;

  // ── Fetch list ────────────────────────────────────────────────
  Future<void> fetchMyRequests(String buyerId) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      listModel = await _repo.listMyExchangeRequests(buyerId);
    } catch (e) {
      errorMessage = "Failed to load exchanges: $e";
    }
    loading = false;
    notifyListeners();
  }

  Future<void> fetchMyRefunds(String buyerId) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      refundListModel = await _repo.listMyRefundRequests(buyerId);
    } catch (e) {
      errorMessage = "Failed to load refunds: $e";
    }
    loading = false;
    notifyListeners();
  }

  // ── Create request ────────────────────────────────────────────
  Future<bool> createRequest({
    required String buyerId,
    required String orderId,
    required String id,
    required String productId,
    required String reason,
    required String reasonCategory,
    List<String> images = const [],
  }) async {
    creating = true;
    errorMessage = null;
    notifyListeners();

    bool ok = false;
    try {
      createModel = await _repo.createExchangeRequest(
        buyerId: buyerId,
        orderId: orderId,
        id: id,
        productId: productId,
        reason: reason,
        reasonCategory: reasonCategory,
        images: images,
      );
      ok = createModel?.exchangeRequest != null;
      if (!ok) errorMessage = createModel?.message;
    } catch (e) {
      errorMessage = "Error: $e";
    }

    creating = false;
    notifyListeners();
    return ok;
  }

  Future<bool> createRefund({
    required String buyerId,
    required String orderId,
    required String id,
    required String productId,
    required String reason,
    required String reasonCategory,
    List<String> images = const [],
  }) async {
    creating = true;
    errorMessage = null;
    notifyListeners();

    bool ok = false;
    try {
      createRefundModel = await _repo.createRefundRequest(
        buyerId: buyerId,
        orderId: orderId,
        id: id,
        productId: productId,
        reason: reason,
        reasonCategory: reasonCategory,
        images: images,
      );
      ok = createRefundModel?.refundRequest != null;
      if (!ok) errorMessage = createRefundModel?.message;
    } catch (e) {
      errorMessage = "Error: $e";
    }

    creating = false;
    notifyListeners();
    return ok;
  }

  // ── Upload return proof ───────────────────────────────────────
  Future<bool> uploadReturnProof({
    required String exchangeId,
    required String buyerId,
    required String trackingNumber,
    required String courierName,
    List<String> proofImages = const [],
  }) async {
    uploadingProof = true;
    errorMessage = null;
    notifyListeners();

    bool ok = false;
    try {
      proofModel = await _repo.uploadReturnProof(
        exchangeId: exchangeId,
        buyerId: buyerId,
        trackingNumber: trackingNumber,
        courierName: courierName,
        proofImages: proofImages,
      );
      ok = proofModel?.exchangeRequest != null;
      if (!ok) errorMessage = proofModel?.message;

      // Update local list
      if (ok && listModel != null) {
        final updated = listModel!.requests.map((r) {
          if (r.id == exchangeId) return proofModel!.exchangeRequest!;
          return r;
        }).toList();
        listModel = ExchangeRequestListModel(
          message: listModel!.message,
          requests: updated,
        );
      }
    } catch (e) {
      errorMessage = "Error: $e";
    }

    uploadingProof = false;
    notifyListeners();
    return ok;
  }

  // ── Download PDF ──────────────────────────────────────────────
  Future<File?> downloadPdf({
    required String requestId,
    required String buyerId,
    required Map<String, String> authHeaders,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return await _repo.downloadExchangePdf(
        requestId: requestId,
        buyerId: buyerId,
        saveDir: dir,
        authHeaders: authHeaders,
      );
    } catch (e) {
      errorMessage = "PDF download failed: $e";
      notifyListeners();
      return null;
    }
  }
}
