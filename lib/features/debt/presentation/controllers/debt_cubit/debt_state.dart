part of 'debt_cubit.dart';

class DebtState extends Equatable {
  const DebtState({this.items = const []});
  final List<Debt> items;

  DebtState copyWith({List<Debt>? debts}) {
    return DebtState(items: debts ?? items);
  }

  @override
  List<Object> get props => [items];
}
