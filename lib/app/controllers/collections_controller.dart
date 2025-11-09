// lib/app/controllers/collections_controller.dart

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/collection.dart';
import '../networking/api_service.dart';
import 'controller.dart';
import 'collections_state.dart'; // IMPORT STATE MỚI

class CollectionsController extends Controller {
  CollectionsController();

  // ĐÃ SỬA: Dùng một State Object duy nhất
  final ValueNotifier<CollectionsState> collectionsState =
  ValueNotifier(CollectionsState());

  int _allCollectionsPage = 1;
  bool _hasMoreCollections = true;

  Future<void> fetchInitialCollections() async {
    // Set state về loading ban đầu
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
      _hasMoreCollections = false; // Dừng việc tải thêm nếu có lỗi
      collectionsState.value =
          collectionsState.value.copyWith(isLoadingMore: false);
    }
  }

  void handleCollectionsScroll(ScrollController scrollController) {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9) {
      fetchMoreCollections();
    }
  }
}