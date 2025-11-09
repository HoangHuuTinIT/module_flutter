// lib/resources/widgets/user_likes_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_module_4/resources/widgets/photo_list_item.dart';

import '../../app/controllers/user_profile_controller.dart';
// IMPORT STATE MỚI
import '../../app/controllers/user_profile_state.dart';
import '../../app/models/photo.dart';

class UserLikesTab extends StatefulWidget {
  final UserProfileController controller;
  const UserLikesTab({Key? key, required this.controller}) : super(key: key);

  @override
  State<UserLikesTab> createState() => _UserLikesTabState();
}

class _UserLikesTabState extends State<UserLikesTab> {
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
      widget.controller.fetchMoreLikedPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ĐÃ SỬA: Lắng nghe controller.state
    return ValueListenableBuilder<UserProfileState>(
      // ĐÃ SỬA: Đổi tên thành 'userProfileState'
        valueListenable: widget.controller.userProfileState,
        builder: (context, state, _) {
          // ĐÃ SỬA: Lấy 'photos' và 'isLoadingMore' từ state
          final photos = state.likedPhotos;
          final isLoadingMore = state.isLoadingMoreLikedPhotos;

          if (photos.isEmpty && !isLoadingMore) { // Thêm check !isLoadingMore
            return Center(
                child: Text("No liked photos found.",
                    style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            controller: _scrollController,
            // ĐÃ SỬA: Dùng biến isLoadingMore
            itemCount: photos.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= photos.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.black)),
                );
              }
              return PhotoListItem(photo: photos[index]);
            },
          );
        });
  }
}