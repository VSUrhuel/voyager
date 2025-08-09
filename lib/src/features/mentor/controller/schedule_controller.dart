import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class ScheduleController extends GetxController {
  static ScheduleController get instance => Get.find();

  // Service instances
  final _firestore = FirestoreInstance();
  final _auth = FirebaseAuth.instance;

  // Form controllers
  final scheduleStartTime = TextEditingController();
  final scheduleEndTime = TextEditingController();
  final scheduleDate = TextEditingController();
  final scheduleRoomName = TextEditingController();
  final scheduleDescription = TextEditingController();
  final scheduleTitle = TextEditingController();
  final scheduleMenteeId = TextEditingController();
  final scheduleMentorId = TextEditingController();

  @override
  void onClose() {
    // Dispose all text controllers to prevent memory leaks
    scheduleStartTime.dispose();
    scheduleEndTime.dispose();
    scheduleDate.dispose();
    scheduleRoomName.dispose();
    scheduleDescription.dispose();
    scheduleTitle.dispose();
    scheduleMenteeId.dispose();
    scheduleMentorId.dispose();
    super.onClose();
  }

  /// Parses a time string (e.g., "5:30 PM") into 24-hour format ("17:30").
  String _format24HourTime(String timeInput) {
    try {
      final time = timeInput.replaceAll(' ', '').toUpperCase();
      final is12HourFormat = time.contains('AM') || time.contains('PM');
      final timePart = time.replaceAll('AM', '').replaceAll('PM', '');

      if (!timePart.contains(':')) {
        throw const FormatException('Invalid time format - missing colon');
      }

      final parts = timePart.split(':');
      if (parts.length != 2) throw const FormatException('Invalid time format');

      int hours = int.parse(parts[0]);
      final int minutes = int.parse(parts[1]);

      if (minutes < 0 || minutes > 59) {
        throw const FormatException('Invalid minute value');
      }

      if (is12HourFormat) {
        if (time.contains('PM') && hours != 12) hours += 12;
        if (time.contains('AM') && hours == 12) hours = 0;
      }

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      throw FormatException(
          'Invalid time format: $timeInput. Please use HH:mm or HH:mm AM/PM format.');
    }
  }

  /// Combines a date string and a time string into a single DateTime object.
  DateTime _parseDateWithTime(String dateString, String timeString) {
    try {
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
      rethrow;
    }
  }

  /// Private helper to get the course mentor ID for the current user.
  Future<String> _getCourseMentorId() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User is not authenticated.");
    final mentorId = await _firestore.getMentorID(user.uid);
    return await _firestore.getCourseMentorDocId(mentorId);
  }

  Future<void> generateSchedule() async {
    try {
      final courseMentorId = await _getCourseMentorId();

      final scheduleData = ScheduleModel(
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
      await _firestore.setSchedule(scheduleData);

      final postContentModel = PostContentModel(
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
      await _firestore.uploadPostContent(postContentModel);
    } catch (e) {
      // Use rethrow to preserve the original stack trace for better debugging.
      rethrow;
    }
  }

  Future<List<ScheduleModel>> getCompletedSchedule() async {
    try {
      final courseMentorId = await _getCourseMentorId();
      return await _firestore.getCompletedSchedule(courseMentorId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScheduleModel>> getUpcomingSchedule() async {
    try {
      final courseMentorId = await _getCourseMentorId();
      final upcomingSchedules =
          await _firestore.getUpcomingSchedule(courseMentorId);

      // Sort the schedules by start time.
      upcomingSchedules.sort((a, b) => _firestore
          .parseTimeString(a.scheduleStartTime)
          .compareTo(_firestore.parseTimeString(b.scheduleStartTime)));

      return upcomingSchedules;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScheduleModel>> getScheduleSession() async {
    try {
      final courseMentorId = await _getCourseMentorId();
      return await _firestore.getSchedule(courseMentorId);
    } catch (e) {
      rethrow;
    }
  }

  String getDayOfTheWeek(DateTime selectedDay) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    // This is a safe operation, no try-catch or async needed.
    return days[selectedDay.weekday - 1];
  }

  Future<bool> hasRegScheduleToday(String day) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User is not authenticated.");
      final regDays = await _firestore.getRegularDayOfWeek(user.uid);
      return regDays.contains(day);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScheduleModel>> getScheduleByDay(String date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User is not authenticated.");
      final parsedDate = DateTime.parse(date);
      final dateOnly =
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      final mentor = await _firestore.getMentorThroughAccId(user.uid);
      final courseMentorId =
          await _firestore.getCourseMentorId(mentor.mentorId);
      return await _firestore.getScheduleByDay(dateOnly, courseMentorId);
    } catch (e) {
      rethrow;
    }
  }

  Future<MentorModel> getMentorDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User is not authenticated.");
      return await _firestore.getMentorThroughAccId(user.uid);
    } catch (e) {
      rethrow;
    }
  }
}
