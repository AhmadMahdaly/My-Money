part of 'shopping_cubit.dart';

class ShoppingState extends Equatable {
  const ShoppingState({this.items = const []});
  final List<ShoppingItem> items;

  ShoppingState copyWith({List<ShoppingItem>? items}) {
    return ShoppingState(items: items ?? this.items);
  }

  @override
  List<Object> get props => [items];
}
