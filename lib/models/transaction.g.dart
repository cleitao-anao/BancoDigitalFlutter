// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'sender_id',
      'receiver_id',
      'amount',
      'type',
      'status',
      'created_at',
      'updated_at',
    ],
  );
  return Transaction(
    id: json['id'] as String,
    senderId: json['sender_id'] as String,
    receiverId: json['receiver_id'] as String,
    amount: (json['amount'] as num).toDouble(),
    type: json['type'] as String,
    status: json['status'] as String,
    description: json['description'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'receiver_id': instance.receiverId,
      'amount': instance.amount,
      'type': instance.type,
      'status': instance.status,
      if (instance.description case final value?) 'description': value,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
