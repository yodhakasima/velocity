import 'dart:async';

import 'package:location/location.dart';
import 'package:velocity/user_location.dart';

class LocationService {
  Location location = Location();

  final StreamController<UserLocation> _locationStreamController =
      StreamController<UserLocation>();
  Stream<UserLocation> get locationStream => _locationStreamController.stream;

  LocationService() {
    location.requestPermission().then((permissionStatus) {
      if (permissionStatus == PermissionStatus.granted) {
        location.onLocationChanged.listen((locationData) {
          // ignore: unnecessary_null_comparison
          if (locationData != null) {
            _locationStreamController.add(UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            ));
          }
        });
      }
    });
  }
  // ignore: non_constant_identifier_names

  void dispose() => _locationStreamController.close();
}
