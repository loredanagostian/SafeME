// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 0;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      email: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      phoneNumber: fields[3] as String,
      imageURL: fields[4] as String,
      emergencyGroup: (fields[6] as List).cast<String>(),
      emergencySMS: fields[5] as String,
      trackingSMS: fields[7] as String,
      friends: (fields[8] as List).cast<String>(),
      trackMeNow: fields[9] as bool,
      friendsRequest: (fields[10] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.imageURL)
      ..writeByte(5)
      ..write(obj.emergencySMS)
      ..writeByte(6)
      ..write(obj.emergencyGroup)
      ..writeByte(7)
      ..write(obj.trackingSMS)
      ..writeByte(8)
      ..write(obj.friends)
      ..writeByte(9)
      ..write(obj.trackMeNow)
      ..writeByte(10)
      ..write(obj.friendsRequest);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
