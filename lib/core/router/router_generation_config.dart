import 'package:go_router/go_router.dart';
import 'package:opration/core/router/app_routes.dart';
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
      // GoRoute(
      //   path: AppRoutes.loginScreen,
      //   name: AppRoutes.loginScreen,
      //   builder: (context, state) => BlocProvider<AuthCubit>(
      //     create: (context) => AuthCubit(getIt<AuthRepo>()),
      //     child: const LoginScreen(),
      //   ),
      // ),
    ],
  );
}
