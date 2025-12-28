import 'package:flutter/foundation.dart';

class ProductDetailUiProvider extends ChangeNotifier {
  ProductDetailUiProvider({List<String>? initialImages}) {
    _images = initialImages ?? <String>[];
  }

  final List<String> selectedColors = <String>[];
  final List<String> selectedSizes = <String>[];

  int _currentImageIndex = 0;
  List<String> _images = <String>[];

  int get currentImageIndex => _currentImageIndex;

  String get currentImage {
    if (_images.isEmpty) return '';
    if (_currentImageIndex < 0 || _currentImageIndex >= _images.length) {
      return _images.first;
    }
    return _images[_currentImageIndex];
  }

  void setImages(List<String> images) {
    _images = images;
    if (_images.isEmpty) {
      _currentImageIndex = 0;
    } else if (_currentImageIndex >= _images.length) {
      _currentImageIndex = 0;
    }
    notifyListeners();
  }

  void onImageChange(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  void toggleColor(String color) {
    if (selectedColors.contains(color)) {
      selectedColors.remove(color);
    } else {
      selectedColors.add(color);
    }
    notifyListeners();
  }

  void toggleSize(String size) {
    if (selectedSizes.contains(size)) {
      selectedSizes.remove(size);
    } else {
      selectedSizes.add(size);
    }
    notifyListeners();
  }
}
