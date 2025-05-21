// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pharmacy.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PharmacyAdapter extends TypeAdapter<Pharmacy> {
  @override
  final int typeId = 3;

  @override
  Pharmacy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pharmacy(
      name: fields[0] as String,
      distance: fields[1] as String,
      openNow: fields[2] as bool,
      contact: fields[3] as String,
      latitude: fields[4] as double?,
      longitude: fields[5] as double?,
      address: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Pharmacy obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.distance)
      ..writeByte(2)
      ..write(obj.openNow)
      ..writeByte(3)
      ..write(obj.contact)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PharmacyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
