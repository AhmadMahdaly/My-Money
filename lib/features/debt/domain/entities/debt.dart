import 'package:equatable/equatable.dart';

enum DebtRecurrence { once, weekly, monthly }

class Debt extends Equatable {
  const Debt({
    required this.id,
    required this.name,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.installmentAmount = 0.0, // <-- قيمة القسط
    this.recurrence = DebtRecurrence.once,
    this.recurrenceValue,
    this.dueDate,
    this.autoDeduct = false,
    this.targetWalletId,
    this.categoryId, // <-- الفئة التي سيسجل تحتها القسط في المعاملات
    this.lastProcessedDate, // <-- لتتبع آخر مرة تم الدفع فيها
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] as String,
      name: json['name'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      installmentAmount: (json['installmentAmount'] as num?)?.toDouble() ?? 0.0,
      recurrence: DebtRecurrence.values.firstWhere(
        (e) => e.name == json['recurrence'],
        orElse: () => DebtRecurrence.once,
      ),
      recurrenceValue: json['recurrenceValue'] as int?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      autoDeduct: json['autoDeduct'] as bool? ?? false,
      targetWalletId: json['targetWalletId'] as String?,
      categoryId: json['categoryId'] as String?,
      lastProcessedDate: json['lastProcessedDate'] != null
          ? DateTime.parse(json['lastProcessedDate'] as String)
          : null,
    );
  }

  final String id;
  final String name;
  final double totalAmount;
  final double paidAmount;
  final double installmentAmount;
  final DebtRecurrence recurrence;
  final int? recurrenceValue;
  final DateTime? dueDate;
  final bool autoDeduct;
  final String? targetWalletId;
  final String? categoryId;
  final DateTime? lastProcessedDate;

  double get remainingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'installmentAmount': installmentAmount,
      'recurrence': recurrence.name,
      'recurrenceValue': recurrenceValue,
      'dueDate': dueDate?.toIso8601String(),
      'autoDeduct': autoDeduct,
      'targetWalletId': targetWalletId,
      'categoryId': categoryId,
      'lastProcessedDate': lastProcessedDate?.toIso8601String(),
    };
  }

  Debt copyWith({
    String? id,
    String? name,
    double? totalAmount,
    double? paidAmount,
    double? installmentAmount,
    DebtRecurrence? recurrence,
    int? recurrenceValue,
    DateTime? dueDate,
    bool? autoDeduct,
    String? targetWalletId,
    String? categoryId,
    DateTime? lastProcessedDate,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      recurrence: recurrence ?? this.recurrence,
      recurrenceValue: recurrenceValue ?? this.recurrenceValue,
      dueDate: dueDate ?? this.dueDate,
      autoDeduct: autoDeduct ?? this.autoDeduct,
      targetWalletId: targetWalletId ?? this.targetWalletId,
      categoryId: categoryId ?? this.categoryId,
      lastProcessedDate: lastProcessedDate ?? this.lastProcessedDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    totalAmount,
    paidAmount,
    installmentAmount,
    recurrence,
    recurrenceValue,
    dueDate,
    autoDeduct,
    targetWalletId,
    categoryId,
    lastProcessedDate,
  ];
}
