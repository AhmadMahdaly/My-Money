import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionWidget extends StatelessWidget {
  const AppVersionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FutureBuilder<String>(
        future: getAppVersion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          } else if (snapshot.hasError) {
            return const Text('');
          } else {
            return Text(
              'رقم الإصدار: ${snapshot.data}',
              style: AppTextStyles.style9W600.copyWith(
                fontSize: 9.sp,
                color: AppColors.forthColor.withAlpha(150),
              ),
            );
          }
        },
      ),
    );
  }

  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();

    return info.version;
  }
}
