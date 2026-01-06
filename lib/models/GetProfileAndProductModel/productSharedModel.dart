class ProductShareModel {
  final String shareUrl;

  ProductShareModel({required this.shareUrl});

  factory ProductShareModel.fromJson(Map<String, dynamic> json) {
    return ProductShareModel(
      shareUrl: json['shareUrl'] ?? '',
    );
  }
}
