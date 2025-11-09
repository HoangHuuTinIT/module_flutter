
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../app/helpers/ui_helpers.dart';
import '../../app/models/collection.dart'; // THÊM IMPORT NÀY

class HomeCollectionItem extends StatelessWidget {
  final Collection collection;

  const HomeCollectionItem({Key? key, required this.collection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => routeTo('/collection-detail', data: collection),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // THÊM GestureDetector ĐỂ BẮT SỰ KIỆN NHẤN
            GestureDetector(
              onTap: () {
                // Kiểm tra nếu có username thì mới điều hướng
                if (collection.user?.username != null) {
                  routeTo('/user-profile', data: collection.user!.username);
                }
              },
              // Đặt màu transparent để GestureDetector bắt sự kiện trên cả vùng trống
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                          collection.user?.profileImage?.medium ?? ""),
                    ),
                    SizedBox(width: 12),
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
            SizedBox(height: 12),
            // Phần ảnh và thông tin collection (giữ nguyên)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
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
                      bottom: 16,
                      left: 16,
                      right: 16,
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
                          SizedBox(height: 4),
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