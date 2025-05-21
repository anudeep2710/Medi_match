import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medimatch/models/pharmacy.dart';
import 'package:medimatch/services/hive_service.dart';
import 'package:medimatch/services/location_service.dart';
import 'package:medimatch/services/map_service.dart';

class PharmacyProvider extends ChangeNotifier {
  final HiveService _hiveService;
  final LocationService _locationService;
  final MapService _mapService;

  List<Pharmacy> _pharmacies = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  PharmacyProvider(this._hiveService, this._locationService, this._mapService) {
    _loadPharmacies();
    _getCurrentLocation();
  }

  List<Pharmacy> get pharmacies => _pharmacies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  LocationService get locationService => _locationService;

  Future<void> _loadPharmacies() async {
    _setLoading(true);
    try {
      _pharmacies = _hiveService.getAllPharmacies();
      _setError(null);
    } catch (e) {
      _setError('Failed to load pharmacies: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _getCurrentLocation() async {
    _setLoading(true);
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      _setError(null);
    } catch (e) {
      _setError('Failed to get current location: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> findNearbyPharmacies() async {
    _setLoading(true);
    try {
      if (_currentPosition == null) {
        await _getCurrentLocation();

        if (_currentPosition == null) {
          _setError(
            'Location is not available. Please enable location services and try again.',
          );
          return;
        }
      }

      try {
        final nearbyPharmacies = await _mapService.findNearbyPharmacies(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        if (nearbyPharmacies.isNotEmpty) {
          _pharmacies = nearbyPharmacies;
          await _hiveService.savePharmacies(nearbyPharmacies);
          _setError(null);
        } else {
          _setError(
            'No pharmacies found in your area. Please try again later.',
          );
        }
      } catch (apiError) {
        debugPrint('API Error: $apiError');
        _setError(
          'Failed to fetch pharmacy data from the server: ${apiError.toString().replaceAll('Exception: ', '')}',
        );
      }
    } catch (e) {
      _setError('Failed to find nearby pharmacies: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      return await _locationService.getAddressFromCoordinates(
        latitude,
        longitude,
      );
    } catch (e) {
      _setError('Failed to get address: $e');
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
