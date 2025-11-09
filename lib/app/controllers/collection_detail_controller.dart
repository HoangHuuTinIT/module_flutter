
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/collection.dart';
import '../models/photo.dart';
import '../networking/api_service.dart';
import 'controller.dart';

class CollectionDetailController extends Controller {
  Collection? initialCollection;
  final ValueNotifier<Collection?> detailedCollection = ValueNotifier(null);
  final ValueNotifier<List<Photo>> photos = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(true);

  int _page = 1;
  bool _hasMore = true;
  bool isLoadingMore = false;

  void setupInitial(Collection collection) {
    initialCollection = collection;
  }

  Future<void> fetchAllDetails() async {
    if (initialCollection?.id == null) return;
    isLoading.value = true;
    _page = 1;
    _hasMore = true;
    final results = await Future.wait([
      api<ApiService>((request) => request.fetchCollectionDetails(initialCollection!.id!)),
      api<ApiService>((request) => request.fetchPhotosForCollection(initialCollection!.id!, page: _page)),
    ]);

    detailedCollection.value = results[0] as Collection?;
    final initialPhotos = results[1] as List<Photo>? ?? [];

    photos.value = initialPhotos;
    if (initialPhotos.length < 20) {
      _hasMore = false;
    }

    isLoading.value = false;
  }

  Future<void> fetchMoreCollectionPhotos() async {
    if (isLoadingMore || !_hasMore || initialCollection?.id == null) return;

    isLoadingMore = true;
    photos.notifyListeners();

    _page++;
    List<Photo>? newPhotos = await api<ApiService>((request) =>
        request.fetchPhotosForCollection(initialCollection!.id!, page: _page));

    if (newPhotos != null) {
      if (newPhotos.isEmpty || newPhotos.length < 20) {
        _hasMore = false;
      }
      photos.value = List.from(photos.value)..addAll(newPhotos);
    } else {
      _hasMore = false;
    }
    isLoadingMore = false;
  }

  void handleScroll(ScrollController scrollController) {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9) {
      fetchMoreCollectionPhotos();
    }
  }
}