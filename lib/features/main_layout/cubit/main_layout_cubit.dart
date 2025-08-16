import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:opration/features/transactions/presentation/screens/monthly_plan_screen.dart';
import 'package:opration/features/transactions/presentation/screens/transaction_details_screen.dart';

part 'main_layout_state.dart';

class MainLayoutCubit extends Cubit<MainLayoutState> {
  MainLayoutCubit() : super(MainLayoutInitial());
  List<Widget> screens = [
    const TransactionDetailsScreen(),
    const AddTransactionScreen(),
    const MonthlyPlanScreen(),
  ];
  int currentIndex = 1;
  void changeNavBarIndex(int index) {
    currentIndex = index;
    emit(ChangeNavBarState());
  }
}
