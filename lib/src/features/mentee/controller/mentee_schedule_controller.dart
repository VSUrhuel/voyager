import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';

class MenteeScheduleController extends GetxController {
  static MenteeScheduleController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserEmail => _auth.currentUser?.email ?? "";

  Future<String> getUserIdThroughEmail(String email) async {
    try {
      final userSnapshot = await _db
          .collection('users')
          .where('accountApiEmail', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception("No user found with email: $email");
      }

      final userId = userSnapshot.docs.first.id;

      final menteeSnapshot = await _db
          .collection('mentee')
          .where('accountId', isEqualTo: userId)
          .limit(1)
          .get();

      if (menteeSnapshot.docs.isEmpty) {
        throw Exception("No mentee found with accountId: $userId");
      }

      return menteeSnapshot.docs.first.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getCourseMentorIdsForMentee(String menteeId) async {
    try {
      final allocations = await _db
          .collection('menteeCourseAlloc')
          .where('menteeId', isEqualTo: menteeId)
          .where('mcaAllocStatus', isEqualTo: 'accepted')
          .where('mcaSoftDeleted', isEqualTo: false)
          .get();

      return allocations.docs
          .map((doc) => doc.data()['courseMentorId'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ScheduleModel>> getScheduleSession() async {
    try {
      final userId = await getUserIdThroughEmail(currentUserEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return [];

      final snapshot = await _db
          .collection('schedule')
          .where('courseMentorId', whereIn: courseMentorIds)
          .where('scheduleSoftDelete', isEqualTo: false)
          .get();

      return snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  String getDayOfTheWeek(DateTime selectedDay) {
    const List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[selectedDay.weekday - 1];
  }

  Future<List<MentorModel>> getRegScheduleToday(String day) async {
    try {
      final userId = await getUserIdThroughEmail(currentUserEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return [];

      final mentors = await Future.wait(
        courseMentorIds.map((courseMentorId) async {
          final mentorSnapshot =
              await _db.collection('courseMentor').doc(courseMentorId).get();
          if (!mentorSnapshot.exists) {
            throw Exception('Mentor mapping not found');
          }

          final mentorId = mentorSnapshot.data()?['mentorId'] as String? ?? '';
          if (mentorId.isEmpty) throw Exception('Mentor ID is empty');

          final mentorDoc = await _db.collection('mentors').doc(mentorId).get();
          if (!mentorDoc.exists) throw Exception('Mentor details not found');

          return MentorModel.fromJson(mentorDoc.data() as Map<String, dynamic>);
        }),
      );

      return mentors
          .where((mentor) => mentor.mentorRegDay.contains(day))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasRegScheduleToday(String day) async {
    try {
      final userId = await getUserIdThroughEmail(currentUserEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return false;

      final mentors = await Future.wait(
        courseMentorIds.map((courseMentorId) async {
          final mentorSnapshot =
              await _db.collection('courseMentor').doc(courseMentorId).get();
          if (!mentorSnapshot.exists) {
            throw Exception('Mentor mapping not found');
          }

          final mentorId = mentorSnapshot.data()?['mentorId'] as String? ?? '';
          if (mentorId.isEmpty) throw Exception('Mentor ID is empty');

          final mentorDoc = await _db.collection('mentors').doc(mentorId).get();
          if (!mentorDoc.exists) throw Exception('Mentor details not found');

          return MentorModel.fromJson(mentorDoc.data() as Map<String, dynamic>);
        }),
      );

      return mentors.any((mentor) => mentor.mentorRegDay.contains(day));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScheduleModel>> getScheduleByDay(String date) async {
    try {
      DateTime queryDate = DateTime.parse(date);
      final userId = await getUserIdThroughEmail(currentUserEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return [];

      final snapshot = await _db
          .collection('schedule')
          .where('courseMentorId', whereIn: courseMentorIds)
          .where('scheduleSoftDelete', isEqualTo: false)
          .get();

      return snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data()))
          .where((schedule) =>
              schedule.scheduleDate.year == queryDate.year &&
              schedule.scheduleDate.month == queryDate.month &&
              schedule.scheduleDate.day == queryDate.day)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<MentorModel> getMentorDetails() async {
    try {
      final userId = await getUserIdThroughEmail(currentUserEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) {
        throw Exception("No course mentors found for this mentee");
      }
      final courseMentorDoc =
          await _db.collection('courseMentor').doc(courseMentorIds.first).get();
      final mentorId = courseMentorDoc.data()?['mentorId'] as String? ?? '';
      final mentorDoc = await _db.collection('mentors').doc(mentorId).get();

      return MentorModel.fromJson(mentorDoc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Refactored helper to fetch schedules based on a time condition.
  Future<List<ScheduleModel>> _getSchedulesByTimeCondition(
      String email, bool Function(DateTime) condition) async {
    final userId = await getUserIdThroughEmail(email);
    final courseMentorIds = await getCourseMentorIdsForMentee(userId);

    if (courseMentorIds.isEmpty) return [];

    final snapshot = await _db
        .collection('schedule')
        .where('courseMentorId', whereIn: courseMentorIds)
        .where('scheduleSoftDelete', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) => ScheduleModel.fromJson(doc.data()))
        .where((schedule) => condition(schedule.scheduleDate))
        .toList();
  }

  Future<List<ScheduleModel>> getUpcomingScheduleForMentee(String email) async {
    try {
      final now = DateTime.now();
      final upcoming = await _getSchedulesByTimeCondition(
          email, (date) => date.isAfter(now));
      upcoming.sort((a, b) => a.scheduleDate.compareTo(b.scheduleDate));
      return upcoming;
    } catch (e) {
      return [];
    }
  }

  Future<List<ScheduleModel>> getCompletedScheduleForMentee(
      String email) async {
    try {
      final now = DateTime.now();
      final completed = await _getSchedulesByTimeCondition(
          email, (date) => date.isBefore(now));
      completed.sort((a, b) => b.scheduleDate.compareTo(a.scheduleDate));
      return completed;
    } catch (e) {
      return [];
    }
  }

  /// Refactored helper to fetch mentors based on schedules.
  Future<List<UserModel>> _getMentorsFromSchedules(
      List<ScheduleModel> schedules) async {
    if (schedules.isEmpty) return [];

    final courseMentorIds =
        schedules.map((s) => s.courseMentorId).toSet().toList();
    List<UserModel> mentorUsers = [];

    for (final courseMentorId in courseMentorIds) {
      try {
        final courseMentorDoc =
            await _db.collection('courseMentor').doc(courseMentorId).get();
        final courseMentorData = courseMentorDoc.data();
        if (courseMentorData == null || courseMentorData['mentorId'] == null) {
          continue;
        }

        final mentorId = courseMentorData['mentorId'];
        final mentorDoc = await _db.collection('mentors').doc(mentorId).get();
        final mentorData = mentorDoc.data();
        if (mentorData == null || mentorData['accountId'] == null) continue;

        final accountId = mentorData['accountId'];
        final userDoc = await _db.collection('users').doc(accountId).get();
        final userData = userDoc.data();
        if (userData != null) {
          mentorUsers.add(UserModel.fromJson(userData));
        }
      } catch (e) {
        // Log this error silently if needed, but continue the loop
        continue;
      }
    }
    return mentorUsers;
  }

  Future<List<UserModel>> getMentorsForUpcoming(String email) async {
    try {
      final upcomingSchedules = await getUpcomingScheduleForMentee(email);
      return await _getMentorsFromSchedules(upcomingSchedules);
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getMentorsForCompleted(String email) async {
    try {
      final completedSchedules = await getCompletedScheduleForMentee(email);
      return await _getMentorsFromSchedules(completedSchedules);
    } catch (e) {
      return [];
    }
  }

  Future<String> getCourseNameFromCourseMentorId(String courseMentorId) async {
    try {
      final courseMentorDoc =
          await _db.collection('courseMentor').doc(courseMentorId).get();
      final courseMentorData = courseMentorDoc.data();

      if (courseMentorData == null || courseMentorData['courseId'] == null) {
        throw Exception("Course ID not found in courseMentor document");
      }

      final courseId = courseMentorData['courseId'];
      final courseDoc = await _db.collection('course').doc(courseId).get();
      final courseData = courseDoc.data();

      if (courseData == null || courseData['courseName'] == null) {
        throw Exception("Course name not found in course document");
      }

      return courseData['courseName'];
    } catch (e) {
      rethrow;
    }
  }
}
