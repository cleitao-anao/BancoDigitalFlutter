// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestModel _$TestModelFromJson(Map<String, dynamic> json) => TestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TestModelToJson(TestModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
    };
