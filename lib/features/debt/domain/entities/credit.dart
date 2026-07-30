import 'package:equatable/equatable.dart';

enum CreditRecurrence { once, weekly, monthly, custom }

class Credit extends Equatable {
  const Credit({
    required this.id,
    required this.name,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.installmentAmount = 0.0,
    this.recurrence = CreditRecurrence.once,
    this.recurrenceValue,
    this.dueDate,
    this.customDates,
    this.autoDeduct = false,
    this.targetWalletId,
    this.categoryId,
    this.lastProcessedDate,
  });

  factory Credit.fromJson(Map<String, dynamic> json) {
    return Credit(
      id: json['id'] as String,
      name: json['name'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      installmentAmount: (json['installmentAmount'] as num?)?.toDouble() ?? 0.0,
      recurrence: CreditRecurrence.values.firstWhere(
        (e) => e.name == json['recurrence'],
        orElse: () => CreditRecurrence.once,
      ),
      recurrenceValue: json['recurrenceValue'] as int?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
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
  final double paidAmount; // هنا تعني "المبلغ المُحصّل"
  final double installmentAmount;
  final CreditRecurrence recurrence;
  final int? recurrenceValue;
  final DateTime? dueDate;
  final List<DateTime>? customDates;
  final bool autoDeduct; // هنا تعني تحصيل تلقائي
  final String? targetWalletId;
  final String? categoryId;
  final DateTime? lastProcessedDate;

  double get remainingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;

  DateTime? get nextDueDate {
    if (isFullyPaid) return null;

    var installmentsPaid = 0;
    if (installmentAmount > 0) {
      installmentsPaid = (paidAmount / installmentAmount).floor();
    }

    final now = DateTime.now();

    final startDate =
        dueDate ??
        (customDates != null && customDates!.isNotEmpty
            ? customDates!.first
            : DateTime.now());

    switch (recurrence) {
      case CreditRecurrence.once:
        return paidAmount >= totalAmount ? null : dueDate;

      case CreditRecurrence.monthly:
        if (recurrenceValue == null) return null;

        var nextCandidate = DateTime(
          startDate.year,
          startDate.month + installmentsPaid,
          recurrenceValue!,
        );

        if (nextCandidate.isBefore(DateTime(now.year, now.month, now.day))) {
          nextCandidate = DateTime(
            nextCandidate.year,
            nextCandidate.month + 1,
            recurrenceValue!,
          );
        }
        return nextCandidate;

      case CreditRecurrence.weekly:
        if (recurrenceValue == null) return null;

        var nextCandidate = startDate.add(
          Duration(days: 7 * installmentsPaid),
        );

        var daysToAdd = (recurrenceValue! - nextCandidate.weekday) % 7;
        if (daysToAdd < 0) daysToAdd += 7;
        nextCandidate = nextCandidate.add(Duration(days: daysToAdd));

        while (nextCandidate.isBefore(DateTime(now.year, now.month, now.day))) {
          nextCandidate = nextCandidate.add(const Duration(days: 7));
        }
        return nextCandidate;

      case CreditRecurrence.custom:
        if (customDates == null || customDates!.isEmpty) return null;
        final sortedDates = List<DateTime>.from(customDates!)..sort();

        if (installmentsPaid < sortedDates.length) {
          final candidate = sortedDates[installmentsPaid];

          if (candidate.isBefore(DateTime(now.year, now.month, now.day))) {
            try {
              return sortedDates.firstWhere(
                (d) => !d.isBefore(DateTime(now.year, now.month, now.day)),
              );
            } catch (e) {
              return null;
            }
          }
          return candidate;
        }
        return null;
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
      'customDates': customDates?.map((e) => e.toIso8601String()).toList(),
      'autoDeduct': autoDeduct,
      'targetWalletId': targetWalletId,
      'categoryId': categoryId,
      'lastProcessedDate': lastProcessedDate?.toIso8601String(),
    };
  }

  Credit copyWith({
    String? id,
    String? name,
    double? totalAmount,
    double? paidAmount,
    double? installmentAmount,
    CreditRecurrence? recurrence,
    int? recurrenceValue,
    DateTime? dueDate,
    List<DateTime>? customDates,
    bool? autoDeduct,
    String? targetWalletId,
    String? categoryId,
    DateTime? lastProcessedDate,
  }) {
    return Credit(
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
