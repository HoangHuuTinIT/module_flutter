import '../app/controllers/collection_detail_controller.dart';
import '../app/controllers/collections_controller.dart';
import '../app/controllers/user_profile_controller.dart';
import '../app/models/location.dart';
import '/app/controllers/home_controller.dart';
import '/app/controllers/photo_detail_page_controller.dart';
import '/app/models/photo.dart';
import '/app/models/user.dart';
import '/app/networking/api_service.dart';

final Map<Type, dynamic> modelDecoders = {
  User: (data) => User.fromJson(data),
  List<User>: (data) =>
      List.from(data).map((json) => User.fromJson(json)).toList(),

  // Thêm các model mới vào đây
  Photo: (data) => Photo.fromJson(data),
  List<Photo>: (data) =>
      List.from(data).map((json) => Photo.fromJson(json)).toList(),

  Location: (data) => Location.fromJson(data),
  List<Location>: (data) =>
      List.from(data).map((json) => Location.fromJson(json)).toList(),
};


final Map<Type, dynamic> apiDecoders = {
  ApiService: () => ApiService(),
};

final Map<Type, dynamic> controllers = {
  HomeController: () => HomeController.instance,
  PhotoDetailPageController: () => PhotoDetailPageController(),
  UserProfileController: () => UserProfileController.instance,
  CollectionsController: () => CollectionsController.instance,
  CollectionDetailController: () => CollectionDetailController(),
};
