// lib/resources/widgets/photo_info_section.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../app/controllers/photo_detail_page_controller.dart';
import '../../app/models/photo.dart';
import '../../app/controllers/photo_detail_state.dart';
import '../../constants/app_dimensions.dart'; // IMPORT STATE MỚI

class PhotoInfoSection extends StatefulWidget {
  final PhotoDetailPageController controller;
  final Photo initialPhoto;

  const PhotoInfoSection(
      {Key? key, required this.controller, required this.initialPhoto})
      : super(key: key);

  @override
  _PhotoInfoSectionState createState() => _PhotoInfoSectionState();
}

class _PhotoInfoSectionState extends State<PhotoInfoSection> {
  // @override
  // void initState() {
  //   super.initState();
  //   // ĐÃ XÓA: Controller tự gọi fetchFullDetails từ page
  // }

  @override
  Widget build(BuildContext context) {
    // ĐÃ SỬA: Lắng nghe PhotoDetailState
    return ValueListenableBuilder<PhotoDetailState>(
      valueListenable: widget.controller.photoState,
      builder: (context, state, child) {

        // Hiển thị lỗi nếu có
        if (state.errorMessage != null) {
          return Padding(
            padding: const EdgeInsets.all(kSpacingXLarge),
            child: Center(
              child: Text(
                state.errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // Dùng state.hasLoadedDetails để quyết định
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: !state.hasLoadedDetails
              ? _buildSkeleton(context, widget.initialPhoto)
              : _buildContent(context, state.photo ?? widget.initialPhoto),
        );
      },
    );
  }

  // ... (Tất cả các hàm _buildSkeleton, _buildContent, _buildUserInfo, v.v. giữ nguyên) ...
  Widget _buildSkeleton(BuildContext context, Photo initialPhoto) {
    Widget buildPlaceholder(double width, double height, {double radius = 8}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Padding(
      key: const ValueKey('skeleton'),
      padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge, vertical: kSpacingXLarge),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: kAvatarRadiusMedium,
                backgroundImage:
                NetworkImage(initialPhoto.user?.profileImage?.medium ?? ""),
              ),
              const SizedBox(width: kSpacingMedium),
              Expanded(
                child: Text(
                  initialPhoto.user?.name ?? "",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              buildPlaceholder(24, 24, radius: 12),
              const SizedBox(width: kSpacingLarge),
              buildPlaceholder(24, 24, radius: 12),
              const SizedBox(width: kSpacingLarge),
              buildPlaceholder(24, 24, radius: 12),
            ],
          ),
          const Divider(height: kSpacingHuge, thickness: 1),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: buildPlaceholder(double.infinity, 30)),
                  const SizedBox(width: kSpacingXXLarge),
                  Expanded(child: buildPlaceholder(double.infinity, 30)),
                ],
              ),
              const SizedBox(width: kSpacingXXLarge),
              Row(
                children: [
                  Expanded(child: buildPlaceholder(double.infinity, 30)),
                  const SizedBox(width: 24),
                  Expanded(child: buildPlaceholder(double.infinity, 30)),
                ],
              ),
            ],
          ),
          const Divider(height: kSpacingHuge, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kSpacingXLarge),
            child: Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.grey.shade400,
                size: kSpacingHuge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Photo photo) {
    return Padding(
      key: const ValueKey('content'),
      padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge, vertical: kSpacingXLarge),
      child: Column(
        children: [
          _buildUserInfo(context, photo),
          const Divider(height: kSpacingHuge, thickness: 1),
          _buildAllInfo(context, photo),
          const Divider(height: kSpacingHuge, thickness: 1),
          _buildPhotoStats(context, photo),
          const SizedBox(height: kSpacingXXLarge),
          _buildTags(context, photo),
          const SizedBox(height: kSpacingXXLarge),
          _buildWallpaperButton(photo),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, Photo photo) {
    return Row(
      children: [
        CircleAvatar(
          radius: kAvatarRadiusMedium,
          backgroundImage: NetworkImage(photo.user?.profileImage?.medium ?? ""),
        ),
        SizedBox(width: kSpacingMedium),
        Expanded(
          child: Text(
            photo.user?.name ?? "Unknown",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
            icon: Icon(Icons.download_outlined, color: Colors.black54),
            onPressed: () {}),
        IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black54),
            onPressed: () {}),
        IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.black54),
            onPressed: () {}),
      ],
    );
  }

  Widget _buildAllInfo(BuildContext context, Photo photo) {
    final exif = photo.exif;
    String formatValue(String? value,
        {String prefix = "", String suffix = ""}) {
      if (value == null || value.isEmpty) return "Unknown";
      return "$prefix$value$suffix";
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildStatItem("Camera", exif?.model ?? "Unknown",
                    align: CrossAxisAlignment.start)),
            Expanded(
                child: _buildStatItem(
                    "Aperture", formatValue(exif?.aperture, prefix: "f/"),
                    align: CrossAxisAlignment.start)),
          ],
        ),
        SizedBox(height: kSpacingLarge),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildStatItem("Focal Length",
                    formatValue(exif?.focalLength, suffix: "mm"),
                    align: CrossAxisAlignment.start)),
            Expanded(
                child: _buildStatItem("Shutter Speed",
                    formatValue(exif?.exposureTime, suffix: "s"),
                    align: CrossAxisAlignment.start)),
          ],
        ),
        SizedBox(height: kSpacingLarge),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildStatItem(
                    "ISO", (exif?.iso ?? 'Unknown').toString(),
                    align: CrossAxisAlignment.start)),
            Expanded(
                child: _buildStatItem("Dimensions",
                    "${photo.width ?? 'Unknown'}x${photo.height ?? ''}",
                    align: CrossAxisAlignment.start)),
          ],
        )
      ],
    );
  }

  Widget _buildPhotoStats(BuildContext context, Photo photo) {
    String formatNumber(num? value) {
      if (value == null) return "0";
      return value < 1000
          ? value.toStringAsFixed(0)
          : "${(value / 1000).toStringAsFixed(1)}K";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Views", formatNumber(photo.views)),
        _buildStatItem("Downloads", formatNumber(photo.downloads)),
        _buildStatItem("Likes", formatNumber(photo.likes)),
      ],
    );
  }

  Widget _buildTags(BuildContext context, Photo photo) {
    if (photo.tags == null || photo.tags!.isEmpty) return SizedBox.shrink();
    return Container(
      height: 35,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: photo.tags!
              .map((tag) => Padding(
            padding: const EdgeInsets.only(right: kSpacingSmall),
            child: Chip(
              label: Text(tag.title ?? ""),
              backgroundColor: Colors.grey[200],
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: kSpacingSmall),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value,
      {CrossAxisAlignment align = CrossAxisAlignment.center}) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: kSpacingExtraSmall),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildWallpaperButton(Photo photo) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.wallpaper, color: Colors.white),
        label: Text("SET AS WALLPAPER", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: kSpacingXXLarge, vertical: kSpacingMedium),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
        ),
      ),
    );
  }
}