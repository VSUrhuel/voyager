import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String accountApiID;
  final String accountApiName;
  final String accountApiEmail;
  final String accountPassword;
  final String accountApiPhoto;
  final String accountUsername;
  final String accountRole;
  final String accountStudentId;
  final bool accountSoftDeleted;
  final DateTime accountCreatedTimestamp;
  final DateTime accountModifiedTimestamp;

  UserModel({
    required this.accountApiID,
    required this.accountApiName,
    required this.accountApiEmail,
    required this.accountPassword,
    required this.accountApiPhoto,
    required this.accountUsername,
    required this.accountRole,
    required this.accountStudentId,
    required this.accountSoftDeleted,
    required this.accountCreatedTimestamp,
    required this.accountModifiedTimestamp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accountApiID: json['accountApiID'] ?? '',
      accountApiName: json['accountApiName'] ?? '',
      accountApiEmail: json['accountApiEmail'] ?? '',
      accountPassword: json['accountPassword'] ?? '',
      accountApiPhoto: json['accountApiPhoto'] ?? '',
      accountUsername: json['accountUsername'] ?? '',
      accountRole: json['accountRole'] ?? '',
      accountStudentId: json['accountStudentId'] ?? '',
      accountSoftDeleted: json['accountSoftDeleted'] ?? false,
      accountCreatedTimestamp: json['accountCreatedTimestamp'] is Timestamp
          ? (json['accountCreatedTimestamp'] as Timestamp).toDate()
          : DateTime.now(), // Default to current time if missing
      accountModifiedTimestamp: json['accountModifiedTimestamp'] is Timestamp
          ? (json['accountModifiedTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountApiID': accountApiID,
      'accountApiName': accountApiName,
      'accountApiEmail': accountApiEmail,
      'accountPassword': accountPassword,
      'accountApiPhoto': accountApiPhoto,
      'accountUsername': accountUsername,
      'accountRole': accountRole,
      'accountStudentId': accountStudentId,
      'accountSoftDeleted': accountSoftDeleted,
      'accountCreatedTimestamp': accountCreatedTimestamp
          .toIso8601String(), // Convert DateTime to ISO 8601 string
      'accountModifiedTimestamp': accountModifiedTimestamp
          .toIso8601String(), // Convert DateTime to ISO 8601 string
    };
  }
}
