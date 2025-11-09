// lib/app/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../models/photo_response.dart';
import '../networking/api_service.dart';
import 'controller.dart';
import '../states/home_state.dart';

class HomeController extends Controller {
  HomeController();

  final ValueNotifier<HomeState> homeState = ValueNotifier(HomeState());

  String? _nextPageUrl;

  Future<void> fetchInitialPhotos() async {
    homeState.value = homeState.value.copyWith(isRefreshing: true, errorMessage: null);

    try {
      PhotoResponse? response =
      await api<ApiService>((request) => request.fetchPhotos());
      if (response != null) {
        _nextPageUrl = response.nextPageUrl;
        homeState.value = homeState.value.copyWith(
          photos: response.photos,
          isRefreshing: false,
        );
      }
    } catch (e) {
      homeState.value = homeState.value.copyWith(
        isRefreshing: false,
        errorMessage: "Không thể tải dữ liệu. Vui lòng thử lại.",
      );
    }
  }

  Future<void> fetchMorePhotos() async {
    if (homeState.value.isLoadingMore || _nextPageUrl == null) return;

    homeState.value = homeState.value.copyWith(isLoadingMore: true);

    try {
      PhotoResponse? response = await api<ApiService>(
              (request) => request.fetchPhotos(url: _nextPageUrl));

      if (response != null) {
        _nextPageUrl = response.nextPageUrl;
        homeState.value = homeState.value.copyWith(
          photos: List.from(homeState.value.photos)..addAll(response.photos),
          isLoadingMore: false,
        );
      } else {
        // Nếu response là null (ít xảy ra vì ApiService ném lỗi)
        _nextPageUrl = null;
        homeState.value = homeState.value.copyWith(isLoadingMore: false);
      }
    } catch (e) {
      // ĐÃ SỬA: Xử lý lỗi khi tải thêm
      _nextPageUrl = null; // Dừng tải thêm
      homeState.value = homeState.value.copyWith(isLoadingMore: false);
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

  // ... (các hàm onRefresh, scrollToTop giữ nguyên) ...
  Future<void> onRefresh() async {
    if (homeState.value.isRefreshing) return;
    await fetchInitialPhotos();
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