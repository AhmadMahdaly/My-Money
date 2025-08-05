import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgImage extends StatelessWidget {
  const SvgImage({
    required this.imagePath,
    super.key,
    this.height = 200,
    this.color,
    this.isNetwork = false,
    this.isFill = false,
  });
  final double? height;
  final String imagePath;
  final Color? color;
  final bool isNetwork;
  final bool isFill;

  @override
  Widget build(BuildContext context) {
    return isNetwork
        ? SvgPicture.network(
            imagePath,
            height: height,
            fit: isFill == true ? BoxFit.cover : BoxFit.contain,
            colorFilter: ColorFilter.mode(
              color ?? Colors.transparent,
              color != null ? BlendMode.srcIn : BlendMode.softLight,
            ),
          )
        : SvgPicture.asset(
            imagePath,
            height: height,
            fit: isFill == true ? BoxFit.fill : BoxFit.contain,
            colorFilter: ColorFilter.mode(
              color ?? Colors.transparent,
              color != null ? BlendMode.srcIn : BlendMode.softLight,
            ),
          );
  }
}
