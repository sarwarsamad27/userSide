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
  final bool isRefundRequest;
  final ExchangeRequestData? exchangeData;
  final RefundRequestData? refundData;
  final ProductCard? productCard;
  final String? replyToId;
  final String? replyToText;
  final String? replyToFromType;

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
    this.isRefundRequest = false,
    this.exchangeData,
    this.refundData,
    this.productCard,
    this.replyToId,
    this.replyToText,
    this.replyToFromType,
  });

  static String? _extractThreadId(Map<String, dynamic> json) {
    final direct = json["threadId"] ?? json["chatThreadId"] ?? json["thread_id"] ?? json["threadID"];
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
    return (json["timestamp"] ?? json["createdAt"] ?? json["time"] ?? json["date"])?.toString();
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
      isExchangeRequest: (json["isExchangeRequest"] ?? json["type"] == "exchange") == true,
      isRefundRequest: (json["isRefundRequest"] ?? json["type"] == "refund") == true,
      exchangeData: json["exchangeData"] != null && json["exchangeData"] is Map
          ? ExchangeRequestData.fromJson((json["exchangeData"] as Map).cast<String, dynamic>())
          : null,
      refundData: json["refundData"] != null && json["refundData"] is Map
          ? RefundRequestData.fromJson((json["refundData"] as Map).cast<String, dynamic>())
          : null,
      productCard: json["productCard"] != null && json["productCard"] is Map
          ? ProductCard.fromJson((json["productCard"] as Map).cast<String, dynamic>())
          : null,
      replyToId: json["replyToId"]?.toString(),
      replyToText: json["replyToText"]?.toString(),
      replyToFromType: json["replyToFromType"]?.toString(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// EXCHANGE REQUEST DATA
// ─────────────────────────────────────────────────────────────
class ExchangeRequestData {
  final String? exchangeId;
  final String? orderId;
  final String? productId;
  final String? productName;
  final String? reason;
  final String? reasonCategory;
  final String? status;
  final String? createdAt;
  final List<String> images;
  final String? companyNote;
  final String? pdfPath;
  final int? quantity;
  final List<String> selectedColor;
  final List<String> selectedSize;
  final String? requestedColor;
  final String? requestedSize;

  // ✅ NEW — after Accept
  final String? courierPaidBy;      // seller | buyer | platform
  final String? resolutionType;     // replacement | refund

  // ✅ NEW — return shipping
  final String? returnTrackingNumber;
  final String? returnCourierName;
  final String? returnShippedAt;

  // ✅ NEW — replacement
  final String? replacementTrackingNumber;
  final String? replacementCourierName;
  final String? replacementShippedAt;
  final String? replacementSlipLink; // ✅ Leopards slip

  // ✅ NEW — refund
  final double? refundAmount;
  final String? refundedAt;

  // ✅ NEW — inspection
  final String? inspectionNote;
  final String? disputeNote;

  ExchangeRequestData({
    this.exchangeId,
    this.orderId,
    this.productId,
    this.productName,
    this.reason,
    this.reasonCategory,
    this.status,
    this.createdAt,
    this.images = const [],
    this.companyNote,
    this.pdfPath,
    this.quantity,
    this.selectedColor = const [],
    this.selectedSize = const [],
    this.requestedColor,
    this.requestedSize,
    this.courierPaidBy,
    this.resolutionType,
    this.returnTrackingNumber,
    this.returnCourierName,
    this.returnShippedAt,
    this.replacementTrackingNumber,
    this.replacementCourierName,
    this.replacementShippedAt,
    this.replacementSlipLink,
    this.refundAmount,
    this.refundedAt,
    this.inspectionNote,
    this.disputeNote,
  });

  String get reasonCategoryLabel {
    switch (reasonCategory) {
      case "seller_fault": return "Wrong Item Received";
      case "defective": return "Defective / Damaged";
      case "size_color": return "Wrong Size / Color";
      case "size_issue": return "Size Issue";
      case "buyer_preference": return "Changed My Mind";
      default: return reasonCategory ?? "N/A";
    }
  }

  factory ExchangeRequestData.fromJson(Map<String, dynamic> json) {
    return ExchangeRequestData(
      exchangeId: (json["exchangeId"] ?? json["exchangeRequestId"] ?? json["_id"] ?? json["id"])?.toString(),
      orderId: (json["orderId"] ?? json["order_id"])?.toString(),
      productId: (json["productId"] ?? json["product_id"])?.toString(),
      productName: (json["productName"] ?? json["product_name"])?.toString(),
      reason: (json["reason"] ?? json["note"])?.toString(),
      reasonCategory: json["reasonCategory"]?.toString(),
      status: json["status"]?.toString(), // ✅ normalize hataya — raw status rakho
      createdAt: (json["createdAt"] ?? json["timestamp"])?.toString(),
      images: _toList(json["images"]),
      companyNote: json["companyNote"]?.toString(),
      pdfPath: json["pdfPath"]?.toString(),
      quantity: json["quantity"] is int
          ? json["quantity"]
          : int.tryParse(json["quantity"]?.toString() ?? ""),
      selectedColor: _toList(json["selectedColor"]),
      selectedSize: _toList(json["selectedSize"]),
      requestedColor: json["requestedColor"]?.toString(),
      requestedSize: json["requestedSize"]?.toString(),

      // ✅ NEW fields
      courierPaidBy: json["courierPaidBy"]?.toString(),
      resolutionType: json["resolutionType"]?.toString(),
      returnTrackingNumber: json["returnTrackingNumber"]?.toString(),
      returnCourierName: json["returnCourierName"]?.toString(),
      returnShippedAt: json["returnShippedAt"]?.toString(),
      replacementTrackingNumber: json["replacementTrackingNumber"]?.toString(),
      replacementCourierName: json["replacementCourierName"]?.toString(),
      replacementShippedAt: json["replacementShippedAt"]?.toString(),
      replacementSlipLink: json["replacementSlipLink"]?.toString(),
      refundAmount: json["refundAmount"] is num
          ? (json["refundAmount"] as num).toDouble()
          : double.tryParse(json["refundAmount"]?.toString() ?? ""),
      refundedAt: json["refundedAt"]?.toString(),
      inspectionNote: json["inspectionNote"]?.toString(),
      disputeNote: json["disputeNote"]?.toString(),
    );
  }

  static List<String> _toList(dynamic val) {
    if (val is List) return val.map((e) => e.toString()).toList();
    return const [];
  }
}

// ─────────────────────────────────────────────────────────────
// REFUND REQUEST DATA
// ─────────────────────────────────────────────────────────────
class RefundRequestData {
  final String? refundId;
  final String? orderId;
  final String? productId;
  final String? productName;
  final String? reason;
  final String? reasonCategory;
  final String? status;
  final String? createdAt;
  final List<String> images;
  final String? companyNote;
  final String? pdfPath;
  final int? quantity;
  final List<String> selectedColor;
  final List<String> selectedSize;
  final double? refundAmount;

  // ✅ NEW — return tracking
  final String? returnTrackingNumber;
  final String? returnCourierName;
  final String? returnShippedAt;

  // ✅ NEW — inspection
  final String? inspectionNote;
  final String? disputeNote;

  // ✅ NEW — timestamps
  final String? refundedAt;
  final String? completedAt;

  // ✅ Courier responsibility
  final String? courierPaidBy; // "seller" | "buyer"
  final double? courierCost;

  RefundRequestData({
    this.refundId,
    this.orderId,
    this.productId,
    this.productName,
    this.reason,
    this.reasonCategory,
    this.status,
    this.createdAt,
    this.images = const [],
    this.companyNote,
    this.pdfPath,
    this.quantity,
    this.selectedColor = const [],
    this.selectedSize = const [],
    this.refundAmount,
    this.returnTrackingNumber,
    this.returnCourierName,
    this.returnShippedAt,
    this.inspectionNote,
    this.disputeNote,
    this.refundedAt,
    this.completedAt,
    this.courierPaidBy,
    this.courierCost,
  });

  String get reasonCategoryLabel {
    switch (reasonCategory) {
      case "seller_fault": return "Wrong Item Received";
      case "defective": return "Defective / Damaged";
      case "size_issue": return "Size Issue";
      case "wrong_item": return "Different Product";
      case "buyer_preference": return "Changed My Mind";
      default: return reasonCategory ?? "N/A";
    }
  }

  factory RefundRequestData.fromJson(Map<String, dynamic> json) {
    return RefundRequestData(
      refundId: (json["refundId"] ?? json["exchangeId"] ?? json["id"] ?? json["_id"])?.toString(),
      orderId: (json["orderId"] ?? json["order_id"])?.toString(),
      productId: (json["productId"] ?? json["product_id"])?.toString(),
      productName: (json["productName"] ?? json["product_name"])?.toString(),
      reason: (json["reason"] ?? json["note"])?.toString(),
      reasonCategory: json["reasonCategory"]?.toString(),
      status: json["status"]?.toString(),
      createdAt: (json["createdAt"] ?? json["timestamp"])?.toString(),
      images: _toList(json["images"]),
      companyNote: json["companyNote"]?.toString(),
      pdfPath: json["pdfPath"]?.toString(),
      quantity: json["quantity"] is int
          ? json["quantity"]
          : int.tryParse(json["quantity"]?.toString() ?? ""),
      selectedColor: _toList(json["selectedColor"]),
      selectedSize: _toList(json["selectedSize"]),
      refundAmount: json["refundAmount"] is num
          ? (json["refundAmount"] as num).toDouble()
          : double.tryParse(json["refundAmount"]?.toString() ?? ""),

      // ✅ NEW fields
      returnTrackingNumber: json["returnTrackingNumber"]?.toString(),
      returnCourierName: json["returnCourierName"]?.toString(),
      returnShippedAt: json["returnShippedAt"]?.toString(),
      inspectionNote: json["inspectionNote"]?.toString(),
      disputeNote: json["disputeNote"]?.toString(),
      refundedAt: json["refundedAt"]?.toString(),
      completedAt: json["completedAt"]?.toString(),
      courierPaidBy: json["courierPaidBy"]?.toString(),
      courierCost: json["courierCost"] is num
          ? (json["courierCost"] as num).toDouble()
          : double.tryParse(json["courierCost"]?.toString() ?? ""),
    );
  }

  static List<String> _toList(dynamic val) {
    if (val is List) return val.map((e) => e.toString()).toList();
    return const [];
  }
}

// ─────────────────────────────────────────────────────────────
// PRODUCT CARD
// ─────────────────────────────────────────────────────────────
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