part of 'credit_cubit.dart';

class CreditState extends Equatable {
  const CreditState({this.items = const []});
  final List<Credit> items;

  CreditState copyWith({List<Credit>? credits}) {
    return CreditState(items: credits ?? items);
  }

  @override
  List<Object> get props => [items];
}
