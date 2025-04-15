import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';

import '../../authentication/models/user_model.dart';

class MenteeScheduleController extends GetxController {
  static MenteeScheduleController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Public getter to access current user email
  String get currentUserEmail => _auth.currentUser?.email ?? "";

  Future<String> getUserIdThroughEmail(String email) async {
    try {
      final userSnapshot = await _db
          .collection('users')
          .where('accountApiEmail', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception("No user found with email: $email");
      }

      final userId = userSnapshot.docs.first.id;

      final menteeSnapshot = await _db
          .collection('mentee')
          .where('accountId', isEqualTo: userId)
          .get();

      if (menteeSnapshot.docs.isEmpty) {
        throw Exception("No mentee found with accountId: $userId");
      }

      return menteeSnapshot.docs.first.id;
    } catch (e) {
      print("❌ Error in getUserIdThroughEmail: $e");
      rethrow;
    }
  }

  Future<List<String>> getCourseMentorIdsForMentee(String menteeId) async {
    try {
      final allocations = await _db
          .collection('menteeCourseAlloc')
          .where('menteeId', isEqualTo: menteeId)
          .where('mcaSoftDeleted', isEqualTo: false)
          .get();

      return allocations.docs
          .map((doc) => doc.data()['courseMentorId'] as String)
          .toList();
    } catch (e) {
      print("❌ Error getting course mentor IDs 1: $e");
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
      print("❌ Error fetching schedule sessions: $e");
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
      print("❌ Error getting day of the week: $e");
      throw Exception("Failed to fetch day of the week: $e");
    }
  }

  Future<bool> hasRegScheduleToday(String day) async {
    try {
      final userId = await getUserIdThroughEmail(currentUserEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return false;

      // Get mentor details for each course mentor
      final mentors =
          await Future.wait(courseMentorIds.map((courseMentorId) async {
        final mentorSnapshot =
            await _db.collection('courseMentor').doc(courseMentorId).get();
        final mentorId = mentorSnapshot.data()?['mentorId'] as String? ?? '';
        final mentorDoc = await _db.collection('mentor').doc(mentorId).get();
        return MentorModel.fromJson(mentorDoc.data() as Map<String, dynamic>);
      }));

      // Check if any mentor has this day as a regular day
      return mentors.any((mentor) => mentor.mentorRegDay.contains(day));
    } catch (e) {
      print("❌ Error checking regular schedule: $e");
      throw Exception("Failed to check schedule: $e");
    }
  }

  Future<List<ScheduleModel>> getScheduleByDay(String date) async {
    try {
      DateTime parsedDate = DateTime.parse(date);
      DateTime startOfDay =
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      DateTime endOfDay = DateTime(
          parsedDate.year, parsedDate.month, parsedDate.day, 23, 59, 59);

      final userId = await getUserIdThroughEmail(currentUserEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return [];

      final snapshot = await _db
          .collection('schedule')
          .where('courseMentorId', whereIn: courseMentorIds)
          .where('scheduleSoftDelete', isEqualTo: false)
          .where('scheduleDate', isGreaterThanOrEqualTo: startOfDay)
          .where('scheduleDate', isLessThanOrEqualTo: endOfDay)
          .get();

      return snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("❌ Error fetching schedule by day: $e");
      throw Exception("Failed to fetch schedule sessions: $e");
    }
  }

  Future<MentorModel> getMentorDetails() async {
    try {
      final userId = await getUserIdThroughEmail(currentUserEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) {
        throw Exception("No course mentors found for this mentee");
      }

      // Get the first course mentor's mentor details
      final courseMentorDoc =
          await _db.collection('courseMentor').doc(courseMentorIds.first).get();
      final mentorId = courseMentorDoc.data()?['mentorId'] as String? ?? '';
      final mentorDoc = await _db.collection('mentor').doc(mentorId).get();

      return MentorModel.fromJson(mentorDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print("❌ Error fetching mentor details: $e");
      throw Exception("Failed to fetch mentor details: $e");
    }
  }

  Future<List<UserModel>> getMentorsForUpcoming(String email) async {
    try {
      final userId = await getUserIdThroughEmail(email);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return [];

      final now = DateTime.now();

      // Step 1: Fetch upcoming schedules
      final scheduleSnapshot = await _db
          .collection('schedule')
          .where('courseMentorId', whereIn: courseMentorIds)
          .where('scheduleSoftDelete', isEqualTo: false)
          .get();

      // Step 2: Filter only future schedules
      final upcomingSchedules = scheduleSnapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data()))
          .where((schedule) => schedule.scheduleDate.isAfter(now))
          .toList();

      if (upcomingSchedules.isEmpty) return [];

      // Step 3: Extract courseMentorIds from upcoming schedules
      final upcomingCourseMentorIds =
          upcomingSchedules.map((s) => s.courseMentorId).toList();

      List<UserModel> mentorUsers = [];

      for (final courseMentorId in upcomingCourseMentorIds) {
        // Get courseMentor document
        final courseMentorDoc =
            await _db.collection('courseMentor').doc(courseMentorId).get();

        final courseMentorData = courseMentorDoc.data();
        if (courseMentorData == null || courseMentorData['mentorId'] == null) {
          continue;
        }

        final mentorId = courseMentorData['mentorId'];

        // Get mentor document
        final mentorDoc = await _db.collection('mentors').doc(mentorId).get();
        final mentorData = mentorDoc.data();

        if (mentorData == null || mentorData['accountId'] == null) {
          continue;
        }

        final accountId = mentorData['accountId'];

        // Get user document
        final userDoc = await _db.collection('users').doc(accountId).get();
        final userData = userDoc.data();
        if (userData != null) {
          mentorUsers.add(
              UserModel.fromJson(userData)); // Append mentor even if repeating
        }
      }

      return mentorUsers;
    } catch (e) {
      print("❌ Error fetching mentors with upcoming schedules: $e");
      return [];
    }
  }

  Future<List<ScheduleModel>> getUpcomingScheduleForMentee(String email) async {
    try {
      final userId = await getUserIdThroughEmail(email);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return [];

      final now = DateTime.now();

      final snapshot = await _db
          .collection('schedule')
          .where('courseMentorId', whereIn: courseMentorIds)
          .where('scheduleSoftDelete', isEqualTo: false)
          .get();

      final upcoming = snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data()))
          .where((schedule) => schedule.scheduleDate.isAfter(now))
          .toList();

      upcoming.sort((a, b) => a.scheduleDate.compareTo(b.scheduleDate));
      return upcoming;
    } catch (e) {
      print("❌ Error fetching upcoming mentee schedule: $e");
      return [];
    }
  }

  Future<List<UserModel>> getMentorsForCompleted(String email) async {
    try {
      final userId = await getUserIdThroughEmail(email);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return [];

      final now = DateTime.now();

      // Step 1: Fetch all schedules for this mentee that are completed
      final scheduleSnapshot = await _db
          .collection('schedule')
          .where('courseMentorId', whereIn: courseMentorIds)
          .where('scheduleSoftDelete', isEqualTo: false)
          .get();

      // Step 2: Filter only past schedules
      final completedSchedules = scheduleSnapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data()))
          .where((schedule) => schedule.scheduleDate.isBefore(now))
          .toList();

      if (completedSchedules.isEmpty) return [];

      // Step 3: Extract courseMentorIds from completed schedules
      final completedCourseMentorIds =
          completedSchedules.map((s) => s.courseMentorId).toList();

      List<UserModel> mentorUsers = [];

      for (final courseMentorId in completedCourseMentorIds) {
        // Get courseMentor document
        final courseMentorDoc =
            await _db.collection('courseMentor').doc(courseMentorId).get();

        final courseMentorData = courseMentorDoc.data();
        if (courseMentorData == null || courseMentorData['mentorId'] == null) {
          continue;
        }

        final mentorId = courseMentorData['mentorId'];

        // Get mentor document
        final mentorDoc = await _db.collection('mentors').doc(mentorId).get();
        final mentorData = mentorDoc.data();

        if (mentorData == null || mentorData['accountId'] == null) {
          continue;
        }

        final accountId = mentorData['accountId'];

        // Get user document
        final userDoc = await _db.collection('users').doc(accountId).get();
        final userData = userDoc.data();
        if (userData != null) {
          mentorUsers.add(
              UserModel.fromJson(userData)); // Append mentor even if repeating
        }
      }
      print("❌ Mentors with completed schedules: $mentorUsers");
      return mentorUsers;
    } catch (e) {
      print("❌ Error fetching mentors with completed schedules: $e");
      return [];
    }
  }

  Future<List<ScheduleModel>> getCompletedScheduleForMentee(
      String email) async {
    try {
      final userId = await getUserIdThroughEmail(email);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return [];

      final now = DateTime.now();

      final snapshot = await _db
          .collection('schedule')
          .where('courseMentorId', whereIn: courseMentorIds)
          .where('scheduleSoftDelete', isEqualTo: false)
          .get();

      final completed = snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data()))
          .where((schedule) => schedule.scheduleDate.isBefore(now))
          .toList();

      completed.sort((a, b) => b.scheduleDate.compareTo(a.scheduleDate));
      return completed;
    } catch (e) {
      print("❌ Error fetching completed mentee schedule: $e");
      return [];
    }
  }

  Future<String> getCourseNameFromCourseMentorId(String courseMentorId) async {
    try {
      // Step 1: Get the courseMentor document
      final courseMentorDoc =
          await _db.collection('courseMentor').doc(courseMentorId).get();
      final courseMentorData = courseMentorDoc.data();

      if (courseMentorData == null || courseMentorData['courseId'] == null) {
        throw Exception("Course ID not found in courseMentor document");
      }

      final courseId = courseMentorData['courseId'];

      // Step 2: Get the course document
      final courseDoc = await _db.collection('course').doc(courseId).get();
      final courseData = courseDoc.data();

      if (courseData == null || courseData['courseName'] == null) {
        throw Exception("Course name not found in course document");
      }

      return courseData['courseName'];
    } catch (e) {
      print("❌ Error fetching course name: $e");
      throw Exception("Failed to fetch course name: $e");
    }
  }
}
