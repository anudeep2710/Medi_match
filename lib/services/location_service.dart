import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Open app settings to allow the user to enable location permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // Open location settings to allow the user to enable location services
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Get current location with detailed error handling
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check permission status
      LocationPermission permission = await checkPermission();

      // If permission is denied, request it
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied, requesting permission...');
        permission = await requestPermission();

        // If still denied after request, return null
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied after request');
          return null;
        }
      }

      // If permission is permanently denied, return null
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied');
        return null;
      }

      // When we reach here, permissions are granted and we can get the location
      debugPrint('Getting current location...');
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // Get address from coordinates
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }

  // Calculate distance between two coordinates in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert meters to kilometers
  }
}
