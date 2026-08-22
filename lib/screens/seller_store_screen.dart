import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';

import '../data/mock_data.dart';
import '../models/product.dart';
import '../providers/app_state.dart';

class SellerStoreScreen extends StatelessWidget {
  final AppState state;

  const SellerStoreScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seller Center',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: state,
        builder: (context, _) => state.sellerProducts.isEmpty
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed: () => _openProductForm(context),
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add product'),
              ),
      ),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final currentProducts = state.sellerProducts;
          final currentValue = currentProducts.fold<double>(
            0,
            (total, product) => total + (product.price * product.stock),
          );
          final currencies = currentProducts
              .map((product) => product.currencySymbol)
              .toSet();
          final inventoryValueLabel = currentProducts.isEmpty
              ? '\$0.00'
              : currencies.length == 1
              ? currentProducts.first.formatPrice(currentValue)
              : 'Mixed currencies';
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              _StoreSummary(
                storeName: state.storeName,
                ownerName: state.storeOwnerName,
                storeImageData: state.storeImageData,
                listingCount: currentProducts.length,
                inventoryValue: inventoryValueLabel,
                onEditProfile: () => _editStoreProfile(context),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Product listings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentProducts.length} listed',
                      style: const TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (currentProducts.isEmpty) ...[
                _EmptyStore(onAdd: () => _openProductForm(context)),
                const SizedBox(height: 18),
                const _SellingGuide(),
              ] else
                ...currentProducts.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProductListing(
                      product: product,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerProductDetailScreen(
                            productId: product.id,
                            state: state,
                          ),
                        ),
                      ),
                      onEdit: () => _openProductForm(context, product: product),
                      onDelete: () => _confirmDelete(context, product),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openProductForm(
    BuildContext context, {
    Product? product,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AddProductScreen(state: state, product: product),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove listing?'),
        content: Text('${product.name} will no longer appear in the store.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7675),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) state.removeSellerProduct(product.id);
  }

  Future<void> _editStoreProfile(BuildContext context) async {
    final storeNameController = TextEditingController(text: state.storeName);
    final ownerNameController = TextEditingController(
      text: state.storeOwnerName,
    );
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Store profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'This information identifies your store and its owner.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: storeNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Store name',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  validator: _requiredProfileField,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: ownerNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Owner name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: _requiredProfileField,
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(sheetContext, true);
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save profile'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true) {
      state.updateStoreProfile(
        storeName: storeNameController.text,
        ownerName: ownerNameController.text,
        imageData: state.storeImageData,
      );
    }
    storeNameController.dispose();
    ownerNameController.dispose();
  }

  static String? _requiredProfileField(String? value) {
    return value == null || value.trim().isEmpty
        ? 'This field is required'
        : null;
  }
}

class SellerProductDetailScreen extends StatelessWidget {
  final AppState state;
  final String productId;

  const SellerProductDetailScreen({
    super.key,
    required this.state,
    required this.productId,
  });

  Product? get _product {
    for (final product in state.sellerProducts) {
      if (product.id == productId) return product;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final product = _product;
        if (product == null) {
          return const Scaffold(body: SizedBox.shrink());
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Listing details',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit listing',
                onPressed: () => _edit(context, product),
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF6C5CE7)),
              ),
              IconButton(
                tooltip: 'Delete listing',
                onPressed: () => _delete(context, product),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFFF7675),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: FilledButton.icon(
              onPressed: () => _edit(context, product),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit listing'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: Image(
                    image: product.imageProvider,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0x1A6C5CE7),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 7, color: Color(0xFF00B894)),
                        SizedBox(width: 6),
                        Text(
                          'Active listing',
                          style: TextStyle(
                            color: Color(0xFF008F72),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                product.formattedPrice,
                style: const TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _OwnerMetric(
                        icon: Icons.inventory_2_outlined,
                        label: 'In stock',
                        value: '${product.stock}',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 42,
                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    ),
                    Expanded(
                      child: _OwnerMetric(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Inventory value',
                        value: product.formatPrice(
                          product.price * product.stock,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  height: 1.55,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _edit(BuildContext context, Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AddProductScreen(state: state, product: product),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('${product.name} will be removed from your store.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7675),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      state.removeSellerProduct(product.id);
      Navigator.pop(context);
    }
  }
}

class _OwnerMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OwnerMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6C5CE7), size: 22),
        const SizedBox(height: 7),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}

class _StoreSummary extends StatelessWidget {
  final String storeName;
  final String ownerName;
  final String? storeImageData;
  final int listingCount;
  final String inventoryValue;
  final VoidCallback onEditProfile;

  const _StoreSummary({
    required this.storeName,
    required this.ownerName,
    required this.storeImageData,
    required this.listingCount,
    required this.inventoryValue,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                clipBehavior: Clip.antiAlias,
                child: storeImageData == null
                    ? const Icon(Icons.storefront_rounded, color: Colors.white)
                    : Image.memory(
                        base64Decode(storeImageData!.split(',').last),
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Owner: $ownerName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: Color(0xFF55EFC4)),
                    SizedBox(width: 6),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Edit store profile',
                onPressed: onEditProfile,
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  minimumSize: const Size(36, 36),
                  padding: const EdgeInsets.all(8),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _metric('Active listings', '$listingCount')),
              Container(width: 1, height: 36, color: Colors.white24),
              Expanded(child: _metric('Inventory value', inventoryValue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _EmptyStore extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyStore({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Color(0xFF6C5CE7),
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Start selling',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first product and make it available to shoppers in just a few steps.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create first listing'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellingGuide extends StatelessWidget {
  const _SellingGuide();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How selling works',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 18),
          _GuideStep(
            number: '1',
            title: 'Add product details',
            subtitle: 'Name, price, stock, and a clear photo',
          ),
          SizedBox(height: 16),
          _GuideStep(
            number: '2',
            title: 'Publish your listing',
            subtitle: 'Your product appears in the shopper catalog',
          ),
          SizedBox(height: 16),
          _GuideStep(
            number: '3',
            title: 'Start selling',
            subtitle: 'Manage inventory from your Seller Center',
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _GuideStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0x1A6C5CE7),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF6C5CE7),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductListing extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductListing({
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image(
                  image: product.imageProvider,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 76,
                    height: 76,
                    color: const Color(0x1F6C5CE7),
                    child: const Icon(Icons.image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${product.stock} in stock',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit product',
                    onPressed: onEdit,
                    color: const Color(0xFF6C5CE7),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Remove product',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddProductScreen extends StatefulWidget {
  final AppState state;
  final Product? product;

  const _AddProductScreen({required this.state, this.product});

  @override
  State<_AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<_AddProductScreen> {
  static const _volumeSizes = ['300ml', '500ml', '1500ml'];
  static const _khrVolumeExamples = {
    '300ml': '500',
    '500ml': '1000',
    '1500ml': '2000',
  };
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _storeNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final Map<String, TextEditingController> _volumePriceControllers;
  late final Map<String, TextEditingController> _volumeStockControllers;
  final _imagePicker = ImagePicker();
  late String _category;
  late String _currencySymbol;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  Uint8List? _storeImageBytes;
  bool _imageRemoved = false;
  bool _storeImageRemoved = false;
  bool _isPickingImage = false;
  bool _isPickingStoreImage = false;
  bool _isPastingImage = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _storeNameController = TextEditingController(text: widget.state.storeName);
    _ownerNameController = TextEditingController(
      text: widget.state.storeOwnerName,
    );
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _stockController = TextEditingController(
      text: product == null ? '' : product.stock.toString(),
    );
    _volumePriceControllers = {
      for (final size in _volumeSizes)
        size: TextEditingController(
          text:
              product?.variantPrices[size]?.toString() ??
              (product?.category == 'food' &&
                      product?.currencySymbol == '\u17DB'
                  ? _khrVolumeExamples[size]!
                  : size == '300ml' && product?.category == 'food'
                  ? product!.price.toString()
                  : ''),
        ),
    };
    _volumeStockControllers = {
      for (final size in _volumeSizes)
        size: TextEditingController(
          text:
              product?.variantStocks[size]?.toString() ??
              (product?.category == 'food' && size == '300ml'
                  ? product!.stock.toString()
                  : '0'),
        ),
    };
    _category = product?.category ?? 'fashion';
    _currencySymbol = product?.currencySymbol ?? '\$';
    final storeImageData = widget.state.storeImageData;
    if (storeImageData != null && storeImageData.startsWith('data:image/')) {
      _storeImageBytes = base64Decode(storeImageData.split(',').last);
    }
    final imageUrl = product?.imageUrl;
    if (imageUrl != null && imageUrl.startsWith('data:image/')) {
      _selectedImageBytes = base64Decode(imageUrl.split(',').last);
      _selectedImageName = 'Current product photo';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    for (final controller in _volumePriceControllers.values) {
      controller.dispose();
    }
    for (final controller in _volumeStockControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit product' : 'New product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          children: [
            const Text(
              'Seller information',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tell shoppers who owns and operates this store.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _storeNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Store name',
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
              validator: _required,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _ownerNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Store owner name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: _required,
            ),
            const SizedBox(height: 14),
            _buildStoreImagePicker(context),
            const SizedBox(height: 28),
            const Text(
              'Product details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add the information shoppers need to buy your product.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Product name',
                prefixIcon: Icon(Icons.sell_outlined),
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: MockData.categories
                  .where((category) => category.id != 'all')
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 20, color: category.color),
                          const SizedBox(width: 10),
                          Text(category.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _category = value;
                  if (value == 'food' &&
                      _volumePriceControllers['300ml']!.text.isEmpty &&
                      _priceController.text.isNotEmpty) {
                    _volumePriceControllers['300ml']!.text =
                        _priceController.text;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Currency',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF6C5CE7);
                    }
                    return isDark ? const Color(0xFF1E293B) : Colors.white;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF475569);
                  }),
                  iconColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return const Color(0xFF6C5CE7);
                  }),
                  side: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);
                    return BorderSide(
                      color: selected
                          ? const Color(0xFF6C5CE7)
                          : isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFD8DEE9),
                      width: selected ? 1.5 : 1,
                    );
                  }),
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(fontWeight: FontWeight.w700),
                  ),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: '\$',
                    label: Text('\$  USD'),
                    icon: Icon(Icons.attach_money_rounded),
                  ),
                  ButtonSegment(
                    value: '៛',
                    label: Text('៛  KHR'),
                    icon: Icon(Icons.currency_exchange_rounded),
                  ),
                ],
                selected: {_currencySymbol},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  setState(() {
                    _currencySymbol = selection.first;
                    if (_category == 'food' && _currencySymbol == '៛') {
                      final replaceLegacyPrices =
                          widget.product?.variantPrices.isEmpty ?? true;
                      for (final entry in _khrVolumeExamples.entries) {
                        if (replaceLegacyPrices ||
                            _volumePriceControllers[entry.key]!.text.isEmpty) {
                          _volumePriceControllers[entry.key]!.text =
                              entry.value;
                        }
                      }
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_category == 'food') ...[
              const Text(
                'Volume inventory',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              const Text(
                'Set the selling price and available stock for each size.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ..._volumeSizes.map(
                (size) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_drink_outlined,
                              size: 20,
                              color: Color(0xFF6C5CE7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              size,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _volumePriceControllers[size],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: 'Price',
                                  prefixText: '$_currencySymbol ',
                                ),
                                validator: _validPrice,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _volumeStockControllers[size],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Stock',
                                  prefixIcon: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 20,
                                  ),
                                ),
                                validator: _validVariantStock,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixText: '$_currencySymbol ',
                      ),
                      validator: _validPrice,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      validator: _validStock,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            Text(
              'Product image',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _ProductImagePicker(
              imageBytes: _selectedImageBytes,
              imageName: _selectedImageName,
              isLoading: _isPickingImage,
              isPasting: _isPastingImage,
              onChoose: _pickImage,
              onPaste: _pasteImage,
              onRemove: () {
                setState(() {
                  _selectedImageBytes = null;
                  _selectedImageName = null;
                  _imageRemoved = true;
                });
              },
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _publish,
              icon: const Icon(Icons.publish_rounded),
              label: Text(_isEditing ? 'Save changes' : 'Publish product'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String? _validPrice(String? value) {
    final price = double.tryParse(value ?? '');
    return price == null || price <= 0 ? 'Invalid' : null;
  }

  String? _validStock(String? value) {
    final stock = int.tryParse(value ?? '');
    return stock == null || stock < 1 ? 'Enter stock' : null;
  }

  String? _validVariantStock(String? value) {
    final stock = int.tryParse(value ?? '');
    return stock == null || stock < 0 ? 'Invalid' : null;
  }

  void _publish() {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    widget.state.updateStoreProfile(
      storeName: _storeNameController.text,
      ownerName: _ownerNameController.text,
      imageData: _storeImageRemoved
          ? null
          : _storeImageBytes == null
          ? widget.state.storeImageData
          : 'data:image/jpeg;base64,${base64Encode(_storeImageBytes!)}',
    );
    final selectedImageUrl = _selectedImageBytes == null
        ? null
        : 'data:image/jpeg;base64,${base64Encode(_selectedImageBytes!)}';
    final variantPrices = _category == 'food'
        ? {
            for (final size in _volumeSizes)
              size: double.parse(_volumePriceControllers[size]!.text),
          }
        : <String, double>{};
    final variantStocks = _category == 'food'
        ? {
            for (final size in _volumeSizes)
              size: int.parse(_volumeStockControllers[size]!.text),
          }
        : <String, int>{};
    final totalStock = _category == 'food'
        ? variantStocks.values.fold<int>(0, (total, stock) => total + stock)
        : int.parse(_stockController.text);
    if (_category == 'food' && totalStock < 1) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Add stock for at least one volume.')),
      );
      return;
    }
    final productPrice = _category == 'food'
        ? variantPrices['300ml']!
        : double.parse(_priceController.text);
    if (_isEditing) {
      widget.state.updateSellerProduct(
        productId: widget.product!.id,
        name: _nameController.text,
        category: _category,
        price: productPrice,
        stock: totalStock,
        description: _descriptionController.text,
        currencySymbol: _currencySymbol,
        variantPrices: variantPrices,
        variantStocks: variantStocks,
        imageUrl: _imageRemoved
            ? null
            : selectedImageUrl ?? widget.product!.imageUrl,
      );
    } else {
      widget.state.addSellerProduct(
        name: _nameController.text,
        category: _category,
        price: productPrice,
        stock: totalStock,
        description: _descriptionController.text,
        currencySymbol: _currencySymbol,
        variantPrices: variantPrices,
        variantStocks: variantStocks,
        imageUrl: selectedImageUrl,
      );
    }
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Product changes saved.'
              : 'Product published to your store.',
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = image.name;
        _imageRemoved = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      final needsRebuild = error.code == 'channel-error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            needsRebuild
                ? 'Restart the app from VS Code once to enable photo access.'
                : error.message ?? 'The photo could not be opened.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Widget _buildStoreImagePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: _storeImageBytes == null
                ? const Icon(Icons.storefront_rounded, color: Color(0xFF6C5CE7))
                : Image.memory(_storeImageBytes!, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store image',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3),
                Text(
                  'Optional — you can skip this',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          if (_storeImageBytes != null)
            IconButton(
              tooltip: 'Remove store image',
              onPressed: () {
                setState(() {
                  _storeImageBytes = null;
                  _storeImageRemoved = true;
                });
              },
              color: const Color(0xFFFF7675),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          IconButton.filledTonal(
            tooltip: _storeImageBytes == null ? 'Choose image' : 'Change image',
            onPressed: _isPickingStoreImage ? null : _pickStoreImage,
            icon: _isPickingStoreImage
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _storeImageBytes == null
                        ? Icons.add_photo_alternate_outlined
                        : Icons.swap_horiz_rounded,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStoreImage() async {
    if (_isPickingStoreImage) return;
    setState(() => _isPickingStoreImage = true);
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _storeImageBytes = bytes;
        _storeImageRemoved = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Unable to choose image.')),
      );
    } finally {
      if (mounted) setState(() => _isPickingStoreImage = false);
    }
  }

  Future<void> _pasteImage() async {
    if (_isPastingImage) return;
    setState(() => _isPastingImage = true);
    try {
      Uint8List? bytes = await Pasteboard.image;
      if (bytes == null || bytes.isEmpty) {
        final clipboardText = await Pasteboard.text;
        if (clipboardText != null &&
            (clipboardText.startsWith('https://') ||
                clipboardText.startsWith('http://'))) {
          final imageData = await NetworkAssetBundle(
            Uri.parse(clipboardText),
          ).load(clipboardText);
          bytes = imageData.buffer.asUint8List();
        } else if (clipboardText != null &&
            clipboardText.startsWith('data:image/') &&
            clipboardText.contains(',')) {
          bytes = base64Decode(clipboardText.split(',').last);
        }
      }
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copy an image first, then tap Paste photo.'),
          ),
        );
        return;
      }
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = 'Pasted photo';
        _imageRemoved = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Copy an image first, then try again.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The copied image could not be loaded. Try Choose photo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPastingImage = false);
    }
  }
}

class _ProductImagePicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageName;
  final bool isLoading;
  final bool isPasting;
  final VoidCallback onChoose;
  final VoidCallback onPaste;
  final VoidCallback onRemove;

  const _ProductImagePicker({
    required this.imageBytes,
    required this.imageName,
    required this.isLoading,
    required this.isPasting,
    required this.onChoose,
    required this.onPaste,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF475569)
        : const Color(0xFFD8DEE9);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: imageBytes == null
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 28)
          : const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: imageBytes == null
          ? Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_rounded,
                    color: Color(0xFF6C5CE7),
                    size: 29,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Add a product photo',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Choose a clear image from your device',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isLoading || isPasting ? null : onChoose,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: const Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFF6C5CE7,
                          ).withValues(alpha: 0.45),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.photo_library_rounded),
                        label: const Text('Choose photo'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading || isPasting ? null : onPaste,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          foregroundColor: const Color(0xFF6C5CE7),
                          backgroundColor: const Color(
                            0xFF6C5CE7,
                          ).withValues(alpha: isDark ? 0.14 : 0.06),
                          side: BorderSide(
                            color: const Color(
                              0xFF6C5CE7,
                            ).withValues(alpha: 0.35),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: isPasting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6C5CE7),
                                ),
                              )
                            : const Icon(Icons.content_paste_rounded),
                        label: const Text('Paste photo'),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.memory(
                    imageBytes!,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        imageName ?? 'Selected photo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: isLoading || isPasting ? null : onChoose,
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: const Text('Change'),
                    ),
                    IconButton(
                      tooltip: 'Paste another photo',
                      onPressed: isLoading || isPasting ? null : onPaste,
                      color: const Color(0xFF6C5CE7),
                      icon: const Icon(Icons.content_paste_rounded),
                    ),
                    IconButton(
                      tooltip: 'Remove photo',
                      onPressed: onRemove,
                      color: const Color(0xFFFF7675),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
