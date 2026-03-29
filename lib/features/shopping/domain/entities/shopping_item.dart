import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.expectedPrice,
    this.isBought = false,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      expectedPrice: (json['expectedPrice'] as num).toDouble(),
      isBought: json['isBought'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final double expectedPrice;
  final bool isBought;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expectedPrice': expectedPrice,
      'isBought': isBought,
    };
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    double? expectedPrice,
    bool? isBought,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      expectedPrice: expectedPrice ?? this.expectedPrice,
      isBought: isBought ?? this.isBought,
    );
  }

  @override
  List<Object?> get props => [id, name, expectedPrice, isBought];
}
