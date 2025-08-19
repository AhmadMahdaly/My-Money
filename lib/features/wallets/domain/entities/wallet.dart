import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  const Wallet({
    required this.id,
    required this.name,
    required this.balance,
    this.isMain = false,
  });
  final String id;
  final String name;
  final double balance;
  final bool isMain;

  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    bool? isMain,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      isMain: isMain ?? this.isMain,
    );
  }

  @override
  List<Object?> get props => [id, name, balance, isMain];
}
