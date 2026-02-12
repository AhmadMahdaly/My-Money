import 'package:flutter/material.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';

enum RecurrenceType { none, weekly, monthly }

class TransactionCategory {
  // خصم تلقائي أم انتظار تأكيد

  TransactionCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.type,
    this.isRecurring = false,
    this.fixedAmount,
    this.recurrenceType = RecurrenceType.none,
    this.dayOfMonth,
    this.daysOfWeek,
    this.autoDeduct = false,
    this.targetWalletId,
  });

  factory TransactionCategory.fromJson(Map<String, dynamic> json) =>
      TransactionCategory(
        id: json['id'].toString(),
        name: json['name'].toString(),
        colorValue: json['colorValue'] as int,
        type: TransactionType.values.firstWhere(
          (e) => e.toString() == json['type'],
          orElse: () => TransactionType.expense,
        ),
        isRecurring: json['isRecurring'] as bool? ?? false,
        fixedAmount: (json['fixedAmount'] as num?)?.toDouble(),
        recurrenceType: RecurrenceType.values.firstWhere(
          (e) => e.name == (json['recurrenceType'] ?? 'none'),
          orElse: () => RecurrenceType.none,
        ),
        dayOfMonth: json['dayOfMonth'] as int?,
        daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)?.cast<int>(),
        autoDeduct: json['autoDeduct'] as bool? ?? false,
      );
  final String id;
  final String name;
  final int colorValue;
  final TransactionType type;

  final String? targetWalletId;
  final bool isRecurring;
  final double? fixedAmount;
  final RecurrenceType recurrenceType;
  final int? dayOfMonth; // ليوم محدد في الشهر (مثل الإيجار)
  final List<int>? daysOfWeek; // لأيام الأسبوع (1 = الاثنين، 7 = الأحد)
  final bool autoDeduct;

  // هذا هو الـ Getter الذي كان مفقوداً ويسبب الخطأ
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
    'type': type.toString(),
    'isRecurring': isRecurring,
    'fixedAmount': fixedAmount,
    'recurrenceType': recurrenceType.name,
    'dayOfMonth': dayOfMonth,
    'daysOfWeek': daysOfWeek,
    'autoDeduct': autoDeduct,
  };
}
