class PopularCategoryModel {
  bool? success;
  int? page;
  int? limit;
  int? totalCategories;
  int? totalPages;
  List<Categories>? categories;

  PopularCategoryModel(
      {this.success,
      this.page,
      this.limit,
      this.totalCategories,
      this.totalPages,
      this.categories});

  PopularCategoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    page = json['page'];
    limit = json['limit'];
    totalCategories = json['totalCategories'];
    totalPages = json['totalPages'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(new Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['totalCategories'] = this.totalCategories;
    data['totalPages'] = this.totalPages;
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
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
  int? averageDiscountPercentage;

  Categories(
      {this.categoryId,
      this.profileId,
      this.categoryName,
      this.categoryImage,
      this.totalProducts,
      this.averageDiscountPercentage});

  Categories.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    profileId = json['profileId'];
    categoryName = json['categoryName'];
    categoryImage = json['categoryImage'];
    totalProducts = json['totalProducts'];
    averageDiscountPercentage = json['averageDiscountPercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryId'] = this.categoryId;
    data['profileId'] = this.profileId;
    data['categoryName'] = this.categoryName;
    data['categoryImage'] = this.categoryImage;
    data['totalProducts'] = this.totalProducts;
    data['averageDiscountPercentage'] = this.averageDiscountPercentage;
    return data;
  }
}
