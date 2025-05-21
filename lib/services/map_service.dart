import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:medimatch/models/pharmacy.dart';

class MapService {
  // MapMyIndia API credentials
  static const String mapApiKey = 'bf55a9999153ee7da291be2ff6a780df';
  static const String clientId =
      '96dHZVzsAuvYNaw2z8MnymW3G8M3I_fyhDapdQ6TUgVqGdmtU2fk7pN1g5CnoklxyhazbLT0EweraAsx3beeiw==';
  static const String clientSecret =
      'lrFxI-iSEg9oh-xXEjRaoJoz8uudCh2N8FNrxdH1ap4c6QlA34vN_-1f7JcK--GwPm2pPw09wTiSV915xv65MzXmw4zoRBEu';

  // Base URLs for MapMyIndia API
  static const String nearbySearchUrl =
      'https://atlas.mapmyindia.com/api/places/nearby/json';
  static const String authUrl =
      'https://outpost.mapmyindia.com/api/security/oauth/token';

  // Find nearby pharmacies using MapMyIndia API
  Future<List<Pharmacy>> findNearbyPharmacies(
    double latitude,
    double longitude,
  ) async {
    try {
      debugPrint('Finding pharmacies near: $latitude, $longitude');

      // Get access token using OAuth
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception('Failed to get access token');
      }

      // Create the base URL
      String url =
          '$nearbySearchUrl?keywords=pharmacy&refLocation=$latitude,$longitude';

      debugPrint('Calling MapMyIndia API: $url');

      // Try different authentication methods
      Map<String, String> headers;

      // First try with OAuth token
      if (token != mapApiKey) {
        headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };
      } else {
        // If we're using the API key directly, use it as a query parameter
        url = '$url&key=$token';
        headers = {'Content-Type': 'application/json'};
      }

      debugPrint('Using URL: $url');
      debugPrint('Using headers: $headers');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(
            const Duration(seconds: 15),
          ); // Add timeout to prevent hanging

      debugPrint('API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('API Response data: ${data.keys}');

        if (data['suggestedLocations'] != null) {
          final List<dynamic> locations = data['suggestedLocations'];
          debugPrint('Found ${locations.length} pharmacies from API');

          final pharmacies =
              locations.map((location) {
                // Extract pharmacy details
                final String name =
                    location['placeAddress'] ?? 'Unknown Pharmacy';
                final String address = location['placeName'] ?? '';
                final String distance = _formatDistance(
                  location['distance'] ?? 0,
                );
                final String contact =
                    location['phoneNumber'] ?? 'Not available';
                final double? lat = location['latitude'];
                final double? lng = location['longitude'];

                // Create pharmacy object
                return Pharmacy(
                  name: name,
                  distance: distance,
                  openNow:
                      true, // Assuming open by default as API doesn't provide this info
                  contact: contact,
                  latitude: lat,
                  longitude: lng,
                  address: address,
                );
              }).toList();

          return pharmacies;
        } else {
          throw Exception('No pharmacy locations found in API response');
        }
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error finding nearby pharmacies: $e');
      // Instead of returning mock data, rethrow the exception
      // so the UI can show an appropriate error message
      rethrow;
    }
  }

  // These methods are used in the mock data generation
  // and would be used in the production API implementation

  // Format distance to readable format
  String _formatDistance(dynamic distance) {
    // This is actually used in the mock data generation
    if (distance is int || distance is double) {
      if (distance < 1000) {
        return '$distance m';
      } else {
        final km = (distance / 1000).toStringAsFixed(1);
        return '$km km';
      }
    }
    return 'Unknown distance';
  }

  // Get access token for MapMyIndia API using OAuth
  Future<String?> _getAccessToken() async {
    try {
      debugPrint('Getting OAuth access token for MapMyIndia API');

      // OAuth implementation for MapMyIndia
      final response = await http
          .post(
            Uri.parse(authUrl),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'grant_type': 'client_credentials',
              'client_id': clientId,
              'client_secret': clientSecret,
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('OAuth response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        if (accessToken != null) {
          debugPrint('Got access token successfully');
          return accessToken;
        } else {
          debugPrint('Access token not found in response: ${response.body}');
          return null;
        }
      } else {
        debugPrint(
          'Failed to get access token: ${response.statusCode} - ${response.body}',
        );

        // As a fallback, try using the API key directly
        debugPrint('Trying to use API key directly as a fallback');
        return mapApiKey;
      }
    } catch (e) {
      debugPrint('Error getting access token: $e');

      // As a fallback, try using the API key directly
      debugPrint('Trying to use API key directly as a fallback after error');
      return mapApiKey;
    }
  }
}
