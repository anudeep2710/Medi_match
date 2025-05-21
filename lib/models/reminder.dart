import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 2)
class Reminder {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicineName;

  @HiveField(2)
  final String time;

  @HiveField(3)
  final String note;

  @HiveField(4)
  final bool isActive;

  @HiveField(5)
  final List<int> daysOfWeek; // 1-7 for Monday-Sunday

  Reminder({
    required this.id,
    required this.medicineName,
    required this.time,
    required this.note,
    this.isActive = true,
    required this.daysOfWeek,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      medicineName: json['medicineName'],
      time: json['time'],
      note: json['note'],
      isActive: json['isActive'] ?? true,
      daysOfWeek: List<int>.from(json['daysOfWeek']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineName': medicineName,
      'time': time,
      'note': note,
      'isActive': isActive,
      'daysOfWeek': daysOfWeek,
    };
  }
}
