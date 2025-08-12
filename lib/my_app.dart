import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opration/core/localization/s.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/router_generation_config.dart';
import 'package:opration/core/theme/themes.dart';
import 'package:opration/features/app_blocker/data/repositories/app_repository.dart';
import 'package:opration/features/app_blocker/data/repositories/rules_repository.dart';
import 'package:opration/features/app_blocker/presentation/bloc/blocker_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppRepository>(
          // Using the real repository
          create: (context) => AppRepository(),
        ),
        RepositoryProvider<RulesRepository>(
          create: (context) => RulesRepository(Hive.box('rulesBox')),
        ),
      ],
      child: BlocProvider(
        create: (context) => HomeBloc(
          appRepository: context.read<AppRepository>(),
          rulesRepository: context.read<RulesRepository>(),
        )..add(LoadInstalledApps()),
        child: GestureDetector(
          onTap: () => unfocusScope(context),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Operating system',
            routerConfig: RouterGenerationConfig.goRouter,
            theme: Appthemes.lightTheme(),
            locale: const Locale('en'),
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
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
