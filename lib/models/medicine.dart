import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String dosage;

  @HiveField(2)
  final String instructions;

  @HiveField(3)
  final String? genericName;

  @HiveField(4)
  final double? genericPrice;

  @HiveField(5)
  final double? brandPrice;

  Medicine({
    required this.name,
    required this.dosage,
    required this.instructions,
    this.genericName,
    this.genericPrice,
    this.brandPrice,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      dosage: json['dosage'],
      instructions: json['instructions'],
      genericName: json['generic'],
      genericPrice: json['genericPrice'] != null ? double.parse(json['genericPrice'].toString()) : null,
      brandPrice: json['brandPrice'] != null ? double.parse(json['brandPrice'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'generic': genericName,
      'genericPrice': genericPrice,
      'brandPrice': brandPrice,
    };
  }
}
