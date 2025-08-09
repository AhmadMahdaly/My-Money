import 'dart:convert';

enum BlockType { permanent, scheduled, recurring }

class BlockerSchedule {
  BlockerSchedule({
    required this.blockType,
    this.blockUntil,
    this.recurringInterval,
    this.recurringDuration,
  });

  factory BlockerSchedule.fromJson(String source) =>
      BlockerSchedule.fromMap(json.decode(source) as Map<String, dynamic>);

  factory BlockerSchedule.fromMap(Map<String, dynamic> map) {
    return BlockerSchedule(
      blockType: BlockType.values.firstWhere((e) => e.name == map['blockType']),
      blockUntil: map['blockUntil'] != null
          ? DateTime.parse(map['blockUntil'].toString())
          : null,
      recurringInterval: map['recurringInterval'] != null
          ? Duration(seconds: map['recurringInterval'] as int)
          : null,
      recurringDuration: map['recurringDuration'] != null
          ? Duration(seconds: map['recurringDuration'] as int)
          : null,
    );
  }
  final BlockType blockType;
  final DateTime? blockUntil;
  final Duration? recurringInterval;
  final Duration? recurringDuration;

  Map<String, dynamic> toMap() {
    return {
      'blockType': blockType.name,
      'blockUntil': blockUntil?.toIso8601String(),
      'recurringInterval': recurringInterval?.inSeconds,
      'recurringDuration': recurringDuration?.inSeconds,
    };
  }

  String toJson() => json.encode(toMap());

  String get description {
    switch (blockType) {
      case BlockType.permanent:
        return 'Permanently blocked';
      case BlockType.scheduled:
        final formattedDate = blockUntil != null
            ? "${blockUntil!.hour}:${blockUntil!.minute.toString().padLeft(2, '0')}, ${blockUntil!.day}/${blockUntil!.month}"
            : '';
        return 'Scheduled until $formattedDate';
      case BlockType.recurring:
        final interval = recurringInterval?.inHours ?? 0;
        final duration = recurringDuration?.inMinutes ?? 0;
        return 'Blocked for $duration minutes every $interval hours';
    }
  }
}
