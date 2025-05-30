import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

/// Representa uma transação financeira no sistema
@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: true,
  createToJson: true,
)
class Transaction {
  /// ID único da transação
  @JsonKey(name: 'id', required: true)
  final String id;

  /// ID do usuário remetente
  @JsonKey(name: 'sender_id', required: true)
  final String senderId;

  /// ID do usuário destinatário
  @JsonKey(name: 'receiver_id', required: true)
  final String receiverId;

  /// Valor da transação
  @JsonKey(name: 'amount', required: true)
  final double amount;

  /// Tipo de transação (PIX, TED, DOC, etc.)
  @JsonKey(name: 'type', required: true)
  final String type;

  /// Status da transação (PENDING, COMPLETED, FAILED, etc.)
  @JsonKey(name: 'status', required: true)
  final String status;

  /// Descrição opcional da transação
  @JsonKey(name: 'description')
  final String? description;

  /// Data de criação da transação
  @JsonKey(name: 'created_at', required: true)
  final DateTime createdAt;

  /// Data da última atualização da transação
  @JsonKey(name: 'updated_at', required: true)
  final DateTime updatedAt;

  /// Construtor da classe Transaction
  Transaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma instância de Transaction a partir de um mapa JSON
  factory Transaction.fromJson(Map<String, dynamic> json) => 
      _$TransactionFromJson(json);

  /// Converte a instância de Transaction para um mapa JSON
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  /// Cria uma cópia da transação com os campos atualizados
  Transaction copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    double? amount,
    String? type,
    String? status,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, senderId: $senderId, receiverId: $receiverId, '
        'amount: $amount, type: $type, status: $status, description: $description, '
        'createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          senderId == other.senderId &&
          receiverId == other.receiverId &&
          amount == other.amount &&
          type == other.type &&
          status == other.status &&
          description == other.description &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      senderId.hashCode ^
      receiverId.hashCode ^
      amount.hashCode ^
      type.hashCode ^
      status.hashCode ^
      description.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
