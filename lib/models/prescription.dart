import 'package:hive/hive.dart';
import 'package:medimatch/models/medicine.dart';

part 'prescription.g.dart';

@HiveType(typeId: 1)
class Prescription {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String patientName;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final List<Medicine> medicines;

  @HiveField(4)
  final String? doctorName;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String? rawOcrText;

  Prescription({
    required this.id,
    required this.patientName,
    required this.date,
    required this.medicines,
    this.doctorName,
    this.notes,
    this.rawOcrText,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientName: json['patientName'],
      date: DateTime.parse(json['date']),
      medicines: (json['medicines'] as List)
          .map((medicine) => Medicine.fromJson(medicine))
          .toList(),
      doctorName: json['doctorName'],
      notes: json['notes'],
      rawOcrText: json['rawOcrText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'date': date.toIso8601String(),
      'medicines': medicines.map((medicine) => medicine.toJson()).toList(),
      'doctorName': doctorName,
      'notes': notes,
      'rawOcrText': rawOcrText,
    };
  }
}
