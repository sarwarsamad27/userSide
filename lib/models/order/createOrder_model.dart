/// ══════════════════════════════════════════════════════════
///  createOrder_model.dart — UPDATED
///  Added: paymentMethod, paymentStatus, paymentNote fields
/// ══════════════════════════════════════════════════════════

class CreateOrderModel {
  String? message;
  Order? order;
  PaymentInfo? payment;

  CreateOrderModel({this.message, this.order, this.payment});

  CreateOrderModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    order   = json['order'] != null ? Order.fromJson(json['order']) : null;
    payment = json['payment'] != null ? PaymentInfo.fromJson(json['payment']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (order != null)   data['order']   = order!.toJson();
    if (payment != null) data['payment'] = payment!.toJson();
    return data;
  }
}

// ─── Payment Info (from backend response) ────────────────────────────────────
class PaymentInfo {
  String? method;   // "cod" | "wallet" | "jazzcash"
  String? status;   // "pending" | "paid"
  String? note;     // Human readable note shown to buyer

  PaymentInfo({this.method, this.status, this.note});

  PaymentInfo.fromJson(Map<String, dynamic> json) {
    method = json['method'];
    status = json['status'];
    note   = json['note'];
  }

  Map<String, dynamic> toJson() => {
    'method': method,
    'status': status,
    'note':   note,
  };

  bool get isPaid    => status == 'paid';
  bool get isCod     => method == 'cod';
  bool get isWallet  => method == 'wallet';
  bool get isJazzcash=> method == 'jazzcash';
}

// ─── Order ───────────────────────────────────────────────────────────────────
class Order {
  String? buyerId;
  String? profileId;
  List<Products>? products;
  int? shipmentCharges;
  int? grandTotal;
  BuyerDetails? buyerDetails;
  String? status;
  String? paymentMethod;    // NEW
  String? paymentStatus;    // NEW
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Order({
    this.buyerId,
    this.profileId,
    this.products,
    this.shipmentCharges,
    this.grandTotal,
    this.buyerDetails,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Order.fromJson(Map<String, dynamic> json) {
    buyerId         = json['buyerId'];
    profileId       = json['profileId'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) => products!.add(Products.fromJson(v)));
    }
    shipmentCharges = json['shipmentCharges'];
    grandTotal      = json['grandTotal'];
    buyerDetails    = json['buyerDetails'] != null
        ? BuyerDetails.fromJson(json['buyerDetails'])
        : null;
    status          = json['status'];
    paymentMethod   = json['paymentMethod'];    // NEW
    paymentStatus   = json['paymentStatus'];    // NEW
    sId             = json['_id'];
    createdAt       = json['createdAt'];
    updatedAt       = json['updatedAt'];
    iV              = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['buyerId']         = buyerId;
    data['profileId']       = profileId;
    if (products != null) data['products'] = products!.map((v) => v.toJson()).toList();
    data['shipmentCharges'] = shipmentCharges;
    data['grandTotal']      = grandTotal;
    if (buyerDetails != null) data['buyerDetails'] = buyerDetails!.toJson();
    data['status']          = status;
    data['paymentMethod']   = paymentMethod;
    data['paymentStatus']   = paymentStatus;
    data['_id']             = sId;
    data['createdAt']       = createdAt;
    data['updatedAt']       = updatedAt;
    data['__v']             = iV;
    return data;
  }
}

// ─── Products (unchanged) ─────────────────────────────────────────────────────
class Products {
  String? productId;
  String? name;
  int? quantity;
  int? price;
  int? totalPrice;
  List<String>? images;
  List<String>? selectedColor;
  List<String>? selectedSize;
  String? sId;

  Products({
    this.productId, this.name, this.quantity, this.price,
    this.totalPrice, this.images, this.selectedColor, this.selectedSize, this.sId,
  });

  Products.fromJson(Map<String, dynamic> json) {
    productId     = json['productId'];
    name          = json['name'];
    quantity      = json['quantity'];
    price         = json['price'];
    totalPrice    = json['totalPrice'];
    images        = json['images']?.cast<String>();
    selectedColor = json['selectedColor']?.cast<String>();
    selectedSize  = json['selectedSize']?.cast<String>();
    sId           = json['_id'];
  }

  Map<String, dynamic> toJson() => {
    'productId':     productId,
    'name':          name,
    'quantity':      quantity,
    'price':         price,
    'totalPrice':    totalPrice,
    'images':        images,
    'selectedColor': selectedColor,
    'selectedSize':  selectedSize,
    '_id':           sId,
  };
}

// ─── BuyerDetails (unchanged) ─────────────────────────────────────────────────
class BuyerDetails {
  String? name;
  String? email;
  String? phone;
  String? address;
  String? additionalNote;

  BuyerDetails({this.name, this.email, this.phone, this.address, this.additionalNote});

  BuyerDetails.fromJson(Map<String, dynamic> json) {
    name           = json['name'];
    email          = json['email'];
    phone          = json['phone'];
    address        = json['address'];
    additionalNote = json['additionalNote'];
  }

  Map<String, dynamic> toJson() => {
    'name':           name,
    'email':          email,
    'phone':          phone,
    'address':        address,
    'additionalNote': additionalNote,
  };
}

// ─── Wallet OTP Models ────────────────────────────────────────────────────────

/// Response from POST /buyer/wallet/order/send-otp
class WalletOtpSendModel {
  final bool success;
  final String message;
  final String? sessionId;
  final int? expiresIn;

  WalletOtpSendModel({
    required this.success,
    required this.message,
    this.sessionId,
    this.expiresIn,
  });

  factory WalletOtpSendModel.fromJson(Map<String, dynamic> json) {
    return WalletOtpSendModel(
      success:   true,
      message:   json['message'] ?? '',
      sessionId: json['sessionId'],
      expiresIn: json['expiresIn'],
    );
  }

  factory WalletOtpSendModel.error(String msg) =>
      WalletOtpSendModel(success: false, message: msg);
}

/// Response from POST /buyer/wallet/order/verify-otp
class WalletOtpVerifyModel {
  final bool success;
  final String message;
  final String? txnId;       // pass to createOrder as walletTxnId
  final double? amount;
  final double? newBalance;

  WalletOtpVerifyModel({
    required this.success,
    required this.message,
    this.txnId,
    this.amount,
    this.newBalance,
  });

  factory WalletOtpVerifyModel.fromJson(Map<String, dynamic> json) {
    return WalletOtpVerifyModel(
      success:    true,
      message:    json['message'] ?? '',
      txnId:      json['txnId'],
      amount:     (json['amount'] as num?)?.toDouble(),
      newBalance: (json['newBalance'] as num?)?.toDouble(),
    );
  }

  factory WalletOtpVerifyModel.error(String msg) =>
      WalletOtpVerifyModel(success: false, message: msg);
}

/// Response from POST /buyer/jazzcash/pay/initiate
class JazzcashInitiateModel {
  final bool success;
  final String message;
  final String? txnRefNo;
  final bool autoApproved;

  JazzcashInitiateModel({
    required this.success,
    required this.message,
    this.txnRefNo,
    this.autoApproved = false,
  });

  factory JazzcashInitiateModel.fromJson(Map<String, dynamic> json) {
    return JazzcashInitiateModel(
      success:      true,
      message:      json['message'] ?? '',
      txnRefNo:     json['txnRefNo'],
      autoApproved: json['autoApproved'] ?? false,
    );
  }

  factory JazzcashInitiateModel.error(String msg) =>
      JazzcashInitiateModel(success: false, message: msg);
}

/// Response from POST /buyer/jazzcash/pay/confirm
class JazzcashConfirmModel {
  final bool success;
  final String message;
  final String? txnRefNo;
  final bool confirmed;

  JazzcashConfirmModel({
    required this.success,
    required this.message,
    this.txnRefNo,
    this.confirmed = false,
  });

  factory JazzcashConfirmModel.fromJson(Map<String, dynamic> json) {
    return JazzcashConfirmModel(
      success:   true,
      message:   json['message'] ?? '',
      txnRefNo:  json['txnRefNo'],
      confirmed: json['confirmed'] ?? false,
    );
  }

  factory JazzcashConfirmModel.error(String msg) =>
      JazzcashConfirmModel(success: false, message: msg);
}