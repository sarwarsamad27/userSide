class ExchangeRequestModel {
  String? message;
  ExchangeRequest? exchangeRequest;

  ExchangeRequestModel({this.message, this.exchangeRequest});

  factory ExchangeRequestModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRequestModel(
      message: json["message"],
      exchangeRequest: json["exchangeRequest"] != null
          ? ExchangeRequest.fromJson(json["exchangeRequest"])
          : null,
    );
  }
}

class ExchangeRequestListModel {
  String? message;
  List<ExchangeRequest>? requests;

  ExchangeRequestListModel({this.message, this.requests});

  factory ExchangeRequestListModel.fromJson(Map<String, dynamic> json) {
    final list = (json["requests"] as List?) ?? [];
    return ExchangeRequestListModel(
      message: json["message"],
      requests: list.map((e) => ExchangeRequest.fromJson(e)).toList(),
    );
  }
}

class ExchangeRequest {
  String? id; // _id
  String? orderId;
  String? productId;
  String? buyerId;
  String? sellerProfileId;
  String? reason;
  String? status; // Pending/Accepted/Denied etc
  String? deliveredAt;
  String? expiresAt;
  String? pdfPath;

  List<String>? images; // ✅ NEW (server returns paths array)

  String? createdAt;
  String? updatedAt;

  ExchangeRequest({
    this.id,
    this.orderId,
    this.productId,
    this.buyerId,
    this.sellerProfileId,
    this.reason,
    this.status,
    this.deliveredAt,
    this.expiresAt,
    this.pdfPath,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory ExchangeRequest.fromJson(Map<String, dynamic> json) {
    final imgs = (json["images"] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return ExchangeRequest(
      id: json["_id"],
      orderId: json["orderId"]?.toString(),
      productId: json["productId"]?.toString(),
      buyerId: json["buyerId"]?.toString(),
      sellerProfileId: json["sellerProfileId"]?.toString(),
      reason: json["reason"],
      status: json["status"],
      deliveredAt: json["deliveredAt"]?.toString(),
      expiresAt: json["expiresAt"]?.toString(),
      pdfPath: json["pdfPath"]?.toString(),
      images: imgs, // ✅ NEW
      createdAt: json["createdAt"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }
}
