import 'package:cloud_firestore/cloud_firestore.dart';

class MenteeScheduleModel {
  final String courseMentorId;
  final DateTime scheduleCreatedTimestamp;
  final DateTime scheduleDate;
  final String scheduleDescription;
  final String scheduleEndTime;
  final DateTime scheduleModifiedTimestamp;
  final String scheduleRoomName;
  final bool scheduleSoftDelete;
  final String scheduleStartTime;
  final String scheduleTitle;

  MenteeScheduleModel({
    required this.courseMentorId,
    required this.scheduleCreatedTimestamp,
    required this.scheduleDate,
    required this.scheduleDescription,
    required this.scheduleEndTime,
    required this.scheduleModifiedTimestamp,
    required this.scheduleRoomName,
    required this.scheduleSoftDelete,
    required this.scheduleStartTime,
    required this.scheduleTitle,
  });

  // Convert from JSON

  factory MenteeScheduleModel.fromJson(Map<String, dynamic> json) {
    return MenteeScheduleModel(
      courseMentorId: json['courseMentorId'] as String,
      scheduleCreatedTimestamp:
          (json['scheduleCreatedTimestamp'] as Timestamp).toDate(),
      scheduleDate: (json['scheduleDate'] as Timestamp).toDate(),
      scheduleDescription: json['scheduleDescription'] as String,
      scheduleEndTime: json['scheduleEndTime'] as String,
      scheduleModifiedTimestamp:
          (json['scheduleModifiedTimestamp'] as Timestamp).toDate(),
      scheduleRoomName: json['scheduleRoomName'] as String,
      scheduleSoftDelete: json['scheduleSoftDelete'] as bool,
      scheduleStartTime: json['scheduleStartTime'] as String,
      scheduleTitle: json['scheduleTitle'] as String,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'courseMentorId': courseMentorId,
      'scheduleCreatedTimestamp': scheduleCreatedTimestamp.toIso8601String(),
      'scheduleDate': scheduleDate.toIso8601String(),
      'scheduleDescription': scheduleDescription,
      'scheduleEndTime': scheduleEndTime,
      'scheduleModifiedTimestamp': scheduleModifiedTimestamp.toIso8601String(),
      'scheduleRoomName': scheduleRoomName,
      'scheduleSoftDelete': scheduleSoftDelete,
      'scheduleStartTime': scheduleStartTime,
      'scheduleTitle': scheduleTitle,
    };
  }

  @override
  String toString() {
    return 'MenteeScheduleModel{'
        'courseMentorId: $courseMentorId, '
        'scheduleCreatedTimestamp: $scheduleCreatedTimestamp, '
        'scheduleDate: $scheduleDate, '
        'scheduleDescription: $scheduleDescription, '
        'scheduleEndTime: $scheduleEndTime, '
        'scheduleModifiedTimestamp: $scheduleModifiedTimestamp, '
        'scheduleRoomName: $scheduleRoomName, '
        'scheduleSoftDelete: $scheduleSoftDelete, '
        'scheduleStartTime: $scheduleStartTime, '
        'scheduleTitle: $scheduleTitle'
        '}';
  }
}
