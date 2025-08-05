import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theming/themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp(
      title: 'Operating system',
      theme: Appthemes.lightTheme(),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
