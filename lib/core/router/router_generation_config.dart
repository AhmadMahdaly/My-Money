import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/features/splash/views/splash_view.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/presentation/cubit/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:opration/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:opration/features/transactions/presentation/screens/monthly_plan_screen.dart';
import 'package:opration/features/transactions/presentation/screens/transaction_details_screen.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/manage_categories_drawer.dart';

class RouterGenerationConfig {
  static GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.splashScreen,
    routes: [
      GoRoute(
        path: AppRoutes.splashScreen,
        name: AppRoutes.splashScreen,
        builder: (context, state) => const SplashView(),
      ),

      GoRoute(
        path: AppRoutes.trackMoney,
        name: AppRoutes.trackMoney,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<TransactionCubit>()..loadInitialData(),
          child: const AddTransactionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.manageCategoriesScreen,
        name: AppRoutes.manageCategoriesScreen,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<TransactionCubit>()..loadInitialData(),
          child: const ManageCategoriesDrawer(),
        ),
      ),
      GoRoute(
        path: AppRoutes.transactionDetailsScreen,
        name: AppRoutes.transactionDetailsScreen,
        builder: (context, state) => BlocProvider.value(
          value: sl<TransactionCubit>()..loadInitialData(),
          child: const TransactionDetailsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editTransactionScreen,
        name: AppRoutes.editTransactionScreen,
        builder: (context, state) {
          final transaction = state.extra! as Transaction;
          return BlocProvider.value(
            value: sl<TransactionCubit>(),
            child: EditTransactionScreen(
              transaction: transaction,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.monthlyPlanScreen,
        name: AppRoutes.monthlyPlanScreen,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  sl<MonthlyPlanCubit>()..loadPlanForMonth(DateTime.now()),
            ),
            BlocProvider.value(
              value: sl<TransactionCubit>(),
            ),
          ],
          child: const MonthlyPlanScreen(),
        ),
      ),
    ],
  );
}
