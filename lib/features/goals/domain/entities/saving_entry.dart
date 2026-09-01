import 'package:equatable/equatable.dart';

enum SavingMovementType { deposit, withdrawal }

class SavingEntry extends Equatable {
  const SavingEntry({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    this.note,
  });

  final String id;
  final double amount;
  final DateTime date;
  final SavingMovementType type;
  final String? note;

  bool get isDeposit => type == SavingMovementType.deposit;

  SavingEntry copyWith({
    String? id,
    double? amount,
    DateTime? date,
    SavingMovementType? type,
    String? note,
  }) {
    return SavingEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, amount, date, type, note];
}
