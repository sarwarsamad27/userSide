class MyOrderModel {
  bool? success;
  int? totalItems;
  int? page;
  int? limit;
  int? totalPages;
  List<Orders>? orders;

  MyOrderModel(
      {this.success,
      this.totalItems,
      this.page,
      this.limit,
      this.totalPages,
      this.orders});

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
  String? orderId;
  String? buyerId;
  Seller? seller;
  int? shipmentCharges;
  int? grandTotal;
  String? status;
  String? createdAt;
  BuyerDetails? buyerDetails;
  Product? product;

  Orders(
      {this.orderId,
      this.buyerId,
      this.seller,
      this.shipmentCharges,
      this.grandTotal,
      this.status,
      this.createdAt,
      this.buyerDetails,
      this.product});

  Orders.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    buyerId = json['buyerId'];
    seller =
        json['seller'] != null ? new Seller.fromJson(json['seller']) : null;
    shipmentCharges = json['shipmentCharges'];
    grandTotal = json['grandTotal'];
    status = json['status'];
    createdAt = json['createdAt'];
    buyerDetails = json['buyerDetails'] != null
        ? new BuyerDetails.fromJson(json['buyerDetails'])
        : null;
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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

  Seller(
      {this.sId,
      this.userId,
      this.image,
      this.name,
      this.email,
      this.phone,
      this.address,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.iV});

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

  BuyerDetails(
      {this.name, this.email, this.phone, this.address, this.additionalNote});

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

  Product(
      {this.productId,
      this.name,
      this.quantity,
      this.price,
      this.totalPrice,
      this.selectedColor,
      this.selectedSize,
      this.images,
      this.stock,
      this.description,
      this.review});

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    name = json['name'];
    quantity = json['quantity'];
    price = json['price'];
    totalPrice = json['totalPrice'];
    selectedColor = json['selectedColor'].cast<String>();
    selectedSize = json['selectedSize'].cast<String>();
    images = json['images'].cast<String>();
    stock = json['stock'];
    description = json['description'];
    review =
        json['review'] != null ? new Review.fromJson(json['review']) : null;
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

  Review(
      {this.sId,
      this.productId,
      this.userId,
      this.stars,
      this.text,
      this.reply,
      this.createdAt,
      this.updatedAt,
      this.iV});

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
