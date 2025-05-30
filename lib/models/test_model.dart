import 'package:json_annotation/json_annotation.dart';

part 'test_model.g.dart';

@JsonSerializable()
class TestModel {
  final String id;
  final String name;
  final DateTime createdAt;

  TestModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) => 
      _$TestModelFromJson(json);
      
  Map<String, dynamic> toJson() => _$TestModelToJson(this);
}
