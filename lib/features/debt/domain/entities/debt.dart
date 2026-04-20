import 'package:equatable/equatable.dart';

enum DebtRecurrence { once, weekly, monthly, custom } // <-- إضافة custom

class Debt extends Equatable {
  const Debt({
    required this.id,
    required this.name,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.installmentAmount = 0.0,
    this.recurrence = DebtRecurrence.once,
    this.recurrenceValue,
    this.dueDate,
    this.customDates, // <-- إضافة التواريخ المخصصة
    this.autoDeduct = false,
    this.targetWalletId,
    this.categoryId,
    this.lastProcessedDate,
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
      // قراءة التواريخ المخصصة من الـ JSON
      customDates: json['customDates'] != null
          ? (json['customDates'] as List)
                .map((e) => DateTime.parse(e.toString()))
                .toList()
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
  final List<DateTime>? customDates; // <-- المتغير الجديد
  final bool autoDeduct;
  final String? targetWalletId;
  final String? categoryId;
  final DateTime? lastProcessedDate;

  double get remainingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;

  // ==== دالة حساب موعد الاستحقاق القادم ====
  DateTime? get nextDueDate {
    if (isFullyPaid) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (recurrence) {
      case DebtRecurrence.once:
        return dueDate;

      case DebtRecurrence.monthly:
        if (recurrenceValue == null) return null;
        var nextDate = DateTime(today.year, today.month, recurrenceValue!);
        if (nextDate.isBefore(today)) {
          // إذا مر اليوم في هذا الشهر، ننتقل للشهر القادم
          nextDate = DateTime(today.year, today.month + 1, recurrenceValue!);
        }
        return nextDate;

      case DebtRecurrence.weekly:
        if (recurrenceValue == null) return null;
        // حساب الأيام المتبقية حتى اليوم المطلوب في الأسبوع
        var daysToAdd = (recurrenceValue! - today.weekday) % 7;
        if (daysToAdd < 0) daysToAdd += 7;
        return today.add(Duration(days: daysToAdd));

      case DebtRecurrence.custom:
        if (customDates == null || customDates!.isEmpty) return null;
        // ترتيب التواريخ وجلب أول تاريخ لم يمر بعد
        final sortedDates = List<DateTime>.from(customDates!)..sort();
        try {
          return sortedDates.firstWhere(
            (date) =>
                !DateTime(date.year, date.month, date.day).isBefore(today),
          );
        } catch (e) {
          return null; // انتهت كل المواعيد
        }
    }
  }

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
      'customDates': customDates
          ?.map((e) => e.toIso8601String())
          .toList(), // <-- الحفظ
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
    List<DateTime>? customDates,
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
      customDates: customDates ?? this.customDates,
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
    customDates,
    autoDeduct,
    targetWalletId,
    categoryId,
    lastProcessedDate,
  ];
}
