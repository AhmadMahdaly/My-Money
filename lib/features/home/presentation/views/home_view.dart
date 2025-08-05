import 'package:flutter/material.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          children: [
            Text(
              '👋 Welcome $userName',
              style: Styles.style18W900.copyWith(color: AppColors.orangeColor),
            ),
          ],
        ),
      ),
    );
  }
}
