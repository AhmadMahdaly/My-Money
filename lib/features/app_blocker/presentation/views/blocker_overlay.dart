import 'package:flutter/material.dart';

class BlockerOverlay extends StatelessWidget {
  const BlockerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_off_outlined, color: Colors.white, size: 80),
              SizedBox(height: 24),
              Text(
                'انتهى الوقت!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 16),
              Text(
                'لقد تجاوزت الحد الزمني المسموح به لاستخدام هذا التطبيق اليوم. خذ قسطاً من الراحة!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
