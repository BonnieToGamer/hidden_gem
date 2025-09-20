import 'package:geolocator/geolocator.dart';

// https://github.com/Mauro124/flutter_map_osrm/

class GeolocatorService {
  static Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return false;
      }
    }

    return true;
  }

  static Future<Position> getCurrentLocation(LocationAccuracy accuracy) async {
    Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(
      accuracy: accuracy,
      distanceFilter: 10
    ));
    return position;
  }

  static Future<Position?> getLastLocation() async {
    Position? position = await Geolocator.getLastKnownPosition();
    return position;
  }
}