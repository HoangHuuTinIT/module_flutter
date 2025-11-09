import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../models/photo_response.dart';
import '../networking/api_service.dart';
import 'controller.dart';

class HomeController extends Controller {
  HomeController._privateConstructor();
  static final HomeController _instance = HomeController._privateConstructor();
  static HomeController get instance => _instance;

  final ValueNotifier<List<Photo>> photos = ValueNotifier([]);
  String? _nextPageUrl;
  bool isLoadingMorePhotos = false;

  final ValueNotifier<bool> isRefreshing = ValueNotifier(false);

  Future<void> fetchInitialPhotos() async {
    PhotoResponse? response =
    await api<ApiService>((request) => request.fetchPhotos());
    if (response != null) {
      photos.value = response.photos;
      _nextPageUrl = response.nextPageUrl;
    }
  }

  Future<void> fetchMorePhotos() async {
    if (isLoadingMorePhotos || _nextPageUrl == null) return;

    isLoadingMorePhotos = true;
    photos.notifyListeners();

    PhotoResponse? response =
    await api<ApiService>((request) => request.fetchPhotos(url: _nextPageUrl));

    if (response != null) {
      photos.value = List.from(photos.value)..addAll(response.photos);
      _nextPageUrl = response.nextPageUrl;
    }

    isLoadingMorePhotos = false;
  }

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