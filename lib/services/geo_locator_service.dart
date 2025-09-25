import 'package:geolocator/geolocator.dart';
import 'package:hidden_gem/constants.dart';

// https://github.com/Mauro124/flutter_map_osrm/

class GeolocatorService {
  static Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        Geolocator.openAppSettings();
        return false;
      }
    }

    return true;
  }

  static Future<Position> getCurrentLocation({LocationAccuracy accuracy = LocationAccuracy.high}) async {
    if (!await checkPermission()) {
      throw Exception("Location services are disabled");
    }

    Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(
      accuracy: accuracy,
      distanceFilter: 10
    ));
    return position;
  }

  static Future<Position?> getLastLocation() async {
    if (!await checkPermission()) {
      throw Exception("Location services are disabled");
    }

    Position? position = await Geolocator.getLastKnownPosition();
    return position;
  }
}