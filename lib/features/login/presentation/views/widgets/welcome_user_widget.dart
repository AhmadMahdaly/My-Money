import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/login/presentation/views/widgets/text_with_icon.dart';

class WelcomeUserWidget extends StatelessWidget {
  const WelcomeUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '👋 Welcome!',
          style: Styles.style19W700,
        ),
        Text(
          'Enter your name now and enjoy a unique, personal experience designed just for your phone — no internet connection required.',
          style: Styles.style16W500,
        ),
        Text(
          'With this app, you can easily:',
          style: Styles.style16W800.copyWith(color: AppColors.blueLightColor),
        ),
        const TextWithIcon(
          text: 'Track your expenses.',
          icon: Icons.monetization_on_outlined,
        ),
        const TextWithIcon(
          text: 'Write down your thoughts.',
          icon: Icons.mode_edit_outline_outlined,
        ),
        const TextWithIcon(
          text: 'Manage your tasks.',
          icon: Icons.task_alt_rounded,
        ),
        const TextWithIcon(
          text: 'Log your reading progress.',
          icon: Icons.book_outlined,
        ),
        Text(
          'And so much more — all in one place!\nStart now and keep everything organized, offline, and truly yours.',
          style: Styles.style17W500,
        ),
      ],
    );
  }
}
