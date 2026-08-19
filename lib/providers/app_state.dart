import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/mock_data.dart';
import '../l10n/app_strings.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  String _languageCode = 'en';
  String _selectedCategoryId = 'all';
  String _searchQuery = '';

  final List<CartItem> _cartItems = [];
  final Set<String> _wishlistIds = {'p1', 'p4'};
  final List<OrderModel> _orders = [];

  String? _appliedPromoCode;
  double _promoDiscountPercent = 0.0;

  // Initial dummy cart item
  AppState() {
    if (MockData.products.isNotEmpty) {
      final p1 = MockData.products.first;
      _cartItems.add(
        CartItem(
          product: p1,
          selectedColor: p1.colors.first,
          selectedSize: p1.sizes.first,
          quantity: 1,
        ),
      );
    }
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  String get languageCode => _languageCode;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);
  List<OrderModel> get orders => List.unmodifiable(_orders);
  String? get appliedPromoCode => _appliedPromoCode;

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => subtotal * _promoDiscountPercent;

  double get shippingFee =>
      subtotal > 99.0 || _appliedPromoCode == 'FREESHIP' || subtotal == 0
      ? 0.0
      : 15.0;

  double get grandTotal =>
      (subtotal - discountAmount + shippingFee).clamp(0.0, double.infinity);

  List<Product> get filteredProducts {
    return MockData.products.where((product) {
      final matchesCategory =
          _selectedCategoryId == 'all' ||
          product.category == _selectedCategoryId;
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Product> get wishlistProducts {
    return MockData.products
        .where((product) => _wishlistIds.contains(product.id))
        .toList();
  }

  // Actions
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    _languageCode = languageCode;
    notifyListeners();
  }

  String text(String key) => AppStrings.text(_languageCode, key);

  void setCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> refreshCatalog() async {
    // This app currently uses local mock data. Keep the same refresh flow that
    // a network-backed catalog would use, so the UI is ready for real data.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    notifyListeners();
  }

  void addToCart(
    Product product, {
    Color? color,
    String? size,
    int quantity = 1,
  }) {
    final selectedColor =
        color ??
        (product.colors.isNotEmpty ? product.colors.first : Colors.black);
    final selectedSize =
        size ?? (product.sizes.isNotEmpty ? product.sizes.first : 'Standard');

    final existingIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor == selectedColor &&
          item.selectedSize == selectedSize,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(
        CartItem(
          product: product,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  int cartQuantityForProduct(String productId) {
    return _cartItems
        .where((item) => item.product.id == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  void removeOneFromCart(Product product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index == -1) return;

    final item = _cartItems[index];
    updateQuantity(item, item.quantity - 1);
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      removeFromCart(item);
    } else {
      item.quantity = quantity;
      notifyListeners();
    }
  }

  void removeFromCart(CartItem item) {
    _cartItems.removeWhere(
      (i) =>
          i.product.id == item.product.id &&
          i.selectedColor == item.selectedColor &&
          i.selectedSize == item.selectedSize,
    );
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _appliedPromoCode = null;
    _promoDiscountPercent = 0.0;
    notifyListeners();
  }

  void toggleWishlist(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }

  bool isWishlisted(String productId) => _wishlistIds.contains(productId);

  bool applyPromoCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'SUMMER50' || cleanCode == 'DISCOUNT50') {
      _appliedPromoCode = cleanCode;
      _promoDiscountPercent = 0.50;
      notifyListeners();
      return true;
    } else if (cleanCode == 'WELCOME20' || cleanCode == 'DISCOUNT20') {
      _appliedPromoCode = cleanCode;
      _promoDiscountPercent = 0.20;
      notifyListeners();
      return true;
    } else if (cleanCode == 'FREESHIP') {
      _appliedPromoCode = cleanCode;
      _promoDiscountPercent = 0.0;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _promoDiscountPercent = 0.0;
    notifyListeners();
  }

  OrderModel? placeOrder({
    required String address,
    required String paymentMethod,
  }) {
    if (_cartItems.isEmpty) return null;

    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      items: List.from(_cartItems),
      subtotal: subtotal,
      discount: discountAmount,
      shippingFee: shippingFee,
      total: grandTotal,
      date: DateTime.now(),
      shippingAddress: address,
      paymentMethod: paymentMethod,
      status: OrderStatus.placed,
    );

    _orders.insert(0, newOrder);
    clearCart();
    notifyListeners();
    return newOrder;
  }
}
