// models/recommendationModel/recommended_product_model.dart

class RecommendedProductModel {
  bool success;
  List<RecommendedProduct> products;

  RecommendedProductModel({
    required this.success,
    required this.products,
  });

  factory RecommendedProductModel.fromJson(Map<String, dynamic> json) {
    return RecommendedProductModel(
      success: true,
      products: json["products"] == null
          ? []
          : List<RecommendedProduct>.from(
              json["products"].map((x) => RecommendedProduct.fromJson(x))),
    );
  }
}

class RecommendedProduct {
  String id;
  String name;
  String description;
  List<String> images;
  num afterDiscountPrice;
  Profile profile;
  Category category;

  RecommendedProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.afterDiscountPrice,
    required this.profile,
    required this.category,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      id: json["_id"],
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      images: json["images"] == null ? [] : List<String>.from(json["images"]),
      afterDiscountPrice: json["afterDiscountPrice"] ?? 0,
      profile: Profile.fromJson(json["profileId"]),
      category: Category.fromJson(json["categoryId"]),
    );
  }
}

class Profile {
  String id;
  String name;
  String image;

  Profile({required this.id, required this.name, required this.image});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json["_id"],
      name: json["name"] ?? "",
      image: json["image"] ?? "",
    );
  }
}

class Category {
  String id;
  String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["_id"],
      name: json["name"] ?? "",
    );
  }
}
