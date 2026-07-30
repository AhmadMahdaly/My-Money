import 'package:go_router/go_router.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/features/Settings/app_settings_screen.dart';
import 'package:opration/features/Settings/backup_screen.dart';
import 'package:opration/features/Settings/more_page.dart';
import 'package:opration/features/Settings/recurring_operations_screen.dart';
import 'package:opration/features/auth/presentation/views/login_view.dart';
import 'package:opration/features/debt/presentation/screens/credits_view.dart';
import 'package:opration/features/debt/presentation/screens/debt_payments_log_view.dart';
import 'package:opration/features/debt/presentation/screens/debts_view.dart';
import 'package:opration/features/goals/presentation/screens/financial_goals_screen.dart';
import 'package:opration/features/intro/splash/views/splash_view.dart';
import 'package:opration/features/main_layout/views/main_layout.dart';
import 'package:opration/features/monthly_plan/presentation/screens/monthly_analytics_screen.dart';
import 'package:opration/features/monthly_plan/presentation/screens/monthly_plan_screen.dart';
import 'package:opration/features/notifications/notifications_screen.dart';
import 'package:opration/features/shopping/presentation/screens/shopping_list_view.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:opration/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:opration/features/transactions/presentation/screens/manage_categories_page.dart';
import 'package:opration/features/transactions/presentation/screens/transaction_details_screen.dart';
import 'package:opration/features/wallets/presentation/screens/transfer_history_screen.dart';
import 'package:opration/features/wallets/presentation/screens/wallets_screen.dart';

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
        path: AppRoutes.mainLayoutScreen,
        name: AppRoutes.mainLayoutScreen,
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: AppRoutes.notificationsScreen,
        name: AppRoutes.notificationsScreen,
        builder: (context, state) => const NotificationsScreen(),
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
        path: AppRoutes.moreScreen,
        name: AppRoutes.moreScreen,
        builder: (context, state) => const MoreView(),
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
      GoRoute(
        path: AppRoutes.financialGoalsScreen,
        name: AppRoutes.financialGoalsScreen,
        builder: (context, state) => const FinancialGoalsScreen(),
      ),
      GoRoute(
        path: AppRoutes.debtsView,
        name: AppRoutes.debtsView,
        builder: (context, state) => const DebtsView(),
      ),
      GoRoute(
        path: AppRoutes.creditsView,
        name: AppRoutes.creditsView,
        builder: (context, state) => const CreditsView(),
      ),
      GoRoute(
        path: AppRoutes.shoppingListView,
        name: AppRoutes.shoppingListView,
        builder: (context, state) => const ShoppingListView(),
      ),
      GoRoute(
        path: AppRoutes.walletsScreen,
        name: AppRoutes.walletsScreen,
        builder: (context, state) => const WalletsScreen(),
      ),
      GoRoute(
        path: AppRoutes.transferHistoryScreen,
        name: AppRoutes.transferHistoryScreen,
        builder: (context, state) => const TransferHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.backupScreen,
        name: AppRoutes.backupScreen,
        builder: (context, state) {
          final isFromMorePage = state.extra as bool? ?? false;
          return BackupScreen(isFromMorePage: isFromMorePage);
        },
      ),
      GoRoute(
        path: AppRoutes.recurringOperationsScreen,
        name: AppRoutes.recurringOperationsScreen,
        builder: (context, state) => const RecurringOperationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.monthlyAnalyticsScreen,
        name: AppRoutes.monthlyAnalyticsScreen,
        builder: (context, state) => const MonthlyAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.debtPaymentsLogView,
        name: AppRoutes.debtPaymentsLogView,
        builder: (context, state) => const DebtPaymentsLogView(),
      ),
      GoRoute(
        path: AppRoutes.appSettingsScreen,
        name: AppRoutes.appSettingsScreen,
        builder: (context, state) => const AppSettingsScreen(),
      ),
    ],
  );
}
