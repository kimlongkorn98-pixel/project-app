import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewCount;
  final String description;
  final String imageUrl;
  final List<Color> colors;
  final List<String> sizes;
  final bool isPopular;
  final bool isFlashSale;
  final int discountPercentage;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.imageUrl,
    required this.colors,
    required this.sizes,
    this.isPopular = false,
    this.isFlashSale = false,
    this.discountPercentage = 0,
    this.stock = 50,
  });
}

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class CartItem {
  final Product product;
  Color selectedColor;
  String selectedSize;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

enum OrderStatus { placed, processing, shipped, delivered }

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double total;
  final DateTime date;
  final String shippingAddress;
  final String paymentMethod;
  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.total,
    required this.date,
    required this.shippingAddress,
    required this.paymentMethod,
    this.status = OrderStatus.processing,
  });
}
