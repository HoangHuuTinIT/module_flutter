// lib/resources/widgets/home_collection_item.dart

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../app/helpers/ui_helpers.dart';
import '../../app/models/collection.dart';
// IMPORT MỚI
import '../../constants/app_dimensions.dart';
import '../../resources/pages/collection_detail_page.dart';
import '../../resources/pages/user_profile_page.dart';

class HomeCollectionItem extends StatelessWidget {
  final Collection collection;

  const HomeCollectionItem({Key? key, required this.collection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ĐÃ SỬA: Dùng CollectionDetailPage.path thay vì string
      onTap: () => routeTo(CollectionDetailPage.path, data: collection),
      child: Padding(
        padding: const EdgeInsets.only(bottom: kSpacingXXLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // THÊM GestureDetector ĐỂ BẮT SỰ KIỆN NHẤN
            GestureDetector(
              onTap: () {
                // Kiểm tra nếu có username thì mới điều hướng
                if (collection.user?.username != null) {
                  // ĐÃ SỬA: Dùng UserProfilePage.path thay vì string
                  routeTo(UserProfilePage.path, data: collection.user!.username);
                }
              },
              // Đặt màu transparent để GestureDetector bắt sự kiện trên cả vùng trống
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: kAvatarRadiusSmall,
                      backgroundImage: NetworkImage(
                          collection.user?.profileImage?.medium ?? ""),
                    ),
                    SizedBox(width: kSpacingMedium),
                    Text(
                      collection.user?.name ?? "Unknown User",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: kSpacingMedium),
            // Phần ảnh và thông tin collection (giữ nguyên)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (collection.coverPhoto?.urls?.regular != null)
                      NetworkImageWithPlaceholder(
                        imageUrl: collection.coverPhoto!.urls!.regular!,
                        placeholderColorHex: collection.coverPhoto!.color,
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: kSpacingLarge,
                      left: kSpacingLarge,
                      right: kSpacingLarge,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collection.title ?? "Untitled",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: kSpacingExtraSmall),
                          Text(
                            "${collection.totalPhotos} Photos",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}