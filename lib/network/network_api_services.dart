import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:user_side/exception/exceptions.dart';
import 'package:user_side/network/base_api_services.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/premium_toast.dart';

class NetworkApiServices extends BaseApiServices {
  // ✅ Existing headers (WITH token if available) - unchanged
  Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    final token = await LocalStorage.getToken();
    print("Token: $token"); // Debugging token value

    return {
      "Accept": "application/json",
      if (!isMultipart) "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // ✅ NEW: Headers WITHOUT token (No Authorization)
  Future<Map<String, String>> getHeadersNoAuth({
    bool isMultipart = false,
  }) async {
    return {
      "Accept": "application/json",
      if (!isMultipart) "Content-Type": "application/json",
    };
  }

  // ✅ Existing POST (WITH token if available) - unchanged
  @override
  Future<Map<String, dynamic>> postApi(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(url, response, body: body);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ✅ NEW: POST WITHOUT token (for Login/Register/Google)
  Future<Map<String, dynamic>> postApiNoAuth(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await getHeadersNoAuth(),
        body: jsonEncode(body),
      );
      return _handleResponse(url, response, body: body);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ✅ Existing GET (WITH token if available) - unchanged
  @override
  Future<Map<String, dynamic>> getApi(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      );
      return _handleResponse(url, response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ✅ NEW: GET WITHOUT token
  Future<Map<String, dynamic>> getApiNoAuth(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await getHeadersNoAuth(),
      );
      return _handleResponse(url, response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ✅ Existing PUT - unchanged
  @override
  Future<Map<String, dynamic>> putApi(
    String url,
    Map<String, dynamic> body, {
    File? image,
    String fileFieldName = "image",
  }) async {
    try {
      // If image is provided, use multipart PUT
      if (image != null) {
        var request = http.MultipartRequest('PUT', Uri.parse(url));

        // Headers
        final token = await LocalStorage.getToken();
        request.headers.addAll({
          "Accept": "application/json",
          if (token != null && token.isNotEmpty)
            "Authorization": "Bearer $token",
        });

        // Add text fields
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        // Add image
        final mimeType = image.path.split('.').last.toLowerCase(); // jpg/png
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            image.path,
            contentType: MediaType("image", mimeType),
          ),
        );

        // Send request
        var streamed = await request.send();
        var response = await http.Response.fromStream(streamed);

        print("PUT Multipart Response: ${response.body}");
        return jsonDecode(response.body);
      } else {
        // Plain JSON PUT
        final response = await http.put(
          Uri.parse(url),
          headers: await getHeaders(),
          body: jsonEncode(body),
        );

        return _handleResponse(url, response, body: body);
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  // ✅ NEW (optional): PUT WITHOUT token (JSON only)
  Future<Map<String, dynamic>> putApiNoAuth(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await getHeadersNoAuth(),
        body: jsonEncode(body),
      );

      return _handleResponse(url, response, body: body);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> putMultiPart({
    required String url,
    required Map<String, String> fields,
    required List<File> files,
    String fileFieldName = "images",
  }) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add headers
      final token = await LocalStorage.getToken();
      request.headers.addAll({
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      });

      // Add text fields
      request.fields.addAll(fields);

      // Add files
      for (var file in files) {
        final mimeType = file.path.split(".").last.toLowerCase();
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            contentType: MediaType("image", mimeType),
          ),
        );
      }

      // Send request
      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'code_status': false,
          'message': 'Server Error: ${response.body}',
        };
      }
    } catch (e) {
      return {'code_status': false, 'message': 'Exception: $e'};
    }
  }

  Future<Map<String, dynamic>> postSingleImageApi(
    String url,
    Map<String, String> fields,
    File? image, {
    String fileFieldName = "image",
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Correct Headers
      final token = await LocalStorage.getToken();
      request.headers.addAll({
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      });

      // Add Text Fields
      request.fields.addAll(fields);

      // Add Image Properly
      if (image != null) {
        final mimeType = image.path
            .split(".")
            .last
            .toLowerCase(); // jpg/png/jpeg

        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            image.path,
            contentType: MediaType("image", mimeType), // <-- IMPORTANT
          ),
        );
      }

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      print("Upload Response: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      return {'code_status': false, 'message': 'Exception: $e'};
    }
  }

  Future<Map<String, dynamic>> postMultipartApi(
    String url,
    Map<String, String> fields,
    List<File> images, {
    String fileFieldName = "images",
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add Authorization Header (IMPORTANT)
      final token = await LocalStorage.getToken();
      request.headers.addAll({
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      });

      // Add fields (text)
      request.fields.addAll(fields);

      // Add images
      for (var file in images) {
        request.files.add(
          await http.MultipartFile.fromPath(fileFieldName, file.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'code_status': false,
          'message': 'Server Error: ${response.body}',
        };
      }
    } catch (e) {
      return {'code_status': false, 'message': 'Exception: $e'};
    }
  }

  // ✅ Existing DELETE (WITH token if available) - unchanged
  @override
  Future<Map<String, dynamic>> deleteApi(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: await getHeaders(),
      );
      return _handleResponse(url, response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ✅ NEW: DELETE WITHOUT token
  Future<Map<String, dynamic>> deleteApiNoAuth(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: await getHeadersNoAuth(),
      );
      return _handleResponse(url, response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(
    String url,
    http.Response response, {
    Map<String, dynamic>? body,
  }) {
    if (kDebugMode) {
      print('✅ API URL: $url');
    }
    if (body != null) print('✅ Request Body: ${jsonEncode(body)}');
    if (kDebugMode) {
      print('✅ Status Code: ${response.statusCode}');
      print('✅ Response Body: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          return {'code_status': true, 'message': decoded.toString()};
        }
      } catch (e) {
        return {'code_status': true, 'message': response.body};
      }
    } else {
      String errorMsg = 'Server Error: ${response.body}';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('message')) {
          errorMsg = decoded['message'];
        }
      } catch (_) {}

      PremiumToast.error(null, errorMsg);
      return {'code_status': false, 'message': errorMsg};
    }
  }

  Map<String, dynamic> _handleError(e) {
    String message = 'Exception: $e';
    if (e is InternetException) {
      message = 'No Internet Connection';
    } else if (e is SocketException) {
      message = 'Network error: Please check your connection';
    }

    PremiumToast.error(null, message);
    return {'code_status': false, 'message': message};
  }
}
