import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        focusNode: focusNode,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: maxLines == 1 ? 18 : 16,
          ),
          filled: true,
          fillColor: colorScheme.surface,
          hintText: hintText,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.4),
            fontSize: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: prefixIcon,
                )
              : null,
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16),
                  child: suffixIcon,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}