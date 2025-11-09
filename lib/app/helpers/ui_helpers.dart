import 'package:flutter/material.dart';

Color hexToColor(String hexString, {String alpha = 'FF'}) {
  try {
    return Color(int.parse(hexString.replaceFirst('#', '0x$alpha')));
  } catch (e) {
    return Colors.grey[200]!;
  }
}

class NetworkImageWithPlaceholder extends StatelessWidget {
  final String imageUrl;
  final String? placeholderColorHex;
  final BoxFit fit;

  const NetworkImageWithPlaceholder({
    Key? key,
    required this.imageUrl,
    this.placeholderColorHex,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final placeholderColor = placeholderColorHex != null
        ? hexToColor(placeholderColorHex!)
        : Colors.grey[200]!;

    return Image.network(
      imageUrl,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          child: child,
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(color: placeholderColor);
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Icon(Icons.broken_image, color: Colors.grey[400]),
        );
      },
    );
  }
}