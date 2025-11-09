import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/collection.dart';
import '../models/photo.dart';
import '../models/user_detail.dart';
import '../networking/api_service.dart';
import 'controller.dart';

class UserProfileController extends Controller {
  UserProfileController._privateConstructor();
  static final UserProfileController _instance =
  UserProfileController._privateConstructor();
  static UserProfileController get instance => _instance;

  final ValueNotifier<UserDetail?> userDetail = ValueNotifier(null);
  final ValueNotifier<bool> isUserLoading = ValueNotifier(true);

  final ValueNotifier<bool> isTabsLoading = ValueNotifier(true);
  final ValueNotifier<List<Photo>> userPhotos = ValueNotifier([]);
  final ValueNotifier<List<Photo>> likedPhotos = ValueNotifier([]);
  final ValueNotifier<List<Collection>> collections = ValueNotifier([]);

  int _userPhotosPage = 1;
  bool _hasMoreUserPhotos = true;
  bool isLoadingMoreUserPhotos = false;
  int _likedPhotosPage = 1;
  bool _hasMoreLikedPhotos = true;
  bool isLoadingMoreLikedPhotos = false;
  int _collectionsPage = 1;
  bool _hasMoreCollections = true;
  bool isLoadingMoreCollections = false;
  void resetState() {
    userDetail.value = null;
    isUserLoading.value = true;
    isTabsLoading.value = true;
    userPhotos.value = [];
    likedPhotos.value = [];
    collections.value = [];
    _userPhotosPage = 1;
    _hasMoreUserPhotos = true;
    isLoadingMoreUserPhotos = false;
    _likedPhotosPage = 1;
    _hasMoreLikedPhotos = true;
    isLoadingMoreLikedPhotos = false;
    _collectionsPage = 1;
    _hasMoreCollections = true;
    isLoadingMoreCollections = false;
  }

  Future<void> fetchUserDetails(String username) async {
    resetState();

    UserDetail? userResponse =
    await api<ApiService>((request) => request.fetchUserDetails(username));

    if (userResponse != null) {
      userDetail.value = userResponse;
    }
    isUserLoading.value = false;
  }

  Future<void> fetchTabsData(String username) async {
    isTabsLoading.value = true;
    final results = await Future.wait([
      api<ApiService>((request) => request.fetchUserPhotos(username, page: _userPhotosPage)),
      api<ApiService>((request) => request.fetchUserLikes(username, page: _likedPhotosPage)),
      api<ApiService>((request) => request.fetchUserCollections(username, page: _collectionsPage)),
    ]);

    final initialUserPhotos = results[0] as List<Photo>? ?? [];
    userPhotos.value = initialUserPhotos;
    if (initialUserPhotos.length < 20) {
      _hasMoreUserPhotos = false;
    }

    final initialLikedPhotos = results[1] as List<Photo>? ?? [];
    likedPhotos.value = initialLikedPhotos;
    if (initialLikedPhotos.length < 20) {
      _hasMoreLikedPhotos = false;
    }

    final initialCollections = results[2] as List<Collection>? ?? [];
    collections.value = initialCollections;
    if (initialCollections.length < 20) {
      _hasMoreCollections = false;
    }

    isTabsLoading.value = false;
  }
  Future<void> fetchMoreUserPhotos() async {
    if (isLoadingMoreUserPhotos || !_hasMoreUserPhotos || userDetail.value == null) return;

    isLoadingMoreUserPhotos = true;
    _userPhotosPage++;

    List<Photo>? newPhotos = await api<ApiService>((request) =>
        request.fetchUserPhotos(userDetail.value!.username!, page: _userPhotosPage));

    if (newPhotos != null) {
      if (newPhotos.isEmpty || newPhotos.length < 20) {
        _hasMoreUserPhotos = false;
      }
      userPhotos.value = List.from(userPhotos.value)..addAll(newPhotos);
    } else {
      _hasMoreUserPhotos = false;
    }

    isLoadingMoreUserPhotos = false;
  }
  Future<void> fetchMoreLikedPhotos() async {
    if (isLoadingMoreLikedPhotos || !_hasMoreLikedPhotos || userDetail.value == null) return;

    isLoadingMoreLikedPhotos = true;
    _likedPhotosPage++;

    List<Photo>? newPhotos = await api<ApiService>((request) =>
        request.fetchUserLikes(userDetail.value!.username!, page: _likedPhotosPage));

    if (newPhotos != null) {
      if (newPhotos.isEmpty || newPhotos.length < 20) {
        _hasMoreLikedPhotos = false;
      }
      likedPhotos.value = List.from(likedPhotos.value)..addAll(newPhotos);
    } else {
      _hasMoreLikedPhotos = false;
    }

    isLoadingMoreLikedPhotos = false;
  }
  Future<void> fetchMoreCollections() async {
    if (isLoadingMoreCollections || !_hasMoreCollections || userDetail.value == null) return;

    isLoadingMoreCollections = true;
    _collectionsPage++;

    List<Collection>? newCollections = await api<ApiService>((request) =>
        request.fetchUserCollections(userDetail.value!.username!, page: _collectionsPage));

    if (newCollections != null) {
      if (newCollections.isEmpty || newCollections.length < 20) {
        _hasMoreCollections = false;
      }
      collections.value = List.from(collections.value)..addAll(newCollections);
    } else {
      _hasMoreCollections = false;
    }

    isLoadingMoreCollections = false;
  }
}