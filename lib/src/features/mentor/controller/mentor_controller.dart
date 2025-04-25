import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/repository/supabase_repository/supabase_instance.dart';

class MentorController extends GetxController {
  static MentorController get instance => Get.find();
  final isLoading = false.obs;
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

  final SupabaseInstance supabase = SupabaseInstance(Supabase.instance.client);
  Future<bool> updateUsername(File? image) async {
    final firestore = FirestoreInstance();
    if (image != null && image.path.isNotEmpty) {
      final String imageUrl = await supabase.uploadProfileImage(image);
      await firestore.updateProfileImage(
          imageUrl, firestore.getFirebaseUser().uid);
    }
    await firestore.updateUsername(
        mentorUserName.text, firestore.getFirebaseUser().uid);

    return Future<bool>.value(true);
  }

  Future<String> uploadImage(File image) async {
    final String imageUrl = await supabase.uploadProfileImage(image);
    return imageUrl;
  }

  Future<bool> generateMentor() async {
    try {
      isLoading.value = true;
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

      String status = 'archived';
      final CourseMentorModel? courseMentor = await FirestoreInstance()
          .getCourseMentorThroughMentor(
              FirestoreInstance().getFirebaseUser().email.toString());
      if (courseMentor != null) {
        status = 'active';
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
        mentorRegStartTime: parseTime(
          mentorRegStartTime.text,
        ),
        mentorRegEndTime: parseTime(
          mentorRegEndTime.text,
        ),
        mentorStatus: status,
        mentorSoftDeleted: false,
      );
      final firestore = FirestoreInstance();

      firestore.setMentor(mentor);
      firestore.updateInitialCourseMentor(
          FirestoreInstance().getFirebaseUser().email.toString(),
          mentor.mentorId);
      isLoading.value = false;
      return Future<bool>.value(true);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return Future<bool>.value(false);
    }
  }

  Future<bool> updateMentorInformation() async {
    try {
      isLoading.value = true;
      final firebaseID = FirestoreInstance().getFirebaseUser().uid;

      String mentorID = await FirestoreInstance().getMentorID(firebaseID);

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
        mentorRegStartTime: parseTime(mentorRegStartTime.text),
        mentorRegEndTime: parseTime(mentorRegEndTime.text),
        mentorStatus: 'active',
        mentorSoftDeleted: false,
      );
      final firestore = FirestoreInstance();

      firestore.setMentor(mentor);
      clearController();
      isLoading.value = false;
      return Future<bool>.value(true);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return Future<bool>.value(false);
    }
  }

  void clearController() {
    mentorId.clear();
    accountId.clear();
    mentorYearLvl.clear();
    mentorAbout.clear();
    mentorSessionCompleted.clear();
    mentorLanguages.clear();
    mentorFbUrl.clear();
    mentorGitUrl.clear();
    mentorExpHeader.clear();
    mentorMotto.clear();
    mentorExpertise.clear();
    mentorExpDesc.clear();
    mentorRegDay.clear();
    mentorRegStartTime.clear();
    mentorRegEndTime.clear();
    mentorStatus.clear();
    mentorSoftDeleted.clear();
  }

  TimeOfDay parseTime(String time) {
    final timeString = time.trim().toLowerCase().replaceAll(' ', '');
    final isPM = timeString.contains('pm');
    final parts = timeString.replaceAll(RegExp(r'[^\d:]'), '').split(':');

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (isPM && hour < 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }
}
