import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/controllers/user_profile_controller.dart';
import '../../app/states/user_profile_state.dart';
import '../../app/helpers/ui_helpers.dart';
import '../../app/constants/app_dimensions.dart';
import '../../resources/pages/photo_detail_page.dart';


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
    return ValueListenableBuilder<UserProfileState>(
      valueListenable: widget.controller.userProfileState,
      builder: (context, state, _) {
        final photos = state.userPhotos;
        final isLoadingMore = state.isLoadingMoreUserPhotos;

        if (photos.isEmpty && !isLoadingMore) {
          return Center(
              child:
              Text("No photos found.", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: kSpacingSmall),
          itemCount: photos.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= photos.length) {
              return Padding(
                padding: const EdgeInsets.all(kSpacingLarge),
                child: Center(child: CircularProgressIndicator(color: Colors.black)),
              );
            }

            final photo = photos[index];
            return GestureDetector(
              onTap: () => routeTo(PhotoDetailPage.path, data: photo),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: kSpacingSmall, horizontal: kSpacingMedium),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                  child: AspectRatio(
                    aspectRatio: photo.aspectRatio,
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