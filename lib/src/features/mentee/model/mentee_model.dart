import 'package:cloud_firestore/cloud_firestore.dart';

class MenteeModel {
  final String docId;
  final String accountId;
  final List<String> menteeMcaId;
  final String menteeYearLvl;
  final DateTime menteeCreatedTimestamp;
  final DateTime menteeModifiedTimestamp;

  MenteeModel({
    required this.docId,
    required this.accountId,
    required this.menteeMcaId,
    required this.menteeYearLvl,
    required this.menteeCreatedTimestamp,
    required this.menteeModifiedTimestamp,
  });

  factory MenteeModel.fromJson(Map<String, dynamic> json, String id) {
    return MenteeModel(
      docId: id,
      accountId: json['accountId'] ?? '',
      menteeMcaId: json['menteeMcaId'] != null
          ? List<String>.from(json['menteeMcaId'] as List)
          : [],
      menteeYearLvl: json['menteeYearLvl'] ?? '',
      menteeCreatedTimestamp: json['menteeCreatedTimestamp'] is Timestamp
          ? (json['menteeCreatedTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
      menteeModifiedTimestamp: json['menteeModifiedTimestamp'] is Timestamp
          ? (json['menteeModifiedTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'menteeMcaId': menteeMcaId,
      'menteeYearLvl': menteeYearLvl,
      'menteeCreatedTimestamp': menteeCreatedTimestamp.toIso8601String(),
      'menteeModifiedTimestamp': menteeModifiedTimestamp.toIso8601String(),
    };
  }
}
