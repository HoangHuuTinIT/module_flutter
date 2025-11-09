import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../app/controllers/photo_detail_page_controller.dart';
import '../../app/models/photo.dart';

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
  @override
  void initState() {
    super.initState();
    widget.controller.fetchFullDetails();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Photo?>(
      valueListenable: widget.controller.photoNotifier,
      builder: (context, detailedPhoto, child) {
        final currentPhoto = detailedPhoto ?? widget.initialPhoto;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: currentPhoto.exif == null
              ? _buildSkeleton(context, widget.initialPhoto)
              : _buildContent(context, currentPhoto),
        );
      },
    );
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage(initialPhoto.user?.profileImage?.medium ?? ""),
              ),
              const SizedBox(width: 12),
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
              const SizedBox(width: 16),
              buildPlaceholder(24, 24, radius: 12),
              const SizedBox(width: 16),
              buildPlaceholder(24, 24, radius: 12),
            ],
          ),
          const Divider(height: 40, thickness: 1),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: buildPlaceholder(double.infinity, 30)),
                  const SizedBox(width: 24),
                  Expanded(child: buildPlaceholder(double.infinity, 30)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: buildPlaceholder(double.infinity, 30)),
                  const SizedBox(width: 24),
                  Expanded(child: buildPlaceholder(double.infinity, 30)),
                ],
              ),
            ],
          ),
          const Divider(height: 40, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.grey.shade400,
                size: 40,
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: [
          _buildUserInfo(context, photo),
          const Divider(height: 40, thickness: 1),
          _buildAllInfo(context, photo),
          const Divider(height: 40, thickness: 1),
          _buildPhotoStats(context, photo),
          const SizedBox(height: 24),
          _buildTags(context, photo),
          const SizedBox(height: 32),
          _buildWallpaperButton(photo),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, Photo photo) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(photo.user?.profileImage?.medium ?? ""),
        ),
        SizedBox(width: 12),
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
        SizedBox(height: 16),
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
        SizedBox(height: 16),
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
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(tag.title ?? ""),
                      backgroundColor: Colors.grey[200],
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(horizontal: 8),
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
        SizedBox(height: 4),
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
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }
}
