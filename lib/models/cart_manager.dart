class CartItem {
  final String name;
  final String imageUrl;
  final String price;
  final List<String> colors;  
  final List<String> sizes;  
  int quantity;

  CartItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.colors,
    required this.sizes,
    this.quantity = 1,
  });
}

class CartManager {
  static final List<CartItem> _cartItems = [];

  static List<CartItem> get items => _cartItems;

  static void addToCart(CartItem newItem) {
    final existing = _cartItems.indexWhere((item) =>
        item.name == newItem.name &&
        item.colors == newItem.colors &&
        item.sizes == newItem.sizes);

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
