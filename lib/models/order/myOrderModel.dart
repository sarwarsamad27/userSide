import 'package:user_side/models/chatModel/chatModel.dart';

class MyOrderModel {
  bool? success;
  int? totalItems;
  int? page;
  int? limit;
  int? totalPages;
  List<Orders>? orders;

  MyOrderModel({
    this.success,
    this.totalItems,
    this.page,
    this.limit,
    this.totalPages,
    this.orders,
  });

  MyOrderModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    totalItems = json['totalItems'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(new Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['totalItems'] = this.totalItems;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['totalPages'] = this.totalPages;
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  String? id;
  String? orderId;
  String? buyerId;
  Seller? seller;
  int? shipmentCharges;
  int? grandTotal;
  String? status;
  String? createdAt;
  BuyerDetails? buyerDetails;
  Product? product;
  ExchangeRequestData? exchangeRequest;
  RefundRequestData? refundRequest;
  Orders({
    this.id,
    this.orderId,
    this.buyerId,
    this.seller,
    this.shipmentCharges,
    this.grandTotal,
    this.status,
    this.createdAt,
    this.buyerDetails,
    this.product,
    this.exchangeRequest,
    this.refundRequest,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['_id'];
    orderId = json['orderId'];
    buyerId = json['buyerId'];
    seller = json['seller'] != null
        ? new Seller.fromJson(json['seller'])
        : null;
    shipmentCharges = json['shipmentCharges'];
    grandTotal = json['grandTotal'];
    status = json['status'];
    createdAt = json['createdAt'];
    buyerDetails = json['buyerDetails'] != null
        ? new BuyerDetails.fromJson(json['buyerDetails'])
        : null;
    product = json['product'] != null
        ? new Product.fromJson(json['product'])
        : null;
     exchangeRequest = json['exchangeRequest'] != null
      ? ExchangeRequestData.fromJson(json['exchangeRequest'])
      : null;
  refundRequest = json['refundRequest'] != null
      ? RefundRequestData.fromJson(json['refundRequest'])
      : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['orderId'] = this.orderId;
    data['buyerId'] = this.buyerId;
    if (this.seller != null) {
      data['seller'] = this.seller!.toJson();
    }
    data['shipmentCharges'] = this.shipmentCharges;
    data['grandTotal'] = this.grandTotal;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    if (this.buyerDetails != null) {
      data['buyerDetails'] = this.buyerDetails!.toJson();
    }
    if (this.product != null) {
      data['product'] = this.product!.toJson();
      
    }
    return data;
  }
}


class ExchangeRequestData {
  final String? id;
  final String? status;
  final String? reason;
  final String? reasonCategory;
  final String? companyNote;
  final String? resolutionType;
  final String? courierPaidBy;
  final String? returnTrackingNumber;
  final String? replacementTrackingNumber;
  final double? refundAmount;
  final String? createdAt;

  const ExchangeRequestData({
    this.id,
    this.status,
    this.reason,
    this.reasonCategory,
    this.companyNote,
    this.resolutionType,
    this.courierPaidBy,
    this.returnTrackingNumber,
    this.replacementTrackingNumber,
    this.refundAmount,
    this.createdAt,
  });

  factory ExchangeRequestData.fromJson(Map<String, dynamic> json) =>
      ExchangeRequestData(
        id: json['_id'],
        status: json['status'],
        reason: json['reason'],
        reasonCategory: json['reasonCategory'],
        companyNote: json['companyNote'],
        resolutionType: json['resolutionType'],
        courierPaidBy: json['courierPaidBy'],
        returnTrackingNumber: json['returnTrackingNumber'],
        replacementTrackingNumber: json['replacementTrackingNumber'],
        refundAmount: (json['refundAmount'] as num?)?.toDouble(),
        createdAt: json['createdAt'],
      );
}

// ── Refund Request Data ────────────────────────────────────────────────────
class RefundRequestData {
  final String? id;
  final String? status;
  final String? reason;
  final String? reasonCategory;
  final String? companyNote;
  final double? refundAmount;
  final String? returnTrackingNumber;
  final String? createdAt;

  const RefundRequestData({
    this.id,
    this.status,
    this.reason,
    this.reasonCategory,
    this.companyNote,
    this.refundAmount,
    this.returnTrackingNumber,
    this.createdAt,
  });

  factory RefundRequestData.fromJson(Map<String, dynamic> json) =>
      RefundRequestData(
        id: json['_id'],
        status: json['status'],
        reason: json['reason'],
        reasonCategory: json['reasonCategory'],
        companyNote: json['companyNote'],
        refundAmount: (json['refundAmount'] as num?)?.toDouble(),
        returnTrackingNumber: json['returnTrackingNumber'],
        createdAt: json['createdAt'],
      );
}


class Seller {
  String? sId;
  String? userId;
  String? image;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Seller({
    this.sId,
    this.userId,
    this.image,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Seller.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    image = json['image'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['image'] = this.image;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['description'] = this.description;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class BuyerDetails {
  String? name;
  String? email;
  String? phone;
  String? address;
  String? additionalNote;

  BuyerDetails({
    this.name,
    this.email,
    this.phone,
    this.address,
    this.additionalNote,
  });

  BuyerDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    additionalNote = json['additionalNote'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['additionalNote'] = this.additionalNote;
    return data;
  }
}

class Product {
  String? productId;
  String? name;
  int? quantity;
  int? price;
  int? totalPrice;
  List<String>? selectedColor;
  List<String>? selectedSize;
  List<String>? images;
  String? stock;
  String? description;
  Review? review;
  ExchangeRequest? exchangeRequest;
  RefundRequest? refundRequest;

  Product({
    this.productId,
    this.name,
    this.quantity,
    this.price,
    this.totalPrice,
    this.selectedColor,
    this.selectedSize,
    this.images,
    this.stock,
    this.description,
    this.review,
    this.exchangeRequest,
    this.refundRequest,
  });

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    name = json['name'];
    quantity = json['quantity'];
    price = json['price'];
    totalPrice = json['totalPrice'];
    selectedColor = json['selectedColor'] != null
        ? json['selectedColor'].cast<String>()
        : [];
    selectedSize = json['selectedSize'] != null
        ? json['selectedSize'].cast<String>()
        : [];
    images = json['images'] != null ? json['images'].cast<String>() : [];
    stock = json['stock'];
    description = json['description'];
    review = json['review'] != null
        ? new Review.fromJson(json['review'])
        : null;
    exchangeRequest = json['exchangeRequest'] != null
        ? new ExchangeRequest.fromJson(json['exchangeRequest'])
        : null;
    refundRequest = json['refundRequest'] != null
        ? new RefundRequest.fromJson(json['refundRequest'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['totalPrice'] = this.totalPrice;
    data['selectedColor'] = this.selectedColor;
    data['selectedSize'] = this.selectedSize;
    data['images'] = this.images;
    data['stock'] = this.stock;
    data['description'] = this.description;
    if (this.review != null) {
      data['review'] = this.review!.toJson();
    }
    if (this.exchangeRequest != null) {
      data['exchangeRequest'] = this.exchangeRequest!.toJson();
    }
    if (this.refundRequest != null) {
      data['refundRequest'] = this.refundRequest!.toJson();
    }
    return data;
  }
}

class ExchangeRequest {
  String? id;
  String? status;
  String? reason;
  String? companyNote;
  String? pdfPath;

  ExchangeRequest({
    this.id,
    this.status,
    this.reason,
    this.companyNote,
    this.pdfPath,
  });

  ExchangeRequest.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    status = json['status'];
    reason = json['reason'];
    companyNote = json['companyNote'];
    pdfPath = json['pdfPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['status'] = this.status;
    data['reason'] = this.reason;
    data['companyNote'] = this.companyNote;
    data['pdfPath'] = this.pdfPath;
    return data;
  }
}

class RefundRequest {
  String? id;
  String? status;
  String? reason;
  String? companyNote;
  String? pdfPath;
  int? refundAmount;

  RefundRequest({
    this.id,
    this.status,
    this.reason,
    this.companyNote,
    this.pdfPath,
    this.refundAmount,
  });

  RefundRequest.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    status = json['status'];
    reason = json['reason'];
    companyNote = json['companyNote'];
    pdfPath = json['pdfPath'];
    refundAmount = json['refundAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['status'] = this.status;
    data['reason'] = this.reason;
    data['companyNote'] = this.companyNote;
    data['pdfPath'] = this.pdfPath;
    data['refundAmount'] = this.refundAmount;
    return data;
  }
}

class Review {
  String? sId;
  String? productId;
  String? userId;
  int? stars;
  String? text;
  Reply? reply;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Review({
    this.sId,
    this.productId,
    this.userId,
    this.stars,
    this.text,
    this.reply,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Review.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    productId = json['productId'];
    userId = json['userId'];
    stars = json['stars'];
    text = json['text'];
    reply = json['reply'] != null ? new Reply.fromJson(json['reply']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['productId'] = this.productId;
    data['userId'] = this.userId;
    data['stars'] = this.stars;
    data['text'] = this.text;
    if (this.reply != null) {
      data['reply'] = this.reply!.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Reply {
  String? text;
  String? repliedAt;

  Reply({this.text, this.repliedAt});

  Reply.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    repliedAt = json['repliedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['repliedAt'] = this.repliedAt;
    return data;
  }
}
