import 'package:flutter/material.dart';
import 'package:opration/features/app_blocker/models/blocker_schedule.dart';
import 'package:opration/features/app_blocker/presentation/views/widgets/custom_duration_picker.dart';

class ScheduleDialog extends StatefulWidget {
  const ScheduleDialog({super.key});

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  BlockType _selectedType = BlockType.permanent;
  DateTime _scheduledUntil = DateTime.now().add(const Duration(hours: 1));
  Duration _recurringInterval = const Duration(hours: 2);
  Duration _recurringDuration = const Duration(minutes: 30);

  Future<Duration?> _showCustomDurationPicker(Duration initial) async {
    return showDialog<Duration>(
      context: context,
      builder: (_) => CustomDurationPickerDialog(initialDuration: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إعدادات حظر التطبيق'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<BlockType>(
              value: _selectedType,
              onChanged: (BlockType? newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: BlockType.permanent,
                  child: Text('حظر دائم'),
                ),
                DropdownMenuItem(
                  value: BlockType.scheduled,
                  child: Text('حظر لفترة محددة'),
                ),
                DropdownMenuItem(
                  value: BlockType.recurring,
                  child: Text('حظر دوري متكرر'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedType == BlockType.scheduled)
              ListTile(
                title: const Text('الحظر حتى تاريخ ووقت:'),
                subtitle: Text(
                  "${"${_scheduledUntil.toLocal()}".split(' ')[0]} - ${TimeOfDay.fromDateTime(_scheduledUntil).format(context)}",
                ),
                trailing: const Icon(Icons.edit),
                onTap: _pickScheduledDateTime,
              ),
            if (_selectedType == BlockType.recurring) ...[
              const Text('كل:'),
              ListTile(
                title: Text(
                  '${_recurringInterval.inHours} ساعة و ${_recurringInterval.inMinutes.remainder(60)} دقيقة',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final resultingDuration = await _showCustomDurationPicker(
                    _recurringInterval,
                  );
                  if (resultingDuration != null) {
                    setState(() => _recurringInterval = resultingDuration);
                  }
                },
              ),
              const Text('يتم الحظر لمدة:'),
              ListTile(
                title: Text(
                  '${_recurringDuration.inHours} ساعة و ${_recurringDuration.inMinutes.remainder(60)} دقيقة',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final resultingDuration = await _showCustomDurationPicker(
                    _recurringDuration,
                  );
                  if (resultingDuration != null) {
                    setState(() => _recurringDuration = resultingDuration);
                  }
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveSchedule,
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  Future<void> _pickScheduledDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledUntil,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledUntil),
    );
    if (time == null) return;

    setState(() {
      _scheduledUntil = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _saveSchedule() {
    BlockerSchedule schedule;
    switch (_selectedType) {
      case BlockType.permanent:
        schedule = BlockerSchedule(blockType: BlockType.permanent);
      case BlockType.scheduled:
        schedule = BlockerSchedule(
          blockType: BlockType.scheduled,
          blockUntil: _scheduledUntil,
        );
      case BlockType.recurring:
        schedule = BlockerSchedule(
          blockType: BlockType.recurring,
          recurringInterval: _recurringInterval,
          recurringDuration: _recurringDuration,
        );
    }
    Navigator.of(context).pop(schedule);
  }
}
