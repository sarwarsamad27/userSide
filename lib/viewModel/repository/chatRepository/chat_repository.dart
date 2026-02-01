import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:user_side/models/chatModel/exchangeRequestModel.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class ExchangeRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  /// ✅ CREATE exchange request (reason + max 5 images base64)
  Future<ExchangeRequestModel> createExchangeRequest({
    required String buyerId,
    required String orderId,
    required String productId,
    required String reason,
    List<String> images = const [], // ✅ NEW
  }) async {
    try {
      // ✅ ensure max 5
      final safeImages = images.length > 5 ? images.take(5).toList() : images;

      final body = {
        "buyerId": buyerId,
        "orderId": orderId,
        "productId": productId,
        "reason": reason,
        "images": safeImages, // ✅ NEW
      };

      print("Creating Exchange Request: $body");

      final response = await apiServices.postApi(
        Global.createExchangeRequest,
        body,
      );

      print("Exchange Request Response: $response");

      return ExchangeRequestModel.fromJson(response);
    } catch (e) {
      print("Exchange Request Error: $e");
      return ExchangeRequestModel(message: "Error: $e");
    }
  }

  /// ✅ LIST my requests
  Future<ExchangeRequestListModel> listMyExchangeRequests(String buyerId) async {
    try {
      final response = await apiServices.getApi(
        "${Global.getExchangeRequests}?buyerId=$buyerId",
      );

      return ExchangeRequestListModel.fromJson(response);
    } catch (e) {
      print("List Exchange Requests Error: $e");
      return ExchangeRequestListModel(
        message: "Error: $e",
        requests: const [],
      );
    }
  }

  /// ✅ DOWNLOAD pdf
  Future<File?> downloadExchangePdf({
    required String requestId,
    required String buyerId,
    required Directory saveDir,
    required Map<String, String> authHeaders,
    String? baseUrl,
  }) async {
    try {
      final String url = _buildPdfUrl(requestId, buyerId, baseUrl: baseUrl);

      print("Downloading PDF from: $url");

      final resp = await http.get(Uri.parse(url), headers: authHeaders);

      if (resp.statusCode != 200) {
        // try parse json error message
        try {
          final m = json.decode(resp.body);
          throw (m["message"] ?? "PDF download failed");
        } catch (_) {
          throw ("PDF download failed (${resp.statusCode})");
        }
      }

      final file = File("${saveDir.path}/exchange_$requestId.pdf");
      await file.writeAsBytes(resp.bodyBytes, flush: true);

      print("PDF saved to: ${file.path}");
      return file;
    } catch (e) {
      print("PDF Download Error: $e");
      return null;
    }
  }

  /// ✅ Build PDF url (baseUrl optional)
  String _buildPdfUrl(String id, String buyerId, {String? baseUrl}) {
    final root = (baseUrl?.trim().isNotEmpty ?? false) ? baseUrl!.trim() : "";
    // Global.getExchangePdf should already be like: {BaseUrl}/buyer/get/exchange
    // your route: /buyer/get/exchange/:id/pdf?buyerId=xxx
    final base = root.isNotEmpty ? root : ""; // optional override

    // If you are already storing full url in Global.getExchangePdf (recommended),
    // then `base` stays empty and it works same.
    final endpoint = Global.getExchangePdf; // e.g. "${BaseUrl}/buyer/get/exchange"

    return "${base.isNotEmpty ? base : endpoint}/$id/pdf?buyerId=$buyerId";
  }
}
