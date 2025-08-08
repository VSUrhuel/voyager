import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String docId;
  final String courseCode;
  final String courseName;
  final String courseDescription;
  final List<String> courseDeliverables;
  final String courseImgUrl;
  final bool courseSoftDelete;
  late final String courseStatus;
  final DateTime courseCreatedTimestamp;
  final DateTime courseModifiedTimestamp;

  CourseModel({
    required this.docId,
    required this.courseCode,
    required this.courseName,
    required this.courseDescription,
    required this.courseDeliverables,
    required this.courseImgUrl,
    required this.courseSoftDelete,
    required this.courseStatus,
    required this.courseCreatedTimestamp,
    required this.courseModifiedTimestamp,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json, String id) {
    return CourseModel(
      docId: id,
      courseCode: json['courseCode'] ?? '',
      courseName: json['courseName'] ?? '',
      courseDescription: json['courseDescription'] ?? '',
      courseDeliverables: List<String>.from(json['courseDeliverables'] ?? []),
      courseImgUrl: json['courseImgUrl'] ?? '',
      courseSoftDelete: json['courseSoftDelete'] ?? false,
      courseStatus: json['courseStatus'] ?? 'inactive',
      courseCreatedTimestamp: json['courseCreatedTimestamp'] is Timestamp
          ? (json['courseCreatedTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
      courseModifiedTimestamp: json['courseModifiedTimestamp'] is Timestamp
          ? (json['courseModifiedTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseCode': courseCode,
      'courseName': courseName,
      'courseDescription': courseDescription,
      'courseDeliverables': courseDeliverables,
      'courseImgUrl': courseImgUrl,
      'courseSoftDelete': courseSoftDelete,
      'courseStatus': courseStatus,
      'courseCreatedTimestamp': courseCreatedTimestamp.toIso8601String(),
      'courseModifiedTimestamp': courseModifiedTimestamp.toIso8601String(),
    };
  }
}
