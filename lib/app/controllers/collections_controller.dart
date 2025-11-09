// lib/app/controllers/collections_controller.dart

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/collection.dart';
import '../networking/api_service.dart';
import 'controller.dart';
import '../states/collections_state.dart';

class CollectionsController extends Controller {
  CollectionsController();

  final ValueNotifier<CollectionsState> collectionsState =
  ValueNotifier(CollectionsState());

  int _allCollectionsPage = 1;
  bool _hasMoreCollections = true;

  Future<void> fetchInitialCollections() async {
    collectionsState.value = collectionsState.value.copyWith(isLoading: true, errorMessage: null);
    _allCollectionsPage = 1;
    _hasMoreCollections = true;

    try {
      List<Collection>? initialCollections = await api<ApiService>(
              (request) => request.fetchAllCollections(page: _allCollectionsPage));

      if (initialCollections != null) {
        if (initialCollections.length < 20) {
          _hasMoreCollections = false;
        }
        collectionsState.value = collectionsState.value.copyWith(
          collections: initialCollections,
          isLoading: false,
        );
      }
    } catch (e) {
      collectionsState.value = collectionsState.value.copyWith(
        isLoading: false,
        errorMessage: "Không thể tải collections.",
      );
    }
  }

  Future<void> fetchMoreCollections() async {
    if (collectionsState.value.isLoadingMore || !_hasMoreCollections) return;

    collectionsState.value =
        collectionsState.value.copyWith(isLoadingMore: true);
    _allCollectionsPage++;

    try {
      List<Collection>? newCollections = await api<ApiService>(
              (request) => request.fetchAllCollections(page: _allCollectionsPage));

      if (newCollections != null) {
        if (newCollections.isEmpty || newCollections.length < 20) {
          _hasMoreCollections = false;
        }
        collectionsState.value = collectionsState.value.copyWith(
          collections: List.from(collectionsState.value.collections)
            ..addAll(newCollections),
          isLoadingMore: false,
        );
      } else {
        _hasMoreCollections = false;
        collectionsState.value =
            collectionsState.value.copyWith(isLoadingMore: false);
      }
    } catch (e) {
      // ĐÃ SỬA: Xử lý lỗi khi tải thêm
      _hasMoreCollections = false;
      collectionsState.value =
          collectionsState.value.copyWith(isLoadingMore: false);
      // CÁCH SỬA ĐÚNG:
      showToastNotification(
        // Tạo một đối tượng ToastMeta kiểu danger
        ToastMeta.danger(
          title: "Lỗi",
          description: "Không thể tải thêm.",
        ) as BuildContext,
      );
    }
  }

  // ... (handleCollectionsScroll giữ nguyên) ...
  void handleCollectionsScroll(ScrollController scrollController) {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9) {
      fetchMoreCollections();
    }
  }
}