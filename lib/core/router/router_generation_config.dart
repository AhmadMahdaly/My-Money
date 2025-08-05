import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/features/login/presentation/cubit/login_cubit.dart';
import 'package:opration/features/login/presentation/views/login_view.dart';
import 'package:opration/features/splash/views/splash_view.dart';

class RouterGenerationConfig {
  static GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.splashScreen,
    routes: [
      GoRoute(
        path: AppRoutes.splashScreen,
        name: AppRoutes.splashScreen,
        builder: (context, state) => const SplashView(),
      ),
      // GoRoute(
      //   path: AppRoutes.onbordingScreen,
      //   name: AppRoutes.onbordingScreen,
      //   builder: (context, state) => const OnBoardingScreen(),
      // ),
      GoRoute(
        path: AppRoutes.loginScreen,
        name: AppRoutes.loginScreen,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<LoginCubit>(),
          child: const LoginScreen(),
        ),
      ),
    ],
  );
}
