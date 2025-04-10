import 'package:cloud_firestore/cloud_firestore.dart';

class PostContentModel {
  final String contentCategory;
  final DateTime contentCreatedTimestamp;
  final String contentDescription;
  final List<String> contentFiles;
  final List<String> contentImage;
  final DateTime contentModifiedTimestamp;
  final bool contentSoftDelete;
  final String contentTitle;
  final List<String> contentVideo;
  final String courseMentorId;
  final List<Map<String, String>> contentLinks;

  PostContentModel({
    required this.contentCategory,
    required this.contentCreatedTimestamp,
    required this.contentDescription,
    required this.contentFiles,
    required this.contentImage,
    required this.contentModifiedTimestamp,
    required this.contentSoftDelete,
    required this.contentTitle,
    required this.contentVideo,
    required this.courseMentorId,
    required this.contentLinks,
  });

  factory PostContentModel.fromJson(Map<String, dynamic> json) {
    return PostContentModel(
      contentCategory: json['contentCategory'] ?? '',
      contentCreatedTimestamp: json['contentCreatedTimestamp'] is Timestamp
          ? (json['contentCreatedTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
      contentDescription: json['contentDescription'] ?? '',
      contentFiles: json['contentFiles'] != null
          ? List<String>.from(json['contentFiles'] as List)
          : [],
      contentImage: json['contentImage'] != null
          ? List<String>.from(json['contentImage'] as List)
          : [],
      contentModifiedTimestamp: json['contentModifiedTimestamp'] is Timestamp
          ? (json['contentModifiedTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
      contentSoftDelete: json['contentSoftDelete'] ?? false,
      contentTitle: json['contentTitle'] ?? '',
      contentVideo: json['contentVideo'] != null
          ? List<String>.from(json['contentVideo'] as List)
          : [],
      courseMentorId: json['courseMentorId'] ?? '',
      contentLinks: json['contentLinks'] != null
          ? List<Map<String, String>>.from(json['contentLinks']
              .map((link) => Map<String, String>.from(link)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentCategory': contentCategory,
      'contentCreatedTimestamp': contentCreatedTimestamp.toIso8601String(),
      'contentDescription': contentDescription,
      'contentFiles': contentFiles,
      'contentImage': contentImage,
      'contentModifiedTimestamp': contentModifiedTimestamp.toIso8601String(),
      'contentSoftDelete': contentSoftDelete,
      'contentTitle': contentTitle,
      'contentVideo': contentVideo,
      'courseMentorId': courseMentorId,
      'contentLinks': contentLinks,
    };
  }

  factory PostContentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PostContentModel(
      contentCategory: data['contentCategory'] ?? '',
      contentCreatedTimestamp:
          data['contentCreatedTimestamp']?.toDate() ?? DateTime.now(),
      contentDescription: data['contentDescription'] ?? '',
      contentFiles: data['contentFiles'] != null
          ? List<String>.from(data['contentFiles'])
          : [],
      contentImage: data['contentImage'] != null
          ? List<String>.from(data['contentImage'])
          : [],
      contentModifiedTimestamp:
          data['contentModifiedTimestamp']?.toDate() ?? DateTime.now(),
      contentSoftDelete: data['contentSoftDelete'] ?? false,
      contentTitle: data['contentTitle'] ?? '',
      contentVideo: data['contentVideo'] != null
          ? List<String>.from(data['contentVideo'])
          : [],
      courseMentorId: data['courseMentorId'] ?? '',
      contentLinks: data['contentLinks'] != null
          ? List<Map<String, String>>.from(data['contentLinks']
              .map((link) => Map<String, String>.from(link)))
          : [],
    );
  }
}
