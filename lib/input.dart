import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    this.title,
    this.subtitle,
    this.controller,
    this.isSearch = false,
    this.onChange,
    this.minLines=1,
    this.keyboardType = TextInputType.text,
  });
  final String? title;
  final String? subtitle;
  final bool isSearch;
  final int minLines;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final Function(String _)? onChange;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.title ?? "Tên danh mục",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        TextField(
          controller: widget.controller,
          maxLength: 255,
maxLines: widget.minLines,
minLines: widget.minLines,
keyboardType: widget.keyboardType,
          buildCounter:
              (
                context, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) {
                return const SizedBox.shrink();
              },
          onChanged: widget.onChange,
          decoration: InputDecoration(
            hintText: widget.subtitle ?? "Nhập tên danh mục",
            prefixIcon: widget.isSearch
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(Icons.search_rounded),
                  )
                : null,
            prefixIconConstraints: BoxConstraints(),
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black87, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
