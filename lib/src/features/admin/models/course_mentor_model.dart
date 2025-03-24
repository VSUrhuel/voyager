import 'package:cloud_firestore/cloud_firestore.dart';

class CourseMentorModel {
  final String courseMentorId;
  final String courseId ;
  final String mentorId;
  final DateTime courseMentorCreatedTimestamp;
  final bool courseMentorSoftDeleted;

  CourseMentorModel({
    required this.courseMentorId,
    required this.courseId,
    required this.mentorId,
    required this.courseMentorCreatedTimestamp,
    required this.courseMentorSoftDeleted,
  });

  factory CourseMentorModel.fromJson(Map<String, dynamic> json) {
    return CourseMentorModel(
      courseMentorId: json['courseMentorId'] ?? '',
      courseId: json['courseId'] ?? '',
      mentorId: json['mentorId'] ?? '',
      courseMentorCreatedTimestamp: json['courseMentorCreatedTimestamp'] is Timestamp
          ? (json['courseMentorCreatedTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
      courseMentorSoftDeleted: json['courseMentorSoftDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'courseMentorId': courseMentorId,
      'courseId': courseId,
      'mentorId': mentorId,
      'courseMentorCreatedTimestamp': courseMentorCreatedTimestamp,
      'courseMentorSoftDeleted': courseMentorSoftDeleted,
    };
  }
}