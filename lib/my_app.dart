import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:opration/core/localization/s.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/router_generation_config.dart';
import 'package:opration/core/theming/themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp.router(
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
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
