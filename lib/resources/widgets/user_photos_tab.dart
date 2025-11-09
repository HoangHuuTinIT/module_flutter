import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../app/controllers/user_profile_controller.dart';
import '../../app/helpers/ui_helpers.dart';
import '../../app/models/photo.dart';

class UserPhotosTab extends StatefulWidget {
  final UserProfileController controller;
  const UserPhotosTab({Key? key, required this.controller}) : super(key: key);

  @override
  State<UserPhotosTab> createState() => _UserPhotosTabState();
}

class _UserPhotosTabState extends State<UserPhotosTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      widget.controller.fetchMoreUserPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Photo>>(
      valueListenable: widget.controller.userPhotos,
      builder: (context, photos, _) {
        if (photos.isEmpty && !widget.controller.isLoadingMoreUserPhotos) {
          return Center(
              child:
              Text("No photos found.", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: photos.length + (widget.controller.isLoadingMoreUserPhotos ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= photos.length) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(color: Colors.black)),
              );
            }

            final photo = photos[index];
            final double aspectRatio = (photo.width != null &&
                photo.height != null &&
                photo.height! > 0)
                ? photo.width! / photo.height!
                : 16 / 9;

            // BỌC PADDING BẰNG GESTUREDETECTOR
            return GestureDetector(
              onTap: () => routeTo('/photo-detail', data: photo),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: NetworkImageWithPlaceholder(
                      imageUrl: photo.urls?.regular ?? photo.urls?.small ?? "",
                      placeholderColorHex: photo.color,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}