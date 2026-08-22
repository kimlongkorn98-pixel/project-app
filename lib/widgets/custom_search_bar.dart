import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onScanTap;
  final Iterable<String> suggestions;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search products, brands...',
    this.onChanged,
    this.onFilterTap,
    this.onScanTap,
    this.suggestions = const [],
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: RawAutocomplete<String>(
                    textEditingController: _controller,
                    focusNode: _focusNode,
                    displayStringForOption: (option) => option,
                    optionsBuilder: (textValue) {
                      final query = textValue.text.trim().toLowerCase();
                      if (query.isEmpty) return const Iterable<String>.empty();

                      return widget.suggestions
                          .where((suggestion) {
                            final normalized = suggestion.toLowerCase();
                            return normalized.startsWith(query);
                          })
                          .take(6);
                    },
                    onSelected: (selection) {
                      widget.onChanged?.call(selection);
                      _focusNode.unfocus();
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            autocorrect: true,
                            enableSuggestions: true,
                            stylusHandwritingEnabled: false,
                            onChanged: widget.onChanged,
                            onSubmitted: (_) => onSubmitted(),
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
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        size: 18,
                                      ),
                                      tooltip: 'Clear search',
                                      onPressed: _clearSearch,
                                    ),
                            ),
                          );
                        },
                    optionsViewBuilder: (context, onSelected, options) {
                      final items = options.toList(growable: false);
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 12,
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shrinkWrap: true,
                              itemCount: items.length,
                              separatorBuilder: (_, _) => Divider(
                                height: 1,
                                color: isDark
                                    ? Colors.white10
                                    : const Color(0xFFF1F2F6),
                              ),
                              itemBuilder: (context, index) {
                                final suggestion = items[index];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.search_rounded,
                                    color: Color(0xFF6C5CE7),
                                    size: 20,
                                  ),
                                  title: Text(
                                    suggestion,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(
                                    Icons.north_west_rounded,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  onTap: () => onSelected(suggestion),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (widget.onScanTap != null) ...[
            const SizedBox(width: 10),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onScanTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6C5CE7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Color(0xFF6C5CE7),
                      size: 20,
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
