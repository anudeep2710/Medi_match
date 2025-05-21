// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrescriptionAdapter extends TypeAdapter<Prescription> {
  @override
  final int typeId = 1;

  @override
  Prescription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Prescription(
      id: fields[0] as String,
      patientName: fields[1] as String,
      date: fields[2] as DateTime,
      medicines: (fields[3] as List).cast<Medicine>(),
      doctorName: fields[4] as String?,
      notes: fields[5] as String?,
      rawOcrText: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Prescription obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientName)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.medicines)
      ..writeByte(4)
      ..write(obj.doctorName)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.rawOcrText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrescriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
