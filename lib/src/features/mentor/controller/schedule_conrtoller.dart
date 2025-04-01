import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class ScheduleConrtoller extends GetxController {
  static ScheduleConrtoller get instance => Get.find();

  final scheduleStartTime = TextEditingController();
  final scheduleEndTime = TextEditingController();
  final scheduleDate = TextEditingController();
  final scheduleMentorId = TextEditingController();
  final scheduleMenteeId = TextEditingController();
  final scheduleSoftDelete = TextEditingController();
  final scheduleRoomName = TextEditingController();
  final scheduleDescription = TextEditingController();
  final scheduleTitle = TextEditingController();

  FirestoreInstance firestore = Get.put(FirestoreInstance());
  Future<void> generateSchedule() async {
    try {
      print("Generating schedule...");
      String mentor =
          await firestore.getMentorID(FirebaseAuth.instance.currentUser!.uid);
      print("Mentor ID: ${mentor}");
      String courseMentorId = await firestore
          .getCourseMentorDocId(mentor); // Get the course mentor ID
      // Implement your schedule generation logic here
      // For example, you can call an API or perform some calculations
      // based on the provided schedule details.
      final ScheduleModel scheduleData = ScheduleModel(
        courseMentorId: courseMentorId,
        scheduleCreatedTimestamp: DateTime.now(),
        scheduleStartTime: scheduleStartTime.text,
        scheduleEndTime: scheduleEndTime.text,
        scheduleDate: DateTime.parse(scheduleDate.text),
        scheduleSoftDelete: false,
        scheduleRoomName: scheduleRoomName.text,
        scheduleDescription: scheduleDescription.text,
        scheduleTitle: scheduleTitle.text,
        scheduleModifiedTimestamp: DateTime.now(),
      );
      await firestore.setSchedule(scheduleData);
      PostContentModel postContentModel = PostContentModel(
        contentCategory: 'Announcement',
        contentCreatedTimestamp: DateTime.now(),
        contentDescription: scheduleDescription.text,
        contentFiles: [],
        contentImage: [],
        contentModifiedTimestamp: DateTime.now(),
        contentSoftDelete: false,
        contentTitle: scheduleTitle.text,
        contentVideo: [],
        courseMentorId: courseMentorId,
        contentLinks: [],
      );
      await firestore.uploadPostContent(postContentModel);
      print("Schedule data: ${scheduleData.toJson()}");
      print("Schedule generated successfully!");
    } catch (e) {
      print("Error generating schedule: $e");
      throw Exception("Failed to fetch schedule sessions: $e");
    }
  }

  Future<List<ScheduleModel>> getCompletedSchedule() async {
    try {
      String mentor =
          await firestore.getMentorID(FirebaseAuth.instance.currentUser!.uid);
      print("Mentor ID: ${mentor}");
      String courseMentorId = await firestore.getCourseMentorDocId(mentor);

      return await firestore.getCompletedSchedule(courseMentorId);
    } catch (e) {
      print("Error generating schedule: $e");
      throw Exception("Failed to fetch schedule sessions: $e");
    }
  }

  Future<List<ScheduleModel>> getUpcomingSchedule() async {
    try {
      String mentor =
          await firestore.getMentorID(FirebaseAuth.instance.currentUser!.uid);
      print("Mentor ID: ${mentor}");
      String courseMentorId = await firestore.getCourseMentorDocId(mentor);
      return await firestore.getUpcomingSchedule(courseMentorId);
    } catch (e) {
      print("Error generating schedule: $e");
      throw Exception("Failed to fetch schedule sessions: $e");
    }
  }

  Future<List<ScheduleModel>> getScheduleSession() async {
    try {
      String mentor =
          await firestore.getMentorID(FirebaseAuth.instance.currentUser!.uid);
      print("Mentor ID: ${mentor}");
      String courseMentorId = await firestore
          .getCourseMentorDocId(mentor); // Get the course mentor ID
      return await firestore.getSchedule(courseMentorId);
    } catch (e) {
      print("Error generating schedule: $e");
      throw Exception("Failed to fetch schedule sessions: $e");
    }
  }

  Future<String> getDayOfTheWeek(DateTime selectedDay) async {
    try {
      List<String> days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      int dayIndex = selectedDay.weekday - 1; // Adjust for 0-based index
      return days[dayIndex];
    } catch (e) {
      Get.log("Error getting day of the week: $e", isError: true);
      throw Exception("Failed to fetch day of the week: $e");
    }
  }

  Future<bool> hasRegScheduleToday(String day) async {
    try {
      List<String> regDays = await firestore
          .getRegularDayOfWeek(FirebaseAuth.instance.currentUser!.uid);
      //String currentDay = DateTime.now().weekday.toString();
      print(regDays);
      //  print(currentDay);
      print(regDays.contains(day));
      // print("Current day: $currentDay");
      return regDays.contains(day);
    } catch (e) {
      print("Error checking schedule: $e");
      throw Exception("Failed to check schedule: $e");
    }
  }

  Future<List<ScheduleModel>> getScheduleByDay(String date) async {
    try {
      print("getting schedule for date: $date");
      DateTime parsedDate = DateTime.parse(date);
      print("Parsed date: $parsedDate");
      DateTime dateOnly =
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      print("Date only: $dateOnly");
      print(await firestore.getScheduleByDay(dateOnly));
      print("done");
      return await firestore.getScheduleByDay(dateOnly);
    } catch (e) {
      print("Error getting schedule: $e");
      throw Exception("Failed to fetch schedule sessions: $e");
    }
  }

  Future<MentorModel> getMentorDetails() async {
    try {
      return await firestore
          .getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      print("Error getting mentor details: $e");
      throw Exception("Failed to fetch mentor details: $e");
    }
  }
}
