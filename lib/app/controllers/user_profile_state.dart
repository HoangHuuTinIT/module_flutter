// lib/app/controllers/user_profile_state.dart

import 'package:flutter_module_4/app/models/collection.dart';
import 'package:flutter_module_4/app/models/photo.dart';
import 'package:flutter_module_4/app/models/user_detail.dart';

// Lớp này chứa TOÀN BỘ trạng thái cho trang UserProfile
class UserProfileState {
  final bool isUserLoading;
  final bool isTabsLoading;
  final UserDetail? userDetail;
  final List<Photo> userPhotos;
  final List<Photo> likedPhotos;
  final List<Collection> collections;

  // Trạng thái load-more cho từng tab
  final bool isLoadingMoreUserPhotos;
  final bool isLoadingMoreLikedPhotos;
  final bool isLoadingMoreCollections;
  final String? errorMessage;
  UserProfileState({
    this.isUserLoading = true,
    this.isTabsLoading = true,
    this.userDetail,
    this.userPhotos = const [],
    this.likedPhotos = const [],
    this.collections = const [],
    this.isLoadingMoreUserPhotos = false,
    this.isLoadingMoreLikedPhotos = false,
    this.isLoadingMoreCollections = false,
    this.errorMessage,
  });

  // Hàm reset về trạng thái ban đầu
  UserProfileState reset() {
    return UserProfileState(); // Trả về một state hoàn toàn mới
  }

  // Hàm copyWith để tạo state mới dựa trên state cũ
  UserProfileState copyWith({
    bool? isUserLoading,
    bool? isTabsLoading,
    UserDetail? userDetail,
    List<Photo>? userPhotos,
    List<Photo>? likedPhotos,
    List<Collection>? collections,
    bool? isLoadingMoreUserPhotos,
    bool? isLoadingMoreLikedPhotos,
    bool? isLoadingMoreCollections,
    String? errorMessage,
  }) {
    return UserProfileState(
      isUserLoading: isUserLoading ?? this.isUserLoading,
      isTabsLoading: isTabsLoading ?? this.isTabsLoading,
      userDetail: userDetail ?? this.userDetail,
      userPhotos: userPhotos ?? this.userPhotos,
      likedPhotos: likedPhotos ?? this.likedPhotos,
      collections: collections ?? this.collections,
      isLoadingMoreUserPhotos: isLoadingMoreUserPhotos ?? this.isLoadingMoreUserPhotos,
      isLoadingMoreLikedPhotos: isLoadingMoreLikedPhotos ?? this.isLoadingMoreLikedPhotos,
      isLoadingMoreCollections: isLoadingMoreCollections ?? this.isLoadingMoreCollections,
      errorMessage: errorMessage,
    );
  }
}