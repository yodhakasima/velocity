import 'package:flutter/services.dart';
import 'package:location/location.dart';

class FirsLocation {
  late Location _location;
  bool _serviceEnabled = false;
  PermissionStatus? _grantedPermission;

  // ignore: non_constant_identifier_names
  FirsLocation() {
    _location = Location();
  }

  Future<bool> _checkPermission() async {
    if (await _checkService()) {
      _grantedPermission = await _location.hasPermission();
      if (_grantedPermission == PermissionStatus.denied) {
        _grantedPermission = await _location.requestPermission();
      }
    }

    return _grantedPermission == PermissionStatus.granted;
  }

  Future<bool> _checkService() async {
    try {
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
      }
    } on PlatformException {
      _serviceEnabled = false;
      await _checkService();
    }

    return _serviceEnabled;
  }

  Future<LocationData?> getLocation() async {
    if (await _checkPermission()) {
      final locationData = _location.getLocation();
      return locationData;
    }
    return null;
  }
}
