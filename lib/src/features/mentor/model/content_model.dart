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
      contentCreatedTimestamp: json['contentCreatedTimestamp'] != null
          ? DateTime.parse(json['contentCreatedTimestamp'])
          : DateTime.now(),
      contentDescription: json['contentDescription'] ?? '',
      contentFiles: json['contentFiles'] != null
          ? List<String>.from(json['contentFiles'] as List)
          : [],
      contentImage: json['contentImage'] != null
          ? List<String>.from(json['contentImage'] as List)
          : [],
      contentModifiedTimestamp: json['contentModifiedTimestamp'] != null
          ? DateTime.parse(json['contentModifiedTimestamp'])
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
}
