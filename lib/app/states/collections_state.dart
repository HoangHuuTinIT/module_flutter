import 'package:flutter_module_4/app/models/collection.dart';

class CollectionsState {
  final List<Collection> collections;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  CollectionsState({
    this.collections = const [],
    this.isLoading = true,
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