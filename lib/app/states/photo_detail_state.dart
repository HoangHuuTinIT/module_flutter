import 'package:flutter_module_4/app/models/photo.dart';

class PhotoDetailState {
  final Photo? photo;
  final bool hasLoadedDetails;
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