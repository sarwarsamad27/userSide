class PopularCategoryModel {
  bool? success;
  int? page;
  int? limit;
  int? totalCategories;
  int? totalPages;
  List<Categories>? categories;

  PopularCategoryModel({
    this.success,
    this.page,
    this.limit,
    this.totalCategories,
    this.totalPages,
    this.categories,
  });

  PopularCategoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    page = json['page'];
    limit = json['limit'];
    totalCategories = json['totalCategories'];
    totalPages = json['totalPages'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['page'] = page;
    data['limit'] = limit;
    data['totalCategories'] = totalCategories;
    data['totalPages'] = totalPages;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  String? categoryId;
  String? profileId;
  String? categoryName;
  String? categoryImage;
  int? totalProducts;
  double? averageDiscountPercentage;

  Categories({
    this.categoryId,
    this.profileId,
    this.categoryName,
    this.categoryImage,
    this.totalProducts,
    this.averageDiscountPercentage,
  });

  Categories.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    profileId = json['profileId'];
    categoryName = json['categoryName'];
    categoryImage = json['categoryImage'];
    totalProducts = json['totalProducts'];
    // ✅ Convert int to double if necessary
    averageDiscountPercentage = json['averageDiscountPercentage'] != null
        ? (json['averageDiscountPercentage'] as num).toDouble()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryId'] = categoryId;
    data['profileId'] = profileId;
    data['categoryName'] = categoryName;
    data['categoryImage'] = categoryImage;
    data['totalProducts'] = totalProducts;
    data['averageDiscountPercentage'] = averageDiscountPercentage;
    return data;
  }
}
