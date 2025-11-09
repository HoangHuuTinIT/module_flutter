// lib/app/controllers/photo_detail_state.dart

import 'package:flutter_module_4/app/models/photo.dart';

class PhotoDetailState {
  final Photo? photo; // Sẽ chứa cả initial và full detail photo
  final bool hasLoadedDetails; // Dùng cho AnimatedSwitcher
  final String? errorMessage;

  PhotoDetailState({
    this.photo,
    this.hasLoadedDetails = false,
    this.errorMessage,
  });

  PhotoDetailState copyWith({
    Photo? photo,
    bool? hasLoadedDetails,
    String? errorMessage,
  }) {
    return PhotoDetailState(
      photo: photo ?? this.photo,
      hasLoadedDetails: hasLoadedDetails ?? this.hasLoadedDetails,
      errorMessage: errorMessage,
    );
  }
}