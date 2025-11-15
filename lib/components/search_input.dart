import 'dart:async';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

/// A reusable search input with a built-in clear (X) icon and optional debounce.
class CommonSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Duration debounceDuration;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const CommonSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search',
    this.debounceDuration = const Duration(milliseconds: 250),
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<CommonSearchField> createState() => _CommonSearchFieldState();
}

class _CommonSearchFieldState extends State<CommonSearchField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    if (widget.onChanged == null) return;
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;
        return TextField(
          controller: widget.controller,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (v) => widget.onSubmitted?.call(),
          cursorColor: AppColor.black12Color,
          style: const TextStyle().normal14w500.textColor(AppColor.black12Color),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle().normal14w500.textColor(AppColor.grey6EColor),
            filled: true,
            fillColor: AppColor.greyF6Color,
            prefixIcon: const Icon(Icons.search, color: AppColor.grey6EColor),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColor.grey6EColor),
                    onPressed: () {
                      // Cancel any pending debounce for previous query
                      _debounce?.cancel();
                      widget.controller.clear();
                      // Immediately propagate empty string so list restores without flicker
                      widget.onChanged?.call('');
                      setState(() {});
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColor.greyF6Color, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColor.black12Color, width: 1.2),
            ),
          ),
        );
      },
    );
  }
}
