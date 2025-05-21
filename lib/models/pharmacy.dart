import 'package:hive/hive.dart';

part 'pharmacy.g.dart';

@HiveType(typeId: 3)
class Pharmacy {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String distance;

  @HiveField(2)
  final bool openNow;

  @HiveField(3)
  final String contact;

  @HiveField(4)
  final double? latitude;

  @HiveField(5)
  final double? longitude;

  @HiveField(6)
  final String? address;

  Pharmacy({
    required this.name,
    required this.distance,
    required this.openNow,
    required this.contact,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      name: json['name'],
      distance: json['distance'],
      openNow: json['openNow'],
      contact: json['contact'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'distance': distance,
      'openNow': openNow,
      'contact': contact,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
