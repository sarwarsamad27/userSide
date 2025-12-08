class FavouriteListModel {
  bool? success;
  List<Favourites>? favourites;

  FavouriteListModel({this.success, this.favourites});

  FavouriteListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['favourites'] != null) {
      favourites = <Favourites>[];
      json['favourites'].forEach((v) {
        favourites!.add(new Favourites.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.favourites != null) {
      data['favourites'] = this.favourites!.map((v) => v.toJson()).toList();
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

  Favourites(
      {this.sId,
      this.selectedSizes,
      this.selectedColors,
      this.product,
      this.seller});

  Favourites.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    selectedSizes = json['selectedSizes'].cast<String>();
    selectedColors = json['selectedColors'].cast<String>();
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
    seller =
        json['seller'] != null ? new Seller.fromJson(json['seller']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['selectedSizes'] = this.selectedSizes;
    data['selectedColors'] = this.selectedColors;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    if (this.seller != null) {
      data['seller'] = this.seller!.toJson();
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

  Product(
      {this.sId,
      this.name,
      this.beforeDiscountPrice,
      this.afterDiscountPrice,
      this.image});

  Product.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    beforeDiscountPrice = json['beforeDiscountPrice'];
    afterDiscountPrice = json['afterDiscountPrice'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['beforeDiscountPrice'] = this.beforeDiscountPrice;
    data['afterDiscountPrice'] = this.afterDiscountPrice;
    data['image'] = this.image;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}
