// models/chatThread/chatModel.dart (Company Side)

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
  final ProductCard? productCard; // ✅ NEW

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
    this.productCard, // ✅ NEW
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
    return (json["timestamp"] ??
            json["createdAt"] ??
            json["time"] ??
            json["date"])
        ?.toString();
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json["_id"] ?? json["id"] ?? json["messageId"])?.toString(),
      threadId: _extractThreadId(json),
      fromType: (json["fromType"] ?? json["senderType"] ?? json["from"])
          ?.toString(),
      fromId: (json["fromId"] ?? json["senderId"])?.toString(),
      text: (json["text"] ?? json["message"])?.toString(),
      timestamp: _extractTimestamp(json),
      deliveredAt: json["deliveredAt"]?.toString(),
      readAt: json["readAt"]?.toString(),
      isExchangeRequest:
          (json["isExchangeRequest"] ?? json["type"] == "exchange") == true,
      
      // ✅ exchangeData
      exchangeData: json["exchangeData"] != null && json["exchangeData"] is Map
          ? ExchangeRequestData.fromJson(
              (json["exchangeData"] as Map).cast<String, dynamic>(),
            )
          : null,

      // ✅ productCard
      productCard: json["productCard"] != null && json["productCard"] is Map
          ? ProductCard.fromJson(
              (json["productCard"] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}

// ✅ Product Card Model
class ProductCard {
  final String? productId;
  final String? productName;
  final String? productImage;
  final String? productPrice;
  final String? productDescription;
  final String? brandName;
  final String? sellerId;

  ProductCard({
    this.productId,
    this.productName,
    this.productImage,
    this.productPrice,
    this.productDescription,
    this.brandName,
    this.sellerId,
  });

  factory ProductCard.fromJson(Map<String, dynamic> json) {
    return ProductCard(
      productId: json["productId"]?.toString(),
      productName: json["productName"]?.toString(),
      productImage: json["productImage"]?.toString(),
      productPrice: json["productPrice"]?.toString(),
      productDescription: json["productDescription"]?.toString(),
      brandName: json["brandName"]?.toString(),
      sellerId: json["sellerId"]?.toString(),
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
    return ExchangeRequestData(
      exchangeId:
          (json["exchangeId"] ?? json["exchangeRequestId"] ?? json["_id"] ?? json["id"])
              ?.toString(),
      orderId: (json["orderId"] ?? json["order_id"])?.toString(),
      productId: (json["productId"] ?? json["product_id"])?.toString(),
      productName: (json["productName"] ?? json["product_name"])?.toString(),
      reason: (json["reason"] ?? json["note"])?.toString(),
      status: _normalizeStatus((json["status"])?.toString()),
      createdAt: (json["createdAt"] ?? json["timestamp"])?.toString(),
      images: (json["images"] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}