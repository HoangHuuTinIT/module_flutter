import 'package:flutter/material.dart';
import '../../app/constants/app_dimensions.dart';

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
          Image.asset(
            'public/images/empty_state.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: kSpacingXXLarge),
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