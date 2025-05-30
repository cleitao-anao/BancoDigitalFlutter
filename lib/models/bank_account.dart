class BankAccount {
  final String id;
  final String userId;
  final String accountNumber;
  final String branch;
  final String accountType; // 'CHECKING' or 'SAVINGS'
  final double balance;
  final String status; // 'ACTIVE', 'BLOCKED', 'CLOSED'
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccount({
    required this.id,
    required this.userId,
    required this.accountNumber,
    this.branch = '0001',
    required this.accountType,
    this.balance = 0.0,
    this.status = 'ACTIVE',
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountNumber: json['account_number'] as String,
      branch: json['branch'] as String? ?? '0001',
      accountType: json['account_type'] as String,
      balance: (json['balance'] as num).toDouble(),
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'account_number': accountNumber,
        'branch': branch,
        'account_type': accountType,
        'balance': balance,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  BankAccount copyWith({
    String? id,
    String? userId,
    String? accountNumber,
    String? branch,
    String? accountType,
    double? balance,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountNumber: accountNumber ?? this.accountNumber,
      branch: branch ?? this.branch,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
