import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/localization/s.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/router_generation_config.dart';
import 'package:opration/core/theme/themes.dart';
import 'package:opration/features/financial_goals/presentation/cubit/financial_goal_cubit.dart';
import 'package:opration/features/intro/login/presentation/cubit/login_cubit.dart';
import 'package:opration/features/main_layout/cubit/main_layout_cubit.dart';
import 'package:opration/features/transactions/presentation/cubit/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return GestureDetector(
      onTap: () => unfocusScope(context),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => getIt<AuthCubit>(),
          ),

          BlocProvider<MainLayoutCubit>(
            create: (context) => MainLayoutCubit(),
          ),
          BlocProvider<TransactionCubit>(
            create: (_) => TransactionCubit(
              getTransactionsUseCase: getIt(),
              addTransactionUseCase: getIt(),
              updateTransactionUseCase: getIt(),
              deleteTransactionUseCase: getIt(),
              getCategoriesUseCase: getIt(),
              addCategoryUseCase: getIt(),
              updateCategoryUseCase: getIt(),
              deleteCategoryUseCase: getIt(),
              getFilterSettingsUseCase: getIt(),
              saveFilterSettingsUseCase: getIt(),
            )..loadInitialData(),
          ),
          BlocProvider<MonthlyPlanCubit>(
            create: (context) => MonthlyPlanCubit(
              getMonthlyPlanUseCase: getIt(),
              saveMonthlyPlanUseCase: getIt(),
            )..loadPlanForMonth(DateTime.now()),
          ),
          BlocProvider<WalletCubit>(
            create: (_) => WalletCubit(
              getWalletsUseCase: getIt(),
              addWalletUseCase: getIt(),
              updateWalletUseCase: getIt(),
              deleteWalletUseCase: getIt(),
              setMainWalletUseCase: getIt(),
              getShowMainWalletPrefUseCase: getIt(),
              saveShowMainWalletPrefUseCase: getIt(),
            )..loadWallets(),
          ),
          BlocProvider<FinancialGoalCubit>(
            create: (_) => FinancialGoalCubit(
              getFinancialGoalsUseCase: getIt(),
              addFinancialGoalUseCase: getIt(),
              updateFinancialGoalUseCase: getIt(),
              deleteFinancialGoalUseCase: getIt(),
            )..loadGoals(),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'فلوسي',
          routerConfig: RouterGenerationConfig.goRouter,
          theme: Appthemes.lightTheme(),
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}

void unfocusScope(BuildContext context) {
  final currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    currentFocus.unfocus();
  }
}
