import 'package:nylo_framework/nylo_framework.dart';
class Location extends Model {
  String? city;
  String? country;
  String? name;

  Location({this.city, this.country, this.name});

  Location.fromJson(dynamic data) {
    city = data['city'];
    country = data['country'];
    name = data['name'];
  }

  @override
  toJson() => {
    "city": city,
    "country": country,
    "name": name,
  };

  String? get displayName {
    if (city != null && country != null) return "$city, $country";
    return city ?? country;
  }
}