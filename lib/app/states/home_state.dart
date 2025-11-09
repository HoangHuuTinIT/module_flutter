// lib/app/controllers/home_state.dart

import 'package:flutter_module_4/app/models/photo.dart';

class HomeState {
  final List<Photo> photos;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;

  HomeState({
    this.photos = const [],
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  HomeState copyWith({
    List<Photo>? photos,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return HomeState(
      photos: photos ?? this.photos,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }
}