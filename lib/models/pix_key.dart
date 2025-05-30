import 'package:json_annotation/json_annotation.dart';

part 'pix_key.g.dart';

@JsonSerializable()
class PixKey {
  final String id;
  final String userId;
  final String keyType; // CPF, Email, Telefone, Chave Aleatória
  final String keyValue;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PixKey({
    required this.id,
    required this.userId,
    required this.keyType,
    required this.keyValue,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PixKey.fromJson(Map<String, dynamic> json) => _$PixKeyFromJson(json);
  Map<String, dynamic> toJson() => _$PixKeyToJson(this);

  PixKey copyWith({
    String? id,
    String? userId,
    String? keyType,
    String? keyValue,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PixKey(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      keyType: keyType ?? this.keyType,
      keyValue: keyValue ?? this.keyValue,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
