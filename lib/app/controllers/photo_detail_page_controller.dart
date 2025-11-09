import 'package:flutter/foundation.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../networking/api_service.dart';
import 'controller.dart';

class PhotoDetailPageController extends Controller {
    final ValueNotifier<Photo?> photoNotifier = ValueNotifier(null);
    final ValueNotifier<bool> hasLoadedDetails = ValueNotifier(false);
    Photo? get photo => photoNotifier.value;
    set photo(Photo? newPhoto) {
      photoNotifier.value = newPhoto;
    }

    void setupInitial(dynamic data) {
      if (data is Photo) {
        if (photo == null) {
          photo = data;
        }
      }
    }

    Future<void> fetchFullDetails() async {
      if (photo?.exif != null) return;

      if (photo == null || photo!.id == null) return;

      try {
        Photo? fullDetailsPhoto = await api<ApiService>((request) => request.fetchPhotoDetails(photo!.id!));
        if (fullDetailsPhoto != null) {
          photo = fullDetailsPhoto;
        }
      } finally {
        hasLoadedDetails.value = true;
      }
    }

} 