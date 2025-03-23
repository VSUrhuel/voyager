class MenteeModel {
  final String accountId;
  final String menteeMcaId;
  final String menteeYearLvl;

  MenteeModel({
    required this.accountId,
    required this.menteeMcaId,
    required this.menteeYearLvl,
  });

  factory MenteeModel.fromJson(Map<String, dynamic> json) {
    return MenteeModel(
      accountId: json['accountId'] ?? '',
      menteeMcaId: json['menteeMcaId'] ?? '',
      menteeYearLvl: json['menteeYearLvl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'menteeMcaId': menteeMcaId,
      'menteeYearLvl': menteeYearLvl,
    };
  }
}
