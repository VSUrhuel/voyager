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

  String _format24HourTime(String timeInput) {
    try {
      // Remove all spaces and convert to uppercase
      final time = timeInput.replaceAll(' ', '').toUpperCase();

      // Check if it contains AM/PM marker
      final is12HourFormat = time.contains('AM') || time.contains('PM');

      // Extract the numeric part
      final timePart = time.replaceAll('AM', '').replaceAll('PM', '');

      if (!timePart.contains(':')) {
        throw FormatException('Invalid time format - missing colon');
      }

      final parts = timePart.split(':');
      if (parts.length != 2) throw FormatException('Invalid time format');

      int hours = int.parse(parts[0]);
      final int minutes = int.parse(parts[1]);

      // Validate time components

      if (minutes < 0 || minutes > 59) {
        throw FormatException('Invalid minute value');
      }

      // Convert 12-hour to 24-hour format
      if (is12HourFormat) {
        if (time.contains('PM') && hours != 12) {
          hours += 12;
        } else if (time.contains('AM') && hours == 12) {
          hours = 0;
        }
      }

      // Format with leading zeros
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      throw FormatException(
          'Invalid time format: $timeInput. Please use HH:mm or HH:mm AM/PM format');
    }
  }

  DateTime _parseDateWithTime(String dateString, String timeString) {
    try {
      print(timeString);
      final date = DateTime.parse(dateString);
      final formattedTime = _format24HourTime(timeString);
      final timeParts = formattedTime.split(':');

      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]), // hours
        int.parse(timeParts[1]), // minutes
      );
    } catch (e) {
      throw FormatException('Failed to combine date and time: $e');
    }
  }

  FirestoreInstance firestore = Get.put(FirestoreInstance());
  Future<void> generateSchedule() async {
    try {
      String mentor =
          await firestore.getMentorID(FirebaseAuth.instance.currentUser!.uid);

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
        scheduleDate:
            _parseDateWithTime(scheduleDate.text, scheduleStartTime.text),
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
    } catch (e) {
      throw Exception("Failed to fetch schedule sessions: $e");
    }
  }

  Future<List<ScheduleModel>> getCompletedSchedule() async {
    try {
      String mentor =
          await firestore.getMentorID(FirebaseAuth.instance.currentUser!.uid);

      String courseMentorId = await firestore.getCourseMentorDocId(mentor);

      return await firestore.getCompletedSchedule(courseMentorId);
    } catch (e) {
      throw Exception("Failed to fetch schedule sessions: $e");
    }
  }

  Future<List<ScheduleModel>> getUpcomingSchedule() async {
    try {
      String mentor =
          await firestore.getMentorID(FirebaseAuth.instance.currentUser!.uid);

      String courseMentorId = await firestore.getCourseMentorDocId(mentor);
      List<ScheduleModel> upcomingSchedules =
          await firestore.getUpcomingSchedule(courseMentorId);

      // Sort the schedules by time posted (scheduleStartTime)
      upcomingSchedules.sort((a, b) => firestore
          .parseTimeString(a.scheduleStartTime)
          .compareTo(firestore.parseTimeString(b.scheduleStartTime)));

      return upcomingSchedules;
    } catch (e) {
      throw Exception("Failed to fetch schedule sessions: $e");
    }
  }

  Future<List<ScheduleModel>> getScheduleSession() async {
    try {
      String mentor =
          await firestore.getMentorID(FirebaseAuth.instance.currentUser!.uid);

      String courseMentorId = await firestore
          .getCourseMentorDocId(mentor); // Get the course mentor ID
      return await firestore.getSchedule(courseMentorId);
    } catch (e) {
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

      return regDays.contains(day);
    } catch (e) {
      throw Exception("Failed to check schedule: $e");
    }
  }

  Future<List<ScheduleModel>> getScheduleByDay(String date) async {
    try {
      DateTime parsedDate = DateTime.parse(date);
      DateTime dateOnly =
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      MentorModel mentor = await firestore
          .getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);
      String courseMentorId =
          await firestore.getCourseMentorId(mentor.mentorId);
      return await firestore.getScheduleByDay(dateOnly, courseMentorId);
    } catch (e) {
      throw Exception("Failed to fetch schedule sessions: $e");
    }
  }

  Future<MentorModel> getMentorDetails() async {
    try {
      return await firestore
          .getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      throw Exception("Failed to fetch mentor details: $e");
    }
  }
}
