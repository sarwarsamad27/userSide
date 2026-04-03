// viewModel/repository/chatRepository/exchange_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:user_side/models/chatModel/exchangeRequestModel.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class ExchangeRepository {
  final NetworkApiServices _api = NetworkApiServices();

  // ─────────────────────────────────────────────────────────────
  // CREATE exchange request
  // ─────────────────────────────────────────────────────────────
  Future<ExchangeRequestModel> createExchangeRequest({
    required String buyerId,
    required String orderId,
    required String id, // ✅ MongoDB ObjectId
    required String productId,
    required String reason,
    required String reasonCategory,
    List<String> images = const [],
  }) async {
    try {
      final body = {
        "buyerId": buyerId,
        "orderId": orderId,
        "id": id, // ✅ Added
        "productId": productId,
        "reason": reason,
        "reasonCategory": reasonCategory,
        "images": images.take(5).toList(),
      };
      final response = await _api.postApi(Global.createExchangeRequest, body);
      return ExchangeRequestModel.fromJson(response);
    } catch (e) {
      return ExchangeRequestModel(message: "Error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LIST my requests
  // ─────────────────────────────────────────────────────────────
  Future<ExchangeRequestListModel> listMyExchangeRequests(
    String buyerId,
  ) async {
    try {
      final response = await _api.getApi(
        "${Global.getExchangeRequests}?buyerId=$buyerId",
      );
      return ExchangeRequestListModel.fromJson(response);
    } catch (e) {
      return ExchangeRequestListModel(message: "Error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────
  // UPLOAD RETURN PROOF
  // ─────────────────────────────────────────────────────────────
  Future<ExchangeRequestModel> uploadReturnProof({
    required String exchangeId,
    required String buyerId,
    required String trackingNumber,
    required String courierName,
    List<String> proofImages = const [],
  }) async {
    try {
      final body = {
        "buyerId": buyerId,
        "trackingNumber": trackingNumber,
        "courierName": courierName,
        "proofImages": proofImages.take(5).toList(),
      };
      // ✅ Global.uploadReturnProof is now a function
      final response = await _api.postApi(
        Global.uploadReturnProof(exchangeId),
        body,
      );
      return ExchangeRequestModel.fromJson(response);
    } catch (e) {
      return ExchangeRequestModel(message: "Error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────
  // DOWNLOAD PDF
  // ─────────────────────────────────────────────────────────────
  Future<File?> downloadExchangePdf({
    required String requestId,
    required String buyerId,
    required Directory saveDir,
    required Map<String, String> authHeaders,
  }) async {
    try {
      // ✅ Global.getExchangePdf is now a function
      final url = "${Global.getExchangePdf(requestId)}?buyerId=$buyerId";
      final resp = await http.get(Uri.parse(url), headers: authHeaders);
      if (resp.statusCode != 200) return null;
      final file = File("${saveDir.path}/exchange_$requestId.pdf");
      await file.writeAsBytes(resp.bodyBytes, flush: true);
      return file;
    } catch (e) {
      return null;
    }
  }
}
