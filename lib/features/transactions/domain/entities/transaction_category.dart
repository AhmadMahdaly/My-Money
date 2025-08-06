import 'package:flutter/material.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';

class TransactionCategory {
  TransactionCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.type,
  });

  factory TransactionCategory.fromJson(Map<String, dynamic> json) =>
      TransactionCategory(
        id: json['id'].toString(),
        name: json['name'].toString(),
        colorValue: json['colorValue'] as int,
        type: TransactionType.values.firstWhere(
          (e) => e.toString() == json['type'],
        ),
      );
  final String id;
  final String name;
  final int colorValue;
  final TransactionType type;

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
    'type': type.toString(),
  };
}
