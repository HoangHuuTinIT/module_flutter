// lib/resources/widgets/photo_list_item.dart

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

import '../../app/models/photo.dart';
// IMPORT MỚI
import '../../app/constants/app_dimensions.dart';
import '../../resources/pages/user_profile_page.dart';
import '../../resources/pages/photo_detail_page.dart';

class PhotoListItem extends StatelessWidget {
  final Photo photo;

  const PhotoListItem({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: kSpacingMedium,
        horizontal: kSpacingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (photo.user?.username != null) {
                // ĐÃ SỬA: Dùng UserProfilePage.path thay vì string
                routeTo(UserProfilePage.path, data: photo.user!.username);
              }
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: kSpacingMedium),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: kAvatarRadiusMedium,
                    backgroundImage:
                    NetworkImage(photo.user?.profileImage?.medium ?? ""),
                  ),
                  SizedBox(width: kSpacingMedium),
                  Expanded(
                    child: Text(
                      photo.user?.name ?? "Unknown",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            // ĐÃ SỬA: Dùng PhotoDetailPage.path thay vì string
            onTap: () => routeTo(PhotoDetailPage.path, data: photo),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kBorderRadiusMedium),
              child: AspectRatio(
                aspectRatio: photo.aspectRatio,
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