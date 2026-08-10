class FavouriteListModel {
  bool? success;
  List<Favourites>? favourites;

  FavouriteListModel({this.success, this.favourites});

  FavouriteListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['favourites'] != null) {
      favourites = <Favourites>[];
      json['favourites'].forEach((v) {
        favourites!.add(Favourites.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (favourites != null) {
      data['favourites'] = favourites!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Favourites {
  String? sId;
  List<String>? selectedSizes;
  List<String>? selectedColors;
  Product? product;
  Seller? seller;

  Favourites({
    this.sId,
    this.selectedSizes,
    this.selectedColors,
    this.product,
    this.seller,
  });

  Favourites.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    selectedSizes = json['selectedSizes'].cast<String>();
    selectedColors = json['selectedColors'].cast<String>();
    product = json['product'] != null
        ? Product.fromJson(json['product'])
        : null;
    seller = json['seller'] != null
        ? Seller.fromJson(json['seller'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['selectedSizes'] = selectedSizes;
    data['selectedColors'] = selectedColors;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (seller != null) {
      data['seller'] = seller!.toJson();
    }
    return data;
  }
}

class Product {
  String? sId;
  String? name;
  int? beforeDiscountPrice;
  int? afterDiscountPrice;
  String? image;
  int? quantity;

  Product({
    this.sId,
    this.name,
    this.beforeDiscountPrice,
    this.afterDiscountPrice,
    this.image,
    this.quantity,
  });

  Product.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    beforeDiscountPrice = json['beforeDiscountPrice'];
    afterDiscountPrice = json['afterDiscountPrice'];
    image = json['image'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['beforeDiscountPrice'] = beforeDiscountPrice;
    data['afterDiscountPrice'] = afterDiscountPrice;
    data['image'] = image;
    data['quantity'] = quantity;
    return data;
  }
}

class Seller {
  String? sId;
  String? name;
  String? image;

  Seller({this.sId, this.name, this.image});

  Seller.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}
