// lib/resources/pages/collections_page.dart

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/controllers/collections_controller.dart';
import '../../app/models/collection.dart';
import '../widgets/home_collection_item.dart';
import '../../app/controllers/collections_state.dart'; // IMPORT STATE MỚI

class CollectionsPage extends NyStatefulWidget<CollectionsController> {
  CollectionsPage({super.key}) : super(child: () => _CollectionsPageState());
}

class _CollectionsPageState extends NyPage<CollectionsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  get init => () async {
    if (widget.controller.collectionsState.value.collections.isEmpty) {
      await widget.controller.fetchInitialCollections();
    }
  };
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      widget.controller.handleCollectionsScroll(_scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    // ĐÃ SỬA: Chỉ dùng 1 ValueListenableBuilder
    return ValueListenableBuilder<CollectionsState>(
        valueListenable: widget.controller.collectionsState,
        builder: (context, state, _) {

          // Hiển thị lỗi
          if (state.errorMessage != null && !state.isLoading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // Logic kiểm tra loading ban đầu
          if (state.isLoading) {
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.grey.shade400,
                size: 50,
              ),
            );
          }

          // Danh sách rỗng
          if (state.collections.isEmpty && !state.isLoadingMore) {
            return Center(child: Text("No collections found."));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: state.collections.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.collections.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.black)),
                );
              }
              return HomeCollectionItem(collection: state.collections[index]);
            },
          );
        });
  }
}