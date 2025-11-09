import 'package:flutter/foundation.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../networking/api_service.dart';
import 'controller.dart';
import '../states/photo_detail_state.dart';

class PhotoDetailPageController extends Controller {

  final ValueNotifier<PhotoDetailState> photoState =
  ValueNotifier(PhotoDetailState());

  void setupInitial(dynamic data) {
    if (data is Photo) {
      photoState.value = photoState.value.copyWith(photo: data);
    }
  }

  Future<void> fetchFullDetails() async {
    final currentPhoto = photoState.value.photo;
    if (currentPhoto?.exif != null) return;
    if (currentPhoto == null || currentPhoto.id == null) return;

    try {
      Photo? fullDetailsPhoto = await api<ApiService>(
              (request) => request.fetchPhotoDetails(currentPhoto.id!));

      if (fullDetailsPhoto != null) {
        photoState.value = photoState.value.copyWith(
          photo: fullDetailsPhoto,
          hasLoadedDetails: true,
        );
      }
    } catch(e) {
      photoState.value = photoState.value.copyWith(
          hasLoadedDetails: true,
          errorMessage: "Không thể tải chi tiết ảnh."
      );
    }
  }
}