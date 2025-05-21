// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 0;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      name: fields[0] as String,
      dosage: fields[1] as String,
      instructions: fields[2] as String,
      genericName: fields[3] as String?,
      genericPrice: fields[4] as double?,
      brandPrice: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dosage)
      ..writeByte(2)
      ..write(obj.instructions)
      ..writeByte(3)
      ..write(obj.genericName)
      ..writeByte(4)
      ..write(obj.genericPrice)
      ..writeByte(5)
      ..write(obj.brandPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
