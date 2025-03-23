import 'package:flutter/material.dart';

class MentorModel {
  final String mentorId;
  final String accountId;
  final String mentorYearLvl;
  final String mentorAbout;
  final int mentorSessionCompleted;
  final List<String> mentorLanguages;
  final String mentorFbUrl;
  final String mentorGitUrl;
  final List<String> mentorExpHeader;
  final String mentorMotto;
  final List<String> mentorExpertise;
  final List<String> mentorExpDesc;
  final List<String> mentorRegDay;
  final TimeOfDay mentorRegStartTime;
  final TimeOfDay mentorRegEndTime;
  final String mentorStatus;
  final bool mentorSoftDeleted;

  MentorModel({
    required this.mentorId,
    required this.accountId,
    required this.mentorYearLvl,
    required this.mentorAbout,
    required this.mentorSessionCompleted,
    required this.mentorLanguages,
    required this.mentorFbUrl,
    required this.mentorGitUrl,
    required this.mentorExpHeader,
    required this.mentorMotto,
    required this.mentorExpertise,
    required this.mentorExpDesc,
    required this.mentorRegDay,
    required this.mentorRegStartTime,
    required this.mentorRegEndTime,
    required this.mentorStatus,
    required this.mentorSoftDeleted,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      mentorId: json['mentorId'] ?? '',
      accountId: json['accountId'] ?? '',
      mentorYearLvl: json['mentorYearLvl'] ?? '',
      mentorAbout: json['mentorAbout'] ?? '',
      mentorSessionCompleted: json['mentorSessionCompleted'] ?? 0,
      mentorLanguages: (json['mentorLanguages'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      mentorFbUrl: json['mentorFbUrl'] ?? '',
      mentorGitUrl: json['mentorGitUrl'] ?? '',
      mentorExpHeader: (json['mentorExpHeader'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      mentorMotto: json['mentorMotto'] ?? '',
      mentorExpertise: (json['mentorExpertise'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      mentorExpDesc: (json['mentorExpDesc'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      mentorRegDay: (json['mentorRegDay'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      mentorRegStartTime: _parseTime(json['mentorRegStartTime']),
      mentorRegEndTime: _parseTime(json['mentorRegEndTime']),
      mentorStatus: json['mentorStatus'] ?? '',
      mentorSoftDeleted: json['mentorSoftDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mentorId': mentorId,
      'accountId': accountId,
      'mentorYearLvl': mentorYearLvl,
      'mentorAbout': mentorAbout,
      'mentorSessionCompleted': mentorSessionCompleted,
      'mentorLanguages': mentorLanguages,
      'mentorFbUrl': mentorFbUrl,
      'mentorGitUrl': mentorGitUrl,
      'mentorExpHeader': mentorExpHeader,
      'mentorMotto': mentorMotto,
      'mentorExpertise': mentorExpertise,
      'mentorExpDesc': mentorExpDesc,
      'mentorRegDay': mentorRegDay,
      'mentorRegStartTime':
          '${mentorRegStartTime.hour}:${mentorRegStartTime.minute}',
      'mentorRegEndTime': '${mentorRegEndTime.hour}:${mentorRegEndTime.minute}',
      'mentorStatus': mentorStatus,
      'mentorSoftDeleted': mentorSoftDeleted,
    };
  }

  /// Parses a time string (`HH:mm`) to a `TimeOfDay` object
  static TimeOfDay _parseTime(dynamic time) {
    if (time is String && time.contains(':')) {
      final parts = time.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }
}
