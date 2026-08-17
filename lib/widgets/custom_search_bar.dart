import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onScanTap;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search products, brands...',
    this.onChanged,
    this.onFilterTap,
    this.onScanTap,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_updateClearButton);
  }

  void _updateClearButton() => setState(() {});

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_updateClearButton)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                autocorrect: true,
                enableSuggestions: true,
                stylusHandwritingEnabled: false,
                onChanged: widget.onChanged,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C5CE7),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C5CE7),
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF6C5CE7),
                    size: 22,
                  ),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          tooltip: 'Clear search',
                          onPressed: _clearSearch,
                        ),
                ),
              ),
            ),
          ),
          if (widget.onScanTap != null) ...[
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onScanTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
