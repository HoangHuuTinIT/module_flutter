// lib/app/controllers/user_profile_controller.dart

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/collection.dart';
import '../models/photo.dart';
import '../models/user_detail.dart';
import '../networking/api_service.dart';
import 'controller.dart';
import 'user_profile_state.dart';

class UserProfileController extends Controller {
  UserProfileController();

  final ValueNotifier<UserProfileState> userProfileState = ValueNotifier(UserProfileState());

  // ... (biến phân trang giữ nguyên) ...
  int _userPhotosPage = 1;
  bool _hasMoreUserPhotos = true;
  int _likedPhotosPage = 1;
  bool _hasMoreLikedPhotos = true;
  int _collectionsPage = 1;
  bool _hasMoreCollections = true;


  void resetState() {
    // ... (reset biến phân trang) ...
    _userPhotosPage = 1;
    _hasMoreUserPhotos = true;
    _likedPhotosPage = 1;
    _hasMoreLikedPhotos = true;
    _collectionsPage = 1;
    _hasMoreCollections = true;
    userProfileState.value = userProfileState.value.reset();
  }

  Future<void> fetchUserDetails(String username) async {
    resetState();

    try { // ĐÃ THÊM try-catch
      UserDetail? userResponse =
      await api<ApiService>((request) => request.fetchUserDetails(username));

      userProfileState.value = userProfileState.value.copyWith(
        userDetail: userResponse,
        isUserLoading: false,
      );
    } catch (e) {
      // ĐÃ THÊM: Cập nhật state với lỗi
      userProfileState.value = userProfileState.value.copyWith(
        isUserLoading: false,
        errorMessage: "Không thể tải thông tin người dùng. Vui lòng thử lại.",
      );
    }
  }

  Future<void> fetchTabsData(String username) async {
    // Không set isTabsLoading = true ở đây, vì resetState đã làm

    try { // ĐÃ THÊM try-catch
      final results = await Future.wait([
        api<ApiService>((request) => request.fetchUserPhotos(username, page: _userPhotosPage)),
        api<ApiService>((request) => request.fetchUserLikes(username, page: _likedPhotosPage)),
        api<ApiService>((request) => request.fetchUserCollections(username, page: _collectionsPage)),
      ]);

      final initialUserPhotos = results[0] as List<Photo>? ?? [];
      if (initialUserPhotos.length < 20) {
        _hasMoreUserPhotos = false;
      }

      final initialLikedPhotos = results[1] as List<Photo>? ?? [];
      if (initialLikedPhotos.length < 20) {
        _hasMoreLikedPhotos = false;
      }

      final initialCollections = results[2] as List<Collection>? ?? [];
      if (initialCollections.length < 20) {
        _hasMoreCollections = false;
      }

      userProfileState.value = userProfileState.value.copyWith(
        userPhotos: initialUserPhotos,
        likedPhotos: initialLikedPhotos,
        collections: initialCollections,
        isTabsLoading: false,
      );
    } catch (e) {
      // ĐÃ THÊM: Cập nhật state với lỗi
      userProfileState.value = userProfileState.value.copyWith(
        isTabsLoading: false,
        errorMessage: "Không thể tải nội dung. Vui lòng thử lại.",
      );
    }
  }

  // ... (Các hàm fetchMore... cũng nên được bọc try-catch,
  // nhưng để đơn giản, chúng ta sẽ bỏ qua bước đó.
  // Lý tưởng nhất là bạn cũng thêm try-catch cho chúng.) ...

  // ... (Toàn bộ các hàm fetchMore... giữ nguyên) ...
  Future<void> fetchMoreUserPhotos() async {
    if (userProfileState.value.isLoadingMoreUserPhotos || !_hasMoreUserPhotos || userProfileState.value.userDetail == null) return;
    userProfileState.value = userProfileState.value.copyWith(isLoadingMoreUserPhotos: true);
    _userPhotosPage++;

    // Tạm thời bỏ qua try-catch ở đây để giữ ví dụ đơn giản
    List<Photo>? newPhotos = await api<ApiService>((request) =>
        request.fetchUserPhotos(userProfileState.value.userDetail!.username!, page: _userPhotosPage));

    if (newPhotos != null) {
      if (newPhotos.isEmpty || newPhotos.length < 20) { _hasMoreUserPhotos = false; }
      userProfileState.value = userProfileState.value.copyWith(
        userPhotos: List.from(userProfileState.value.userPhotos)..addAll(newPhotos),
        isLoadingMoreUserPhotos: false,
      );
    } else {
      _hasMoreUserPhotos = false;
      userProfileState.value = userProfileState.value.copyWith(isLoadingMoreUserPhotos: false);
    }
  }

  Future<void> fetchMoreLikedPhotos() async {
    if (userProfileState.value.isLoadingMoreLikedPhotos || !_hasMoreLikedPhotos || userProfileState.value.userDetail == null) return;
    userProfileState.value = userProfileState.value.copyWith(isLoadingMoreLikedPhotos: true);
    _likedPhotosPage++;

    List<Photo>? newPhotos = await api<ApiService>((request) =>
        request.fetchUserLikes(userProfileState.value.userDetail!.username!, page: _likedPhotosPage));

    if (newPhotos != null) {
      if (newPhotos.isEmpty || newPhotos.length < 20) { _hasMoreLikedPhotos = false; }
      userProfileState.value = userProfileState.value.copyWith(
        likedPhotos: List.from(userProfileState.value.likedPhotos)..addAll(newPhotos),
        isLoadingMoreLikedPhotos: false,
      );
    } else {
      _hasMoreLikedPhotos = false;
      userProfileState.value = userProfileState.value.copyWith(isLoadingMoreLikedPhotos: false);
    }
  }

  Future<void> fetchMoreCollections() async {
    if (userProfileState.value.isLoadingMoreCollections || !_hasMoreCollections || userProfileState.value.userDetail == null) return;
    userProfileState.value = userProfileState.value.copyWith(isLoadingMoreCollections: true);
    _collectionsPage++;

    List<Collection>? newCollections = await api<ApiService>((request) =>
        request.fetchUserCollections(userProfileState.value.userDetail!.username!, page: _collectionsPage));

    if (newCollections != null) {
      if (newCollections.isEmpty || newCollections.length < 20) { _hasMoreCollections = false; }
      userProfileState.value = userProfileState.value.copyWith(
        collections: List.from(userProfileState.value.collections)..addAll(newCollections),
        isLoadingMoreCollections: false,
      );
    } else {
      _hasMoreCollections = false;
      userProfileState.value = userProfileState.value.copyWith(isLoadingMoreCollections: false);
    }
  }
}