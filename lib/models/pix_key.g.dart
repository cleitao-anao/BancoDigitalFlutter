// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pix_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PixKey _$PixKeyFromJson(Map<String, dynamic> json) => PixKey(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  keyType: json['key_type'] as String,
  keyValue: json['key_value'] as String,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PixKeyToJson(PixKey instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'key_type': instance.keyType,
  'key_value': instance.keyValue,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
