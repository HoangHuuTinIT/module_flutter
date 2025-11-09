import 'package:flutter/material.dart';

import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

import '../../app/models/photo.dart';
class PhotoListItem extends StatelessWidget {
  final Photo photo;

  const PhotoListItem({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenWidth * 0.03;
    final avatarRadius = screenWidth * 0.05;
    final spacing = screenWidth * 0.03;
    final borderRadius = screenWidth * 0.03;

    final double aspectRatio = (photo.width != null &&
        photo.height != null &&
        photo.height! > 0)
        ? photo.width! / photo.height!
        : 16 / 9;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (photo.user?.username != null) {
                routeTo('/user-profile', data: photo.user!.username);
              }
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage:
                    NetworkImage(photo.user?.profileImage?.medium ?? ""),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Text(
                      photo.user?.name ?? "Unknown",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => routeTo('/photo-detail', data: photo),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (photo.blurHash != null)
                      BlurHash(hash: photo.blurHash!),
                    Image.network(
                      photo.urls?.small ?? "",
                      fit: BoxFit.cover,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return AnimatedOpacity(
                          child: child,
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOut,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image,
                              color: Colors.grey[600]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}