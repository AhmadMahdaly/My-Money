import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/features/financial_goals/presentation/screens/financial_goals_screen.dart';
import 'package:opration/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:opration/features/transactions/presentation/screens/monthly_plan_screen.dart';
import 'package:opration/features/transactions/presentation/screens/transaction_details_screen.dart';
import 'package:opration/features/wallets/presentation/screens/wallets_screen.dart';

part 'main_layout_state.dart';

class MainLayoutCubit extends Cubit<MainLayoutState> {
  MainLayoutCubit() : super(MainLayoutInitial());
  List<Widget> screens = [
    const TransactionDetailsScreen(),
    const MonthlyPlanScreen(),
    const AddTransactionScreen(),
    const WalletsScreen(),
    const FinancialGoalsScreen(),
  ];
  int currentIndex = 2;
  void changeNavBarIndex(int index) {
    currentIndex = index;
    emit(ChangeNavBarState());
  }
}
