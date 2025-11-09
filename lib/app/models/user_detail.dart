import 'package:flutter_module_4/app/models/user_profile_image.dart';
import 'package:nylo_framework/nylo_framework.dart';

class UserDetail extends Model {
  String? id;
  String? username;
  String? name;
  String? bio;
  String? location;
  int? totalLikes;
  int? totalPhotos;
  int? totalCollections;
  UserProfileImage? profileImage;

  UserDetail({
    this.id,
    this.username,
    this.name,
    this.bio,
    this.location,
    this.totalLikes,
    this.totalPhotos,
    this.totalCollections,
    this.profileImage,
  });

  UserDetail.fromJson(dynamic data) {
    id = data['id'];
    username = data['username'];
    name = data['name'];
    bio = data['bio'];
    location = data['location'];
    totalLikes = data['total_likes'];
    totalPhotos = data['total_photos'];
    totalCollections = data['total_collections'];
    if (data['profile_image'] != null) {
      profileImage = UserProfileImage.fromJson(data['profile_image']);
    }
  }

  @override
  toJson() => {
    "id": id,
    "username": username,
    "name": name,
    "bio": bio,
    "location": location,
    "total_likes": totalLikes,
    "total_photos": totalPhotos,
    "total_collections": totalCollections,
    "profile_image": profileImage?.toJson(),
  };
}