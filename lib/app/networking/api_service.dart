import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dio/dio.dart' as dio_instance;
import '../models/collection.dart';
import '../models/photo.dart';
import '../models/photo_response.dart';
import '../models/user_detail.dart';

class ApiService extends NyApiService {
  late final dio_instance.Dio _dio;

  ApiService({BuildContext? buildContext}) : super(buildContext) {
    _dio = dio_instance.Dio(
      dio_instance.BaseOptions(
        baseUrl: getEnv('API_BASE_URL'),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    if (getEnv('APP_DEBUG') == true) {
      _dio.interceptors.add(PrettyDioLogger());
    }
  }

  Future<PhotoResponse?> fetchPhotos({String? url}) async {
    try {
      final dio_instance.Response response;
      if (url != null) {
        response = await _dio.get(url);
      } else {
        response = await _dio.get(
          "/photos",
          queryParameters: {
            "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
            "page": 1,
            "per_page": 20,
          },
        );
      }

      List<Photo> photos =
          List.from(response.data).map((json) => Photo.fromJson(json)).toList();

      String? nextPageUrl;
      final linkHeader = response.headers.value('Link');
      if (linkHeader != null) {
        final links = linkHeader.split(', ');
        try {
          final nextLink = links.firstWhere(
            (link) => link.contains('rel="next"'),
          );
          nextPageUrl = nextLink.substring(1, nextLink.indexOf('>'));
        } catch (_) {
          nextPageUrl = null;
        }
      }

      return PhotoResponse(photos: photos, nextPageUrl: nextPageUrl);
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }

  Future<Photo?> fetchPhotoDetails(String photoId) async {
    try {
      final response = await _dio.get(
        "/photos/$photoId",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
        },
      );
      return Photo.fromJson(response.data);
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }
  Future<UserDetail?> fetchUserDetails(String username) async {
    try {
      final response = await _dio.get(
        "/users/$username",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
        },
      );
      return UserDetail.fromJson(response.data);
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }
  Future<List<Photo>?> fetchUserPhotos(String username, {int page = 1}) async {
    try {
      final response = await _dio.get(
        "/users/$username/photos",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
          "page": page,
          "per_page": 20,
        },
      );
      return List.from(response.data).map((json) => Photo.fromJson(json)).toList();
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }

  Future<List<Photo>?> fetchUserLikes(String username, {int page = 1}) async {
    try {
      final response = await _dio.get(
        "/users/$username/likes",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
          "page": page,
          "per_page": 20,
        },
      );
      return List.from(response.data).map((json) => Photo.fromJson(json)).toList();
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }

  Future<List<Collection>?> fetchUserCollections(String username, {int page = 1}) async {
    try {
      final response = await _dio.get(
        "/users/$username/collections",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
          "page": page,
          "per_page": 20,
        },
      );
      return List.from(response.data).map((json) => Collection.fromJson(json)).toList();
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }
  Future<List<Collection>?> fetchAllCollections({int page = 1}) async {
    try {
      final response = await _dio.get(
        "/collections",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
          "page": page,
          "per_page": 20,
        },
      );
      return List.from(response.data)
          .map((json) => Collection.fromJson(json))
          .toList();
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }
  Future<List<Photo>?> fetchPhotosForCollection(String collectionId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        "/collections/$collectionId/photos",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
          "page": page,
          "per_page": 20,
        },
      );
      return List.from(response.data).map((json) => Photo.fromJson(json)).toList();
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }
  Future<Collection?> fetchCollectionDetails(String collectionId) async {
    try {
      final response = await _dio.get(
        "/collections/$collectionId",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
        },
      );
      return Collection.fromJson(response.data);
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }
}
