part of 'shopping_cubit.dart';

class ShoppingState extends Equatable {
  const ShoppingState({
    this.items = const [],
    this.categoryOrder = const [],
  });

  final List<ShoppingItem> items;
  final List<String> categoryOrder;

  ShoppingState copyWith({
    List<ShoppingItem>? items,
    List<String>? categoryOrder,
  }) {
    return ShoppingState(
      items: items ?? this.items,
      categoryOrder: categoryOrder ?? this.categoryOrder,
    );
  }

  @override
  List<Object> get props => [items, categoryOrder];
}
