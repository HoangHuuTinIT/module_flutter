// lib/resources/widgets/user_collections_tab.dart

import 'package:flutter/material.dart';

import '../../app/controllers/user_profile_controller.dart';
// IMPORT STATE MỚI
import '../../app/controllers/user_profile_state.dart';
import '../../app/models/collection.dart';
import 'collection_list_item.dart';

class UserCollectionsTab extends StatefulWidget {
  final UserProfileController controller;
  const UserCollectionsTab({Key? key, required this.controller}) : super(key: key);

  @override
  State<UserCollectionsTab> createState() => _UserCollectionsTabState();
}

class _UserCollectionsTabState extends State<UserCollectionsTab> {
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
      widget.controller.fetchMoreCollections();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ĐÃ SỬA: Lắng nghe controller.state
    return ValueListenableBuilder<UserProfileState>(
      // ĐÃ SỬA: Đổi tên thành 'userProfileState'
      valueListenable: widget.controller.userProfileState,
      builder: (context, state, _) {
        // ĐÃ SỬA: Lấy 'collections' và 'isLoadingMore' từ state
        final collections = state.collections;
        final isLoadingMore = state.isLoadingMoreCollections;

        if (collections.isEmpty && !isLoadingMore) { // Thêm check !isLoadingMore
          return Center(
              child: Text("No collections found.",
                  style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          // ĐÃ SỬA: Dùng biến isLoadingMore
          itemCount: collections.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= collections.length) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                    child: CircularProgressIndicator(color: Colors.black)),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CollectionListItem(collection: collections[index]),
              ),
            );
          },
        );
      },
    );
  }
}