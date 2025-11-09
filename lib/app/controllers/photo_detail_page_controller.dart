// lib/app/controllers/photo_detail_page_controller.dart

import 'package:flutter/foundation.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../networking/api_service.dart';
import 'controller.dart';
import '../states/photo_detail_state.dart'; // IMPORT STATE MỚI

class PhotoDetailPageController extends Controller {

  // ĐÃ SỬA: Dùng một State Object duy nhất
  final ValueNotifier<PhotoDetailState> photoState =
  ValueNotifier(PhotoDetailState());

  void setupInitial(dynamic data) {
    if (data is Photo) {
      // Set ảnh ban đầu (chưa có EXIF)
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
          hasLoadedDetails: true, // Vẫn set là true để dừng skeleton
          errorMessage: "Không thể tải chi tiết ảnh."
      );
    }
  }
}