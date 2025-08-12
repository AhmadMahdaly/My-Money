import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // final bool _usageAccessGranted = false;
  bool _overlayPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final overlay = await FlutterOverlayWindow.isPermissionGranted();
    setState(() {
      _overlayPermissionGranted = overlay;
    });
  }

  void _showInfoDialog(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('حسناً'),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والصلاحيات'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'الصلاحيات المطلوبة',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 8),
          _buildPermissionTile(
            title: 'الوصول لبيانات الاستخدام',
            subtitle: 'لمراقبة وقت استخدام التطبيقات',
            isGranted: true,
            onTap: () {
              // AppUsage.();
              _showInfoDialog(
                'صلاحية الوصول للاستخدام',
                'سيتم توجيهك الآن لشاشة الإعدادات. الرجاء البحث عن تطبيقنا في القائمة وتفعيل الصلاحية له.',
              );
            },
          ),
          _buildPermissionTile(
            title: 'العرض فوق التطبيقات الأخرى',
            subtitle: 'لعرض شاشة الحظر عند انتهاء الوقت',
            isGranted: _overlayPermissionGranted,
            onTap: () async {
              final isGranted =
                  await FlutterOverlayWindow.isPermissionGranted();
              if (!isGranted) {
                await FlutterOverlayWindow.requestPermission();
              }
              await _checkPermissions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          isGranted ? Icons.check_circle : Icons.cancel,
          color: isGranted ? Colors.green : Colors.red,
        ),
        onTap: onTap,
      ),
    );
  }
}
