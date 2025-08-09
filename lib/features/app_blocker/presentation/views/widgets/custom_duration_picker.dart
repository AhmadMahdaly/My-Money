import 'package:flutter/material.dart';

class CustomDurationPickerDialog extends StatefulWidget {
  const CustomDurationPickerDialog({
    super.key,
    this.initialDuration = const Duration(hours: 1),
  });
  final Duration initialDuration;

  @override
  State<CustomDurationPickerDialog> createState() =>
      _CustomDurationPickerDialogState();
}

class _CustomDurationPickerDialogState
    extends State<CustomDurationPickerDialog> {
  late int _selectedHours;
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.initialDuration.inHours;
    _selectedMinutes = widget.initialDuration.inMinutes.remainder(60);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختر المدة الزمنية'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Hours Picker
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ساعات'),
              DropdownButton<int>(
                value: _selectedHours,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedHours = value;
                    });
                  }
                },
                items: List.generate(24, (index) => index)
                    .map(
                      (hour) => DropdownMenuItem(
                        value: hour,
                        child: Text(hour.toString().padLeft(2, '0')),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          // Minutes Picker
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('دقائق'),
              DropdownButton<int>(
                value: _selectedMinutes,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMinutes = value;
                    });
                  }
                },
                items: [0, 15, 30, 45]
                    .map(
                      (minute) => DropdownMenuItem(
                        value: minute,
                        child: Text(minute.toString().padLeft(2, '0')),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final duration = Duration(
              hours: _selectedHours,
              minutes: _selectedMinutes,
            );
            Navigator.of(context).pop(duration);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
