import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearchPressed;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? borderRadius;

  const SearchTextField({
    Key? key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSearchPressed,
    this.margin,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: margin ?? EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? 24 : 16,
        vertical: 8,
      ),
      constraints: BoxConstraints(
        maxWidth: screenWidth > 600 ? 600 : double.infinity,
      ),
      height: height ?? (screenWidth > 600 ? 56 : 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? (screenWidth > 600 ? 28 : 24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: screenWidth > 600 ? 24 : 16),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: screenWidth > 600 ? 18 : 16,
                  ),
                ),
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 18 : 16,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              size: screenWidth > 600 ? 28 : 24,
              color: Colors.grey[600],
            ),
            onPressed: onSearchPressed ?? () {
              FocusScope.of(context).unfocus();
            },
          ),
        ],
      ),
    );
  }
}