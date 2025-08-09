import 'package:flutter/material.dart';
import 'package:opration/features/app_blocker/models/blocker_schedule.dart';
import 'package:opration/features/app_blocker/presentation/views/widgets/custom_duration_picker.dart';

class ScheduleDialog extends StatefulWidget {
  const ScheduleDialog({super.key});

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  BlockType _selectedType = BlockType.scheduled;
  DateTime _scheduledUntil = DateTime.now().add(const Duration(minutes: 5));
  Duration _recurringInterval = const Duration(hours: 2);
  Duration _recurringDuration = const Duration(minutes: 30);
  int blockMinutes = 5;

  Future<Duration?> _showCustomDurationPicker(Duration initial) async {
    return showDialog<Duration>(
      context: context,
      builder: (_) => CustomDurationPickerDialog(initialDuration: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('App Blocker Settings'),
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
                  child: Text('Permanently blocked'),
                ),
                DropdownMenuItem(
                  value: BlockType.scheduled,
                  child: Text('Scheduled'),
                ),
                DropdownMenuItem(
                  value: BlockType.recurring,
                  child: Text('Recurring'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedType == BlockType.scheduled) ...[
              const Text('Block duration (in minutes):'),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter the number of minutes (e.g., 5)',
                ),
                onChanged: (value) {
                  final minutes = int.tryParse(value) ?? 5;
                  setState(() {
                    blockMinutes = minutes;
                    _scheduledUntil = DateTime.now().add(
                      Duration(minutes: minutes),
                    );
                  });
                },
              ),
            ],
            if (_selectedType == BlockType.recurring) ...[
              const Text('Every:'),
              ListTile(
                title: Text(
                  '${_recurringInterval.inHours} hours & ${_recurringInterval.inMinutes.remainder(60)} minutes',
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
              const Text('Blocked for:'),
              ListTile(
                title: Text(
                  '${_recurringDuration.inHours} hours & ${_recurringDuration.inMinutes.remainder(60)} minutes',
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSchedule,
          child: const Text('Save'),
        ),
      ],
    );
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
