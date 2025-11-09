// lib/app/controllers/collection_detail_state.dart

import 'package:flutter_module_4/app/models/collection.dart';
import 'package:flutter_module_4/app/models/photo.dart';

class CollectionDetailState {
  final bool isLoading;
  final bool isLoadingMore;
  final Collection? detailedCollection;
  final List<Photo> photos;
  final String? errorMessage;

  CollectionDetailState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.detailedCollection,
    this.photos = const [],
    this.errorMessage,
  });

  CollectionDetailState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    Collection? detailedCollection,
    List<Photo>? photos,
    String? errorMessage,
  }) {
    return CollectionDetailState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      detailedCollection: detailedCollection ?? this.detailedCollection,
      photos: photos ?? this.photos,
      errorMessage: errorMessage,
    );
  }
}