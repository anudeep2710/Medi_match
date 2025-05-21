import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medimatch/models/pharmacy.dart';
import 'package:medimatch/providers/pharmacy_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkLocationAndLoadPharmacies();
      }
    });
  }

  Future<void> _checkLocationAndLoadPharmacies() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final pharmacyProvider = Provider.of<PharmacyProvider>(
        context,
        listen: false,
      );

      final locationService = pharmacyProvider.locationService;

      // Check if location services are enabled
      bool serviceEnabled = await locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          await _showLocationServicesDisabledDialog();
        }
        return;
      }

      // Check permission status
      var permission = await locationService.checkPermission();

      if (permission == LocationPermission.denied) {
        // Show permission explanation dialog
        if (mounted) {
          await _showLocationPermissionDialog();
        }

        // Request permission
        permission = await locationService.requestPermission();

        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location permission is required to find nearby pharmacies',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Show settings dialog
        if (mounted) {
          await _showOpenSettingsDialog();
        }
        return;
      }

      // Try to get current location and find pharmacies
      if (pharmacyProvider.pharmacies.isEmpty) {
        await pharmacyProvider.findNearbyPharmacies();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  // Dialog to explain why we need location permission
  Future<void> _showLocationPermissionDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission'),
          content: const Text(
            'MediMatch needs access to your location to find nearby pharmacies. '
            'Please grant location permission when prompted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Dialog to explain that location services are disabled
  Future<void> _showLocationServicesDisabledDialog() async {
    final pharmacyProvider = Provider.of<PharmacyProvider>(
      context,
      listen: false,
    );

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Location services are disabled. Please enable location services in your device settings to find nearby pharmacies.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await pharmacyProvider.locationService.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // Dialog to guide user to app settings when permissions are permanently denied
  Future<void> _showOpenSettingsDialog() async {
    final pharmacyProvider = Provider.of<PharmacyProvider>(
      context,
      listen: false,
    );

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'Location permission has been permanently denied. Please open app settings and enable location permission to find nearby pharmacies.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await pharmacyProvider.locationService.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _callPharmacy(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not call $phoneNumber'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openMaps(Pharmacy pharmacy) async {
    if (pharmacy.latitude != null && pharmacy.longitude != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${pharmacy.latitude},${pharmacy.longitude}';
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location coordinates not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyProvider = Provider.of<PharmacyProvider>(context);
    final pharmacies = pharmacyProvider.pharmacies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Pharmacies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                pharmacyProvider.isLoading
                    ? null
                    : () => pharmacyProvider.findNearbyPharmacies(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoadingLocation || pharmacyProvider.isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Finding nearby pharmacies...'),
                  ],
                ),
              )
              : pharmacyProvider.currentPosition == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Location not available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Please enable location services to find nearby pharmacies',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _checkLocationAndLoadPharmacies,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Enable Location'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await pharmacyProvider.locationService
                                .openLocationSettings();
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Open Settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : pharmacies.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_pharmacy,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No pharmacies found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        pharmacyProvider.error ??
                            'Try refreshing or check your location',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => pharmacyProvider.findNearbyPharmacies(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: pharmacies.length,
                itemBuilder: (context, index) {
                  final pharmacy = pharmacies[index];
                  return _buildPharmacyCard(pharmacy);
                },
              ),
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pharmacy.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: pharmacy.openNow ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    pharmacy.openNow ? 'Open' : 'Closed',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Distance: ${pharmacy.distance}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (pharmacy.address != null) ...[
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.home, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pharmacy.address!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 8),
                Text(pharmacy.contact, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _callPharmacy(pharmacy.contact),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _openMaps(pharmacy),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Directions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
