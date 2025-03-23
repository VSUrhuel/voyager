import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MentorController extends GetxController {
  static MentorController get instance => Get.find();

  final mentorId = TextEditingController();
  final accountId = TextEditingController();
  final mentorYearLvl = TextEditingController();
  final mentorAbout = TextEditingController();
  final mentorSessionCompleted = TextEditingController();
  final mentorLanguages = TextEditingController();
  final mentorFbUrl = TextEditingController();
  final mentorGitUrl = TextEditingController();
  final mentorExpHeader = TextEditingController();
  final mentorMotto = TextEditingController();
  final mentorExpertise = TextEditingController();
  final mentorExpDesc = TextEditingController();
  final mentorRegDay = TextEditingController();
  final mentorRegStartTime = TextEditingController();
  final mentorRegEndTime = TextEditingController();
  final mentorStatus = TextEditingController();
  final mentorSoftDeleted = TextEditingController();
  final mentorUserName = TextEditingController();
  var selectedLanguages = <String>[].obs;
  void updateselectedLanguages(List<String> newLang) {
    selectedLanguages.value = newLang;
  }

  var selectedDays = <String>[].obs;
  void updateSelectedDays(List<String> newDays) {
    selectedDays.value = newDays;
  }

  var selectedSkills = <String>[].obs;
  void updateSelectedSkills(List<String> newSkills) {
    selectedSkills.value = newSkills;
  }

  var selectedExpHeader = <String>[].obs;
  void updateSelectedExpHeader(List<String> newExpHeader) {
    selectedExpHeader.value = newExpHeader;
  }

  var selectedExpDesc = <String>[].obs;
  void updateSelectedExpDesc(List<String> newExpDesc) {
    selectedExpDesc.value = newExpDesc;
  }

  Future<bool> updateUsername() async {
    final firestore = FirestoreInstance();
    await firestore.updateUsername(
        mentorUserName.text, firestore.getFirebaseUser().uid);

    return Future<bool>.value(true);
  }

  Future<bool> generateMentor() async {
    try {
      final firebaseID = FirestoreInstance().getFirebaseUser().uid;
      final List<String> mentorIDs = await FirestoreInstance().getMentorIDs();
      final List<String> accountIDs =
          await FirestoreInstance().getAccountIDInMentor();
      if (accountIDs.contains(firebaseID)) {
        return Future<bool>.value(false);
      }
      String mentorID = "";
      if (mentorIDs.contains(firebaseID)) {
        mentorID = await FirestoreInstance().getMentorID(firebaseID);
      } else {
        mentorID = FirestoreInstance().generateUniqueId();
      }
      final mentor = MentorModel(
        mentorId: mentorID,
        accountId: FirestoreInstance().getFirebaseUser().uid,
        mentorYearLvl: mentorYearLvl.text,
        mentorAbout: mentorAbout.text,
        mentorSessionCompleted: int.parse(mentorSessionCompleted.text),
        mentorLanguages: selectedLanguages,
        mentorFbUrl: mentorFbUrl.text,
        mentorGitUrl: mentorGitUrl.text,
        mentorExpHeader: selectedExpHeader,
        mentorMotto: mentorMotto.text,
        mentorExpertise: selectedSkills,
        mentorExpDesc: selectedExpDesc,
        mentorRegDay: selectedDays,
        mentorRegStartTime: TimeOfDay(
          hour: int.parse(mentorRegStartTime.text.split(':')[0]) % 12 +
              (mentorRegStartTime.text.toLowerCase().contains('pm') ? 12 : 0),
          minute:
              int.parse(mentorRegStartTime.text.split(':')[1].split(' ')[0]),
        ),
        mentorRegEndTime: TimeOfDay(
          hour: int.parse(mentorRegEndTime.text.split(':')[0]) % 12 +
              (mentorRegEndTime.text.toLowerCase().contains('pm') ? 12 : 0),
          minute: int.parse(mentorRegEndTime.text.split(':')[1].split(' ')[0]),
        ),
        mentorStatus: mentorStatus.text,
        mentorSoftDeleted: false,
      );

      final firestore = FirestoreInstance();

      firestore.setMentor(mentor);
      return Future<bool>.value(true);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return Future<bool>.value(false);
    }
  }
}
