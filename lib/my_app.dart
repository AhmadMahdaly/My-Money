import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/localization/s.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/router_generation_config.dart';
import 'package:opration/core/theme/themes.dart';
import 'package:opration/features/login/presentation/cubit/login_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return GestureDetector(
      onTap: () => unfocusScope(context),
      child: BlocProvider(
        create: (_) => sl<AuthCubit>(),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Operating system',
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
