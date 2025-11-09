// lib/app/controllers/collection_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/collection.dart';
import '../models/photo.dart';
import '../networking/api_service.dart';
import 'controller.dart';
import '../states/collection_detail_state.dart';

class CollectionDetailController extends Controller {
  Collection? initialCollection;
  final ValueNotifier<CollectionDetailState> detailState =
  ValueNotifier(CollectionDetailState());

  int _page = 1;
  bool _hasMore = true;

  void setupInitial(Collection collection) {
    initialCollection = collection;
  }

  Future<void> fetchAllDetails() async {
    if (initialCollection?.id == null) return;

    detailState.value = detailState.value.copyWith(isLoading: true, errorMessage: null);
    _page = 1;
    _hasMore = true;

    try {
      final results = await Future.wait([
        api<ApiService>((request) =>
            request.fetchCollectionDetails(initialCollection!.id!)),
        api<ApiService>((request) =>
            request.fetchPhotosForCollection(initialCollection!.id!, page: _page)),
      ]);

      final collectionDetails = results[0] as Collection?;
      final initialPhotos = results[1] as List<Photo>? ?? [];

      if (initialPhotos.length < 20) {
        _hasMore = false;
      }

      detailState.value = detailState.value.copyWith(
        detailedCollection: collectionDetails,
        photos: initialPhotos,
        isLoading: false,
      );
    } catch (e) {
      detailState.value = detailState.value.copyWith(
          isLoading: false,
          errorMessage: "Không thể tải chi tiết collection."
      );
    }
  }

  Future<void> fetchMoreCollectionPhotos() async {
    if (detailState.value.isLoadingMore ||
        !_hasMore ||
        initialCollection?.id == null) return;

    detailState.value = detailState.value.copyWith(isLoadingMore: true);
    _page++;

    try {
      List<Photo>? newPhotos = await api<ApiService>((request) =>
          request.fetchPhotosForCollection(initialCollection!.id!, page: _page));

      if (newPhotos != null) {
        if (newPhotos.isEmpty || newPhotos.length < 20) {
          _hasMore = false;
        }
        detailState.value = detailState.value.copyWith(
          photos: List.from(detailState.value.photos)..addAll(newPhotos),
          isLoadingMore: false,
        );
      } else {
        _hasMore = false;
        detailState.value = detailState.value.copyWith(isLoadingMore: false);
      }
    } catch(e) {
      // ĐÃ SỬA: Xử lý lỗi khi tải thêm
      _hasMore = false;
      detailState.value = detailState.value.copyWith(isLoadingMore: false);
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

  // ... (handleScroll giữ nguyên) ...
  void handleScroll(ScrollController scrollController) {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9) {
      fetchMoreCollectionPhotos();
    }
  }
}