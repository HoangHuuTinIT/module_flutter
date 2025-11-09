import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../models/photo_response.dart';
import '../networking/api_service.dart';
import 'controller.dart';
import 'home_state.dart'; // IMPORT STATE MỚI

class HomeController extends Controller {
  HomeController();

  // ĐÃ SỬA: Dùng một State Object duy nhất
  final ValueNotifier<HomeState> homeState = ValueNotifier(HomeState());

  String? _nextPageUrl;

  Future<void> fetchInitialPhotos() async {
    // Reset state về refreshing
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
      }
    } catch (e) {
      // Có thể hiển thị lỗi tinh tế hơn (ví dụ: SnackBar) thay vì ghi đè errorMessage
      homeState.value = homeState.value.copyWith(isLoadingMore: false);
    }
  }

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