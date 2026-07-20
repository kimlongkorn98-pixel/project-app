import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/app_state.dart';
import '../screens/product_detail_screen.dart';
import 'product_card.dart';

class AutoHorizontalProductList extends StatefulWidget {
  final List<Product> products;
  final AppState state;
  final double cardWidth;
  final double cardSpacing;
  final double height;
  final double pixelsPerSecond;

  const AutoHorizontalProductList({
    super.key,
    required this.products,
    required this.state,
    this.cardWidth = 170.0,
    this.cardSpacing = 14.0,
    this.height = 250.0,
    this.pixelsPerSecond = 35.0, // Smooth continuous scanning speed
  });

  @override
  State<AutoHorizontalProductList> createState() =>
      _AutoHorizontalProductListState();
}

class _AutoHorizontalProductListState
    extends State<AutoHorizontalProductList> {
  late final ScrollController _scrollController;
  Timer? _timer;
  bool _isUserInteracting = false;
  static const int _infiniteItemCount = 10000;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && widget.products.isNotEmpty) {
        final count = widget.products.length;
        final middle = _infiniteItemCount ~/ 2;
        final initialIndex = middle - (middle % count);
        final double step = widget.cardWidth + widget.cardSpacing;
        _scrollController.jumpTo(20.0 + (initialIndex * step));
      }
      _startContinuousScroll();
    });
  }

  void _startContinuousScroll() {
    _timer?.cancel();
    // 60fps tick for ultra-smooth continuous scanning movement
    const tickDuration = Duration(milliseconds: 16);
    final double stepPerTick =
        widget.pixelsPerSecond * (tickDuration.inMilliseconds / 1000.0);

    _timer = Timer.periodic(tickDuration, (timer) {
      if (_isUserInteracting ||
          !_scrollController.hasClients ||
          widget.products.isEmpty) {
        return;
      }
      final double currentOffset = _scrollController.offset;
      _scrollController.jumpTo(currentOffset + stepPerTick);
    });
  }

  void _onUserInteractionStart() {
    _isUserInteracting = true;
    _timer?.cancel();
  }

  void _onUserInteractionEnd() {
    _isUserInteracting = false;
    _startContinuousScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollManual(bool isNext) {
    if (!_scrollController.hasClients) return;
    _onUserInteractionStart();
    final step = widget.cardWidth + widget.cardSpacing;
    final target = isNext
        ? _scrollController.offset + step
        : _scrollController.offset - step;

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isUserInteracting) {
        _onUserInteractionEnd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _onUserInteractionStart();
                  } else if (notification is ScrollEndNotification) {
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted && !_isUserInteracting) {
                        _onUserInteractionEnd();
                      }
                    });
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _infiniteItemCount,
                  itemBuilder: (context, index) {
                    final realIndex = index % widget.products.length;
                    final product = widget.products[realIndex];

                    return Padding(
                      padding: EdgeInsets.only(right: widget.cardSpacing),
                      child: SizedBox(
                        width: widget.cardWidth,
                        child: ProductCard(
                          product: product,
                          isWishlisted: widget.state.isWishlisted(product.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  product: product,
                                  state: widget.state,
                                ),
                              ),
                            );
                          },
                          onFavoriteTap: () =>
                              widget.state.toggleWishlist(product.id),
                          onAddToCartTap: () {
                            widget.state.addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${product.name} to cart!'),
                                backgroundColor: const Color(0xFF6C5CE7),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Left & Right Quick Arrow Navigation Overlays
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _scrollManual(false),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _scrollManual(true),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
