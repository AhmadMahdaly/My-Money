import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.type,
    required this.walletId,
    this.note,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      type: TransactionType.values.byName(json['type'] as String),
      walletId: json['walletId'] as String? ?? 'default_wallet',
    );
  }
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? note;
  final TransactionType type;
  final String walletId;

  @override
  List<Object?> get props => [
    id,
    amount,
    categoryId,
    date,
    note,
    type,
    walletId,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'type': type.name,
      'walletId': walletId,
    };
  }
}
