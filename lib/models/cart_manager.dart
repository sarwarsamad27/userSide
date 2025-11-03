import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final String imageUrl;
  final String price;
  final String color;
  final String size;
  int quantity;

  CartItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.color,
    required this.size,
    this.quantity = 1,
  });
}

class CartManager {
  static final List<CartItem> _cartItems = [];

  static List<CartItem> get items => _cartItems;

  static void addToCart(CartItem newItem) {
    final existing = _cartItems.indexWhere((item) =>
        item.name == newItem.name &&
        item.color == newItem.color &&
        item.size == newItem.size);

    if (existing == -1) {
      _cartItems.add(newItem);
    }
  }

  static void increaseQuantity(CartItem item) {
    item.quantity++;
  }

  static void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) item.quantity--;
  }

  static void removeFromCart(CartItem item) {
    _cartItems.remove(item);
  }
}
