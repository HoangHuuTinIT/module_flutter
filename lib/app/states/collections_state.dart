// lib/app/controllers/collections_state.dart

import 'package:flutter_module_4/app/models/collection.dart';

class CollectionsState {
  final List<Collection> collections;
  final bool isLoading; // Loading ban đầu
  final bool isLoadingMore;
  final String? errorMessage;

  CollectionsState({
    this.collections = const [],
    this.isLoading = true, // Mặc định là true khi mới vào
    this.isLoadingMore = false,
    this.errorMessage,
  });

  CollectionsState copyWith({
    List<Collection>? collections,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return CollectionsState(
      collections: collections ?? this.collections,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}