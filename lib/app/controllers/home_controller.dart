import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
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
        _nextPageUrl = null;
        homeState.value = homeState.value.copyWith(isLoadingMore: false);
      }
    } catch (e) {
      _nextPageUrl = null;
      homeState.value = homeState.value.copyWith(isLoadingMore: false);
      if (context != null) {
        showToastNotification(
          context!,
          style: ToastNotificationStyleType.danger,
          title: "Lỗi",
          description: "Không thể tải thêm. Vui lòng thử lại sau.",
        );
      }
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