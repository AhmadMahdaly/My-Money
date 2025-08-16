import 'package:go_router/go_router.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/features/login/presentation/views/login_view.dart';
import 'package:opration/features/main_layout/views/main_layout.dart';
import 'package:opration/features/splash/views/splash_view.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
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
        path: AppRoutes.loginScreen,
        name: AppRoutes.loginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.mainLayout,
        name: AppRoutes.mainLayout,
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: AppRoutes.addTransactionScreen,
        name: AppRoutes.addTransactionScreen,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: AppRoutes.manageCategoriesScreen,
        name: AppRoutes.manageCategoriesScreen,
        builder: (context, state) => const ManageCategoriesDrawer(),
      ),
      GoRoute(
        path: AppRoutes.transactionDetailsScreen,
        name: AppRoutes.transactionDetailsScreen,
        builder: (context, state) => const TransactionDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.editTransactionScreen,
        name: AppRoutes.editTransactionScreen,
        builder: (context, state) {
          final transaction = state.extra! as Transaction;
          return EditTransactionScreen(
            transaction: transaction,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.monthlyPlanScreen,
        name: AppRoutes.monthlyPlanScreen,
        builder: (context, state) => const MonthlyPlanScreen(),
      ),
    ],
  );
}
