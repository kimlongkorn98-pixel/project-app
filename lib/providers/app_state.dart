import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/mock_data.dart';
import '../l10n/app_strings.dart';

class AppState extends ChangeNotifier {
  final Map<String, ({String name, String password})> _users = {
    'alex.morgan@example.com': (name: 'Alex Morgan', password: 'Shop1234'),
  };
  bool _isAuthenticated = false;
  String? _currentUserEmail;
  String? _currentUserName;
  bool _isDarkMode = false;
  String _languageCode = 'en';
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  String _storeName = 'My Store';
  String? _storeOwnerName;
  String? _storeImageData;

  final List<CartItem> _cartItems = [];
  final Set<String> _wishlistIds = {'p1', 'p4'};
  final List<OrderModel> _orders = [];
  final List<Product> _sellerProducts = [];

  String? _appliedPromoCode;
  double _promoDiscountPercent = 0.0;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String get currentUserName => _currentUserName ?? 'Guest';
  String get currentUserEmail => _currentUserEmail ?? '';
  String get currentUserFirstName => currentUserName.split(' ').first;
  bool get isDarkMode => _isDarkMode;
  String get languageCode => _languageCode;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  String get storeName => _storeName;
  String get storeOwnerName => _storeOwnerName ?? currentUserName;
  String? get storeImageData => _storeImageData;
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);
  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<Product> get sellerProducts => List.unmodifiable(_sellerProducts);
  List<Product> get catalogProducts => [
    ..._sellerProducts,
    ...MockData.products,
  ];
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
    return catalogProducts.where((product) {
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
    return catalogProducts
        .where((product) => _wishlistIds.contains(product.id))
        .toList();
  }

  // Actions
  String? login({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();
    final user = _users[normalizedEmail];
    if (user == null || user.password != password) {
      return 'Incorrect email or password.';
    }

    _currentUserEmail = normalizedEmail;
    _currentUserName = user.name;
    _isAuthenticated = true;
    notifyListeners();
    return null;
  }

  String? register({
    required String name,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.containsKey(normalizedEmail)) {
      return 'An account with this email already exists.';
    }

    final cleanName = name.trim();
    _users[normalizedEmail] = (name: cleanName, password: password);
    _currentUserEmail = normalizedEmail;
    _currentUserName = cleanName;
    _isAuthenticated = true;
    notifyListeners();
    return null;
  }

  void signOut() {
    _isAuthenticated = false;
    _currentUserEmail = null;
    _currentUserName = null;
    _searchQuery = '';
    _selectedCategoryId = 'all';
    notifyListeners();
  }

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

  void updateStoreProfile({
    required String storeName,
    required String ownerName,
    required String? imageData,
  }) {
    _storeName = storeName.trim();
    _storeOwnerName = ownerName.trim();
    _storeImageData = imageData;
    notifyListeners();
  }

  void addSellerProduct({
    required String name,
    required String category,
    required double price,
    required int stock,
    required String description,
    required String currencySymbol,
    required Map<String, double> variantPrices,
    required Map<String, int> variantStocks,
    String? imageUrl,
  }) {
    final product = Product(
      id: 'seller-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      category: category,
      price: price,
      originalPrice: price,
      rating: 0,
      reviewCount: 0,
      description: description.trim(),
      imageUrl: imageUrl?.trim().isNotEmpty == true
          ? imageUrl!.trim()
          : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=800&auto=format&fit=crop',
      colors: const [Colors.black],
      sizes: category == 'food'
          ? const ['300ml', '500ml', '1500ml']
          : const ['Standard'],
      stock: stock,
      currencySymbol: currencySymbol,
      variantPrices: variantPrices,
      variantStocks: variantStocks,
    );
    _sellerProducts.insert(0, product);
    notifyListeners();
  }

  void removeSellerProduct(String productId) {
    _sellerProducts.removeWhere((product) => product.id == productId);
    _wishlistIds.remove(productId);
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateSellerProduct({
    required String productId,
    required String name,
    required String category,
    required double price,
    required int stock,
    required String description,
    required String currencySymbol,
    required Map<String, double> variantPrices,
    required Map<String, int> variantStocks,
    String? imageUrl,
  }) {
    final index = _sellerProducts.indexWhere(
      (product) => product.id == productId,
    );
    if (index < 0) return;

    final existing = _sellerProducts[index];
    _sellerProducts[index] = Product(
      id: existing.id,
      name: name.trim(),
      category: category,
      price: price,
      originalPrice: price,
      rating: existing.rating,
      reviewCount: existing.reviewCount,
      description: description.trim(),
      imageUrl: imageUrl?.trim().isNotEmpty == true
          ? imageUrl!.trim()
          : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=800&auto=format&fit=crop',
      colors: existing.colors,
      sizes:
          category == 'food' &&
              existing.sizes.length == 1 &&
              existing.sizes.first == 'Standard'
          ? const ['300ml', '500ml', '1500ml']
          : existing.sizes,
      stock: stock,
      currencySymbol: currencySymbol,
      variantPrices: variantPrices,
      variantStocks: variantStocks,
    );
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
