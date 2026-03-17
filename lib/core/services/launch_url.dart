// import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    // debugPrint('Could not launch $url');
  }
}
