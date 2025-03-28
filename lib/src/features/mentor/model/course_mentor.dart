import 'package:cloud_firestore/cloud_firestore.dart';

class CourseMentorModel {
  final String courseId;
  final Timestamp courseMentorCreatedTimestamp;
  final String courseMentorId;
  final bool courseMentorSoftDelete;
  final String mentorId;

  CourseMentorModel({
    required this.courseId,
    required this.courseMentorCreatedTimestamp,
    required this.courseMentorId,
    required this.courseMentorSoftDelete,
    required this.mentorId,
  });

  // Factory method to create a model from JSON
  factory CourseMentorModel.fromJson(Map<String, dynamic> json) {
    return CourseMentorModel(
      courseId: json['courseId'] ?? '',
      courseMentorCreatedTimestamp:
          json['courseMentorCreatedTimestamp'] ?? Timestamp.now(),
      courseMentorId: json['courseMentorId'] ?? '',
      courseMentorSoftDelete: json['courseMentorSoftDelete'] ?? false,
      mentorId: json['mentorId'] ?? '',
    );
  }

  // Convert model to JSON format
  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseMentorCreatedTimestamp': courseMentorCreatedTimestamp,
      'courseMentorId': courseMentorId,
      'courseMentorSoftDelete': courseMentorSoftDelete,
      'mentorId': mentorId,
    };
  }
}
