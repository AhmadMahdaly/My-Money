enum TransactionType { income, expense }

class Transaction {
  Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.type,
    this.note,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'].toString(),
    amount: json['amount'] as double,
    categoryId: json['categoryId'].toString(),
    date: DateTime.parse(json['date'].toString()),
    note: json['note'].toString(),
    type: TransactionType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
  );
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? note;
  final TransactionType type;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'categoryId': categoryId,
    'date': date.toIso8601String(),
    'note': note,
    'type': type.toString(),
  };
}
