// lib/app/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../models/photo_response.dart';
import '../networking/api_service.dart';
import 'controller.dart';

class HomeController extends Controller {
  HomeController();

  final ValueNotifier<List<Photo>> photos = ValueNotifier([]);
  String? _nextPageUrl;

  // ĐÃ SỬA: Biến `isLoadingMorePhotos` thành một ValueNotifier
  final ValueNotifier<bool> isLoadingMorePhotos = ValueNotifier(false);

  final ValueNotifier<bool> isRefreshing = ValueNotifier(false);

  Future<void> fetchInitialPhotos() async {
    // Reset trạng thái loading khi tải lại từ đầu
    isLoadingMorePhotos.value = false;

    PhotoResponse? response =
    await api<ApiService>((request) => request.fetchPhotos());
    if (response != null) {
      photos.value = response.photos;
      _nextPageUrl = response.nextPageUrl;
    }
  }

  Future<void> fetchMorePhotos() async {
    // ĐÃ SỬA: Dùng .value
    if (isLoadingMorePhotos.value || _nextPageUrl == null) return;

    // ĐÃ SỬA: Dùng .value
    isLoadingMorePhotos.value = true;

    // ĐÃ XÓA: photos.notifyListeners(); (Không cần nữa)

    PhotoResponse? response =
    await api<ApiService>((request) => request.fetchPhotos(url: _nextPageUrl));

    if (response != null) {
      photos.value = List.from(photos.value)..addAll(response.photos);
      _nextPageUrl = response.nextPageUrl;
    }

    // ĐÃ SỬA: Dùng .value
    isLoadingMorePhotos.value = false;
  }

  // ... (các hàm còn lại giữ nguyên) ...
  Future<void> onRefresh() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    await fetchInitialPhotos();
    await Future.delayed(const Duration(seconds: 1));
    isRefreshing.value = false;
  }


  void scrollToTop(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}