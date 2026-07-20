import 'package:flutter/material.dart';
import '../models/product.dart';

class MockData {
  static final List<CategoryItem> categories = [
    CategoryItem(
      id: 'all',
      name: 'All',
      icon: Icons.grid_view_rounded,
      color: const Color(0xFF6C5CE7),
    ),
    CategoryItem(
      id: 'fashion',
      name: 'Fashion',
      icon: Icons.checkroom_rounded,
      color: const Color(0xFFFF7675),
    ),
    CategoryItem(
      id: 'electronics',
      name: 'Tech & Gadgets',
      icon: Icons.devices_rounded,
      color: const Color(0xFF0984E3),
    ),
    CategoryItem(
      id: 'shoes',
      name: 'Footwear',
      icon: Icons.roller_skating_rounded,
      color: const Color(0xFF00CEC9),
    ),
    CategoryItem(
      id: 'beauty',
      name: 'Beauty & Skincare',
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFFE84393),
    ),
    CategoryItem(
      id: 'home',
      name: 'Home & Living',
      icon: Icons.chair_rounded,
      color: const Color(0xFFFDCB6E),
    ),
  ];

  static final List<Product> products = [
    Product(
      id: 'p1',
      name: 'Sony WH-1000XM5 Wireless Headphones',
      category: 'electronics',
      price: 349.99,
      originalPrice: 399.99,
      rating: 4.8,
      reviewCount: 1240,
      description:
          'Industry-leading noise canceling headphones with two processors and 8 microphones for unprecedented noise cancellation and exceptional call quality.',
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=800&auto=format&fit=crop',
      colors: [Colors.black, Colors.grey.shade300, const Color(0xFFD4AF37)],
      sizes: ['Standard'],
      isPopular: true,
      isFlashSale: true,
      discountPercentage: 12,
      stock: 25,
    ),
    Product(
      id: 'p2',
      name: 'Nike Air Max Pulse Urban Sneakers',
      category: 'shoes',
      price: 159.00,
      originalPrice: 189.00,
      rating: 4.7,
      reviewCount: 850,
      description:
          'Mixes urban street style with supreme comfort. Point-loaded cushioning system gives you a springy response for all-day energy.',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=800&auto=format&fit=crop',
      colors: [Colors.red, Colors.white, Colors.black],
      sizes: ['US 7', 'US 8', 'US 9', 'US 10', 'US 11'],
      isPopular: true,
      isFlashSale: true,
      discountPercentage: 15,
      stock: 40,
    ),
    Product(
      id: 'p3',
      name: 'Minimalist Minimal Desk Lamp Studio',
      category: 'home',
      price: 79.50,
      originalPrice: 99.00,
      rating: 4.6,
      reviewCount: 310,
      description:
          'Sleek matte finish architectural lamp with customizable color temperature, stepless brightness dimming, and built-in wireless fast charging pad.',
      imageUrl:
          'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?q=80&w=800&auto=format&fit=crop',
      colors: [Colors.white, Colors.black, const Color(0xFF8D6E63)],
      sizes: ['Medium', 'Large'],
      isPopular: false,
      isFlashSale: false,
      discountPercentage: 20,
      stock: 15,
    ),
    Product(
      id: 'p4',
      name: 'Luxury Chronograph Leather Watch',
      category: 'fashion',
      price: 220.00,
      originalPrice: 280.00,
      rating: 4.9,
      reviewCount: 520,
      description:
          'Precision sapphire crystal face, genuine Italian calfskin leather strap, 50m water resistance, and classic luminous dial markers.',
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=800&auto=format&fit=crop',
      colors: [Colors.brown, Colors.black, const Color(0xFFC0C0C0)],
      sizes: ['40mm', '42mm'],
      isPopular: true,
      isFlashSale: true,
      discountPercentage: 21,
      stock: 12,
    ),
    Product(
      id: 'p5',
      name: 'Apple iPad Pro 12.9" M2 Chip',
      category: 'electronics',
      price: 1099.00,
      originalPrice: 1199.00,
      rating: 4.9,
      reviewCount: 2100,
      description:
          'Astonishing performance with Liquid Retina XDR display, pro camera setup, Wi-Fi 6E connectivity, and Apple Pencil hover experience.',
      imageUrl:
          'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?q=80&w=800&auto=format&fit=crop',
      colors: [Colors.grey.shade400, Colors.grey.shade900],
      sizes: ['128GB', '256GB', '512GB'],
      isPopular: true,
      isFlashSale: false,
      discountPercentage: 8,
      stock: 30,
    ),
    Product(
      id: 'p6',
      name: 'Organic Glow Hydration Face Serum',
      category: 'beauty',
      price: 45.00,
      originalPrice: 60.00,
      rating: 4.7,
      reviewCount: 640,
      description:
          'Infused with Hyaluronic Acid and Botanical extracts for intense moisture retention, skin elasticity, and radiant natural radiance.',
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&w=800&auto=format&fit=crop',
      colors: [const Color(0xFFFCE4EC), const Color(0xFFFFF3E0)],
      sizes: ['30ml', '50ml'],
      isPopular: false,
      isFlashSale: true,
      discountPercentage: 25,
      stock: 60,
    ),
    Product(
      id: 'p7',
      name: 'Premium Leather Travel Weekender Bag',
      category: 'fashion',
      price: 185.00,
      originalPrice: 230.00,
      rating: 4.8,
      reviewCount: 420,
      description:
          'Handcrafted top-grain leather travel duffel bag featuring shoe compartment, padded laptop pocket, and heavy-duty brass YKK hardware.',
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=800&auto=format&fit=crop',
      colors: [const Color(0xFF5D4037), Colors.black, const Color(0xFF795548)],
      sizes: ['35L', '45L'],
      isPopular: true,
      isFlashSale: false,
      discountPercentage: 19,
      stock: 18,
    ),
    Product(
      id: 'p8',
      name: 'Smart Ergonomic Mesh Office Chair',
      category: 'home',
      price: 299.00,
      originalPrice: 349.00,
      rating: 4.6,
      reviewCount: 290,
      description:
          'Breathable 3D mesh posture support chair with adjustable 4D armrests, dynamic lumbar pillow, and 135-degree recline mechanism.',
      imageUrl:
          'https://images.unsplash.com/photo-1580481072645-022f9a6d83d0?q=80&w=800&auto=format&fit=crop',
      colors: [Colors.black, Colors.grey],
      sizes: ['Standard'],
      isPopular: false,
      isFlashSale: true,
      discountPercentage: 14,
      stock: 10,
    ),
  ];

  static final List<Map<String, String>> promoBanners = [
    {
      'title': 'SUMMER FLASH SALE',
      'subtitle': 'Up to 50% OFF Top Tech & Fashion',
      'code': 'SUMMER50',
      'color': '0xFF6C5CE7',
      'image': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=800&auto=format&fit=crop',
    },
    {
      'title': 'NEW ARRIVALS 2026',
      'subtitle': 'Discover the Latest Audio Tech & Smart Wearables',
      'code': 'NEWARRIVAL',
      'color': '0xFF00CEC9',
      'image': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=800&auto=format&fit=crop',
    },
    {
      'title': 'FREE EXPRESS SHIPPING',
      'subtitle': 'On all orders over \$99 with code FREESHIP',
      'code': 'FREESHIP',
      'color': '0xFFFF7675',
      'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=800&auto=format&fit=crop',
    },
  ];
}
