// models/recommendationModel/recommended_product_model.dart

class RecommendedProductModel {
  bool success;
  List<RecommendedProduct> products;

  RecommendedProductModel({required this.success, required this.products});

  factory RecommendedProductModel.fromJson(Map<String, dynamic> json) {
    final raw = json["products"];
    final List<RecommendedProduct> parsed = [];
    if (raw is List) {
      for (final x in raw) {
        try {
          parsed.add(RecommendedProduct.fromJson(x as Map<String, dynamic>));
        } catch (_) {}
      }
    }
    return RecommendedProductModel(success: true, products: parsed);
  }
}

class RecommendedProduct {
  String id;
  String name;
  String description;
  List<String> images;
  num afterDiscountPrice;
  int? quantity;

  // ✅ ADDED
  double averageRating;

  Profile profile;
  Category category;

  RecommendedProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.afterDiscountPrice,
    this.quantity,
    required this.averageRating, // ✅
    required this.profile,
    required this.category,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      images: json["images"] == null ? [] : List<String>.from(json["images"]),
      afterDiscountPrice: json["afterDiscountPrice"] ?? 0,
      quantity: json["quantity"],

      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : 0.0,

      profile: json["profileId"] is Map
          ? Profile.fromJson(json["profileId"] as Map<String, dynamic>)
          : Profile(
              id: json["profileId"]?.toString() ?? "",
              name: "",
              image: "",
            ),
      category: json["categoryId"] is Map
          ? Category.fromJson(json["categoryId"] as Map<String, dynamic>)
          : Category(id: json["categoryId"]?.toString() ?? "", name: ""),
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
      id: json["_id"]?.toString() ?? "",
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
      id: json["_id"]?.toString() ?? "",
      name: json["name"] ?? "",
    );
  }
}
