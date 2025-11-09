import 'package:flutter_module_4/app/models/photo.dart';
import 'package:flutter_module_4/app/models/user.dart';
import 'package:nylo_framework/nylo_framework.dart';

class Collection extends Model {
  String? id;
  String? title;
  String? description;
  int? totalPhotos;
  Photo? coverPhoto;
  User? user;

  Collection(
      {this.id,
        this.title,
        this.description,
        this.totalPhotos,
        this.coverPhoto,
        this.user});

  Collection.fromJson(dynamic data) {
    id = data['id'];
    title = data['title'];
    description = data['description'];
    totalPhotos = data['total_photos'];
    if (data['cover_photo'] != null) {
      coverPhoto = Photo.fromJson(data['cover_photo']);
    }
    if (data['user'] != null) {
      user = User.fromJson(data['user']);
    }
  }

  @override
  toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "total_photos": totalPhotos,
    "cover_photo": coverPhoto?.toJson(),
    "user": user?.toJson(),
  };
}