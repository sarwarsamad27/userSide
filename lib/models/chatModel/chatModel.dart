// models/chatModel/chatModel.dart

class ChatMessage {
  final String? id;
  final String? threadId;
  final String? fromType;
  final String? fromId;
  final String? text;
  final String? timestamp;
  final String? deliveredAt;
  final String? readAt;
  final bool isExchangeRequest;
  final ExchangeRequestData? exchangeData;

  ChatMessage({
    this.id,
    this.threadId,
    this.fromType,
    this.fromId,
    this.text,
    this.timestamp,
    this.deliveredAt,
    this.readAt,
    this.isExchangeRequest = false,
    this.exchangeData,
  });

  static String? _extractThreadId(Map<String, dynamic> json) {
    final direct = json["threadId"] ??
        json["chatThreadId"] ??
        json["thread_id"] ??
        json["threadID"];
    if (direct != null) return direct.toString();

    final thread = json["thread"];
    if (thread is String) return thread;
    if (thread is Map) {
      final tid = thread["_id"] ?? thread["id"] ?? thread["threadId"];
      if (tid != null) return tid.toString();
    }
    return null;
  }

  static String? _extractTimestamp(Map<String, dynamic> json) {
    return (json["timestamp"] ?? json["createdAt"] ?? json["time"] ?? json["date"])
        ?.toString();
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json["_id"] ?? json["id"] ?? json["messageId"])?.toString(),
      threadId: _extractThreadId(json),
      fromType: (json["fromType"] ?? json["senderType"] ?? json["from"])?.toString(),
      fromId: (json["fromId"] ?? json["senderId"])?.toString(),
      text: (json["text"] ?? json["message"])?.toString(),
      timestamp: _extractTimestamp(json),
      deliveredAt: json["deliveredAt"]?.toString(),
      readAt: json["readAt"]?.toString(),
      isExchangeRequest: (json["isExchangeRequest"] ?? (json["type"] == "exchange")) == true,

      // ✅ exchangeData can come either in "exchangeData" or "exchangeRequest"
      exchangeData: (() {
        final ex = json["exchangeData"];
        if (ex != null && ex is Map) {
          return ExchangeRequestData.fromJson(ex.cast<String, dynamic>());
        }
        final req = json["exchangeRequest"];
        if (req != null && req is Map) {
          return ExchangeRequestData.fromJson(req.cast<String, dynamic>());
        }
        return null;
      })(),
    );
  }
}

class ExchangeRequestData {
  final String? exchangeId;
  final String? orderId;
  final String? productId;
  final String? productName;
  final String? reason;
  final String? status;
  final String? createdAt;

  final List<String> images;

  ExchangeRequestData({
    this.exchangeId,
    this.orderId,
    this.productId,
    this.productName,
    this.reason,
    this.status,
    this.createdAt,
    this.images = const [],
  });

  static String _normalizeStatus(String? s) {
    final v = (s ?? "pending").toLowerCase();
    if (v == "denied") return "rejected";
    if (v == "reject") return "rejected";
    if (v == "approved") return "accepted";
    return v;
  }

  factory ExchangeRequestData.fromJson(Map<String, dynamic> json) {
    List<String> _pickImages(dynamic value) {
      if (value == null) return const [];
      if (value is List) return value.map((e) => e.toString()).toList();
      return const [];
    }

    // ✅ images can come in multiple keys depending on backend
    // priority:
    // 1) images
    // 2) image
    // 3) exchangeImages
    // 4) exchangeRequest.images (nested)
    final List<String> imgs =
        _pickImages(json["images"]).isNotEmpty ? _pickImages(json["images"]) :
        _pickImages(json["image"]).isNotEmpty ? _pickImages(json["image"]) :
        _pickImages(json["exchangeImages"]).isNotEmpty ? _pickImages(json["exchangeImages"]) :
        (json["exchangeRequest"] is Map)
            ? _pickImages((json["exchangeRequest"] as Map)["images"])
            : const [];

    return ExchangeRequestData(
      exchangeId: (json["exchangeId"] ??
              json["exchangeRequestId"] ??
              json["_id"] ??
              json["id"])
          ?.toString(),
      orderId: (json["orderId"] ?? json["order_id"])?.toString(),
      productId: (json["productId"] ?? json["product_id"])?.toString(),
      productName: (json["productName"] ?? json["product_name"])?.toString(),
      reason: (json["reason"] ?? json["note"])?.toString(),
      status: _normalizeStatus(json["status"]?.toString()),
      createdAt: (json["createdAt"] ?? json["timestamp"])?.toString(),
      images: imgs,
    );
  }
}
