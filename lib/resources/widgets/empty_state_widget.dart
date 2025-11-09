// lib/resources/widgets/empty_state_widget.dart

import 'package:flutter/material.dart';

import '../../constants/app_dimensions.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  const EmptyStateWidget({Key? key, this.message = "Nothing to see here..."})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hiển thị ảnh từ assets
          Image.asset(
            'public/images/empty_state.png', // Đường dẫn trong pubspec.yaml
            width: 150,
            height: 150,
          ),
          const SizedBox(height: kSpacingXXLarge),
          // Hiển thị thông báo
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}