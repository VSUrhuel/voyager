import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String courseCode;
  final DateTime courseCreatedTimestamp;
  final List<String> courseDeliverables;
  final String courseDescription;
  final String courseImgUrl;
  final DateTime courseModifiedTimestamp; 
  final String courseName;
  final bool courseSoftDeleted;
  final String courseStatus;

  CourseModel({
    required this.courseCode,
    required this.courseCreatedTimestamp,
    required this.courseDeliverables,
    required this.courseDescription,
    required this.courseImgUrl,
    required this.courseModifiedTimestamp,
    required this.courseName,
    required this.courseSoftDeleted,
    required this.courseStatus,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json){
    return CourseModel(
      courseCode: json['courseCode'] ?? '',
      courseCreatedTimestamp: json['courseCreatedTimestamp'] is Timestamp
          ? (json['courseCreatedTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
      courseDeliverables: json['courseDeliverables'] != null
          ? List<String>.from(json['courseDeliverables'])
          : [],
      courseDescription: json['courseDescription'] ?? '',
      courseImgUrl: json['courseImgUrl'] ?? '',
      courseModifiedTimestamp: json['courseModifiedTimestamp'] is Timestamp
          ? (json['courseModifiedTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
      courseName: json['courseName'] ?? '',
      courseSoftDeleted: json['courseSoftDeleted'] ?? false,
      courseStatus: json['courseStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'courseCode': courseCode,
      'courseCreatedTimestamp': courseCreatedTimestamp,
      'courseDeliverables': courseDeliverables,
      'courseDescription': courseDescription,
      'courseImgUrl': courseImgUrl,
      'courseModifiedTimestamp': courseModifiedTimestamp,
      'courseName': courseName,
      'courseSoftDeleted': courseSoftDeleted,
      'courseStatus': courseStatus,
    };
  }
}