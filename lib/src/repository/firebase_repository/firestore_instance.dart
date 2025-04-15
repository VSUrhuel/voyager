import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/model/mentee_model.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';

class FirestoreInstance {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.accountApiID).set(user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getUserRole(String uid) async {
    try {
      final user = await _db.collection('users').doc(uid).get();
      if (user.exists) {
        return user.data()!['accountRole'];
      } else {
        return 'mentee';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostContentModel>> getPostContentThroughCourseMentor(
      String id) async {
    try {
      final postContent = await _db
          .collection('postContent')
          .where('courseMentorId', isEqualTo: id)
          .get();
      return postContent.docs
          .map((doc) => PostContentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setUserFromGoogle(Rx<User>? user) async {
    try {
      if (user?.value == null) {
        throw Exception('User is null');
      }
      String? userEmail = user?.value.email;
      String? userUid = user?.value.uid;

      final auth = Get.put(FirebaseAuthenticationRepository());
// Ensure required fields are not null
      if (userUid == null || userEmail == null) {
        throw Exception("User UID or Email is null");
      }

      if ((await getAPIId()).contains(auth.firebaseUser.value?.uid)) {
        return;
      }

      await _db.collection('users').doc(userUid).set({
        'accountApiID':
            auth.firebaseUser.value?.uid ?? "", // Use empty string if null
        'accountApiEmail':
            auth.firebaseUser.value?.email ?? "", // Provide a default
        'accountApiName': auth.firebaseUser.value?.displayName ??
            "Unknown", // Provide default name
        'accountApiPhoto': auth.firebaseUser.value?.photoURL ??
            "https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture//profile.png", // Handle null safely
        'accountPassword': '',
        'accountUsername': auth.firebaseUser.value?.displayName ??
            "Unknown", // Provide default username
        'accountRole': await FirestoreInstance().getUserRole(userUid),
        'accountStudentId': '',
        'accountCreatedTimestamp': DateTime.now(),
        'accountModifiedTimestamp': DateTime.now(),
        'accountSoftDeleted': false,
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
      rethrow;
    }
  }

  Future<String> getUsername(String id) async {
    try {
      final user = await _db.collection('users').doc(id).get();
      if (user.exists) {
        return user.data()!['accountUsername'];
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getAccountPhoto(String id) async {
    try {
      final user = await _db.collection('users').doc(id).get();
      if (user.exists) {
        return user.data()!['accountApiPhoto'];
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUsername(String username, String uid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'accountUsername': username,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfileImage(String url, String uid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'accountApiPhoto': url,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStudentID(String studentID, String uid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'accountStudentId': studentID,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getUserIDs() async {
    try {
      final users = await _db.collection('users').get();
      return users.docs.map((doc) => doc.id).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setMentor(MentorModel mentor) async {
    try {
      final mentorDoc =
          await _db.collection('mentors').doc(mentor.mentorId).get();
      if (mentorDoc.exists) {
        await _db
            .collection('mentors')
            .doc(mentor.mentorId)
            .update(mentor.toJson());

        return;
      }
      await _db.collection('mentors').doc(mentor.mentorId).set(mentor.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<MentorModel> getMentor(String id) async {
    try {
      final mentor = await _db.collection('mentors').doc(id).get();
      return MentorModel.fromJson(mentor.data()!);
    } catch (e) {
      rethrow;
    }
  }

  Future<CourseMentorModel> getCourseMentorThroughMentor(
      String mentorId) async {
    try {
      final courseMentor = await _db
          .collection('courseMentor')
          .where('mentorId', isEqualTo: mentorId)
          .where('courseMentorSoftDeleted', isEqualTo: false)
          .limit(1)
          .get();
      if (courseMentor.docs.isEmpty) {
        throw Exception('No mentor found with ID: $mentorId');
      }

      return CourseMentorModel.fromJson(courseMentor.docs.first.data());
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getCourseMentorDocId(String mentorId) async {
    try {
      final courseMentor = await _db
          .collection('courseMentor')
          .where('mentorId', isEqualTo: mentorId)
          .where('courseMentorSoftDeleted', isEqualTo: false)
          .limit(1)
          .get();
      if (courseMentor.docs.isEmpty) {
        throw Exception('No mentor found with ID: $mentorId');
      }

      return courseMentor.docs.first.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setSchedule(ScheduleModel schedule) async {
    try {
      String uniqueID = generateUniqueId();
      await _db.collection('schedule').doc(uniqueID).set({
        'courseMentorId': schedule.courseMentorId,
        'scheduleCreatedTimestamp': schedule.scheduleCreatedTimestamp,
        'scheduleDate': schedule.scheduleDate,
        'scheduleDescription': schedule.scheduleDescription,
        'scheduleEndTime': schedule.scheduleEndTime,
        'scheduleModifiedTimestamp': schedule.scheduleModifiedTimestamp,
        'scheduleRoomName': schedule.scheduleRoomName,
        'scheduleSoftDelete': schedule.scheduleSoftDelete,
        'scheduleStartTime': schedule.scheduleStartTime,
        'scheduleTitle': schedule.scheduleTitle,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<String> courseMentor(String mentorId) async {
    try {
      final courseMentor = await _db
          .collection('courseMentor')
          .where('mentorId', isEqualTo: mentorId)
          .where('courseMentorSoftDeleted', isEqualTo: false)
          .limit(1)
          .get();
      if (courseMentor.docs.isEmpty) {
        throw Exception('No mentor found with ID: $mentorId');
      }

      return courseMentor.docs.first.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<MentorModel> getMentorThroughStudentId(String studentId) async {
    try {
      final mentor = await _db
          .collection('mentors')
          .where('accountStudentId', isEqualTo: studentId)
          .where('mentorSoftDeleted', isEqualTo: false)
          .get();
      return MentorModel.fromJson(mentor.docs.first.data());
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getMentorThroughCourseMentorId(String courseMentorId) async {
    try {
      final mentor = await _db
          .collection('courseMentor')
          .where('courseMentorId', isEqualTo: courseMentorId)
          .get();

      return mentor.docs.first.data()['mentorId'];
    } catch (e) {
      rethrow;
    }
  }

  Future<MentorModel> getMentorThroughAccId(String accId) async {
    try {
      final mentor = await _db
          .collection('mentors')
          .where('accountId', isEqualTo: accId)
          .where('mentorSoftDeleted', isEqualTo: false)
          .get();
      return MentorModel.fromJson(mentor.docs.first.data());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScheduleModel>> getScheduleByDay(
      DateTime date, String courseMentorId) async {
    try {
      DateTime dateOnly = DateTime(date.year, date.month, date.day);
      DateTime nextDay = dateOnly.add(Duration(days: 1));
      final schedule = await _db
          .collection('schedule')
          .where('scheduleDate', isGreaterThanOrEqualTo: dateOnly)
          .where('scheduleDate', isLessThan: nextDay)
          .orderBy('scheduleDate')
          .get();

      if (schedule.docs.isNotEmpty) {
        return schedule.docs
            .where((doc) => doc['courseMentorId'] == courseMentorId)
            .map((doc) => ScheduleModel.fromJson(doc.data()))
            .toList();
      } else {
        return [];
        //  throw Exception('No schedule found for the given date');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getRegularDayOfWeek(String id) async {
    try {
      final days = await _db
          .collection('mentors')
          .where('accountId', isEqualTo: id)
          .get();
      if (days.docs.isNotEmpty) {
        return days.docs.first.data()['mentorRegDay'].cast<String>();
      } else {
        throw Exception('No mentor found with ID: $id');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScheduleModel>> getUpcomingSchedule(String courseMentorId) async {
    try {
      final snapshot = await _db
          .collection('schedule')
          .where('courseMentorId', isEqualTo: courseMentorId)
          .get();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day); // Strips time

      return snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data()))
          .where((schedule) {
        final scheduleDate = schedule.scheduleDate;
        final startTime = parseTimeString(schedule.scheduleStartTime);

        if (scheduleDate.isBefore(today)) {
          return false; // Past date, ignore
        }

        if (scheduleDate.year == now.year &&
            scheduleDate.month == now.month &&
            scheduleDate.day == now.day) {
          // Check if the schedule is today
          final currentTime = TimeOfDay.now();
          return startTime.hour > currentTime.hour ||
              (startTime.hour == currentTime.hour &&
                  startTime.minute > currentTime.minute);
        } else {
          // Future date, include it
          return true;
        }
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScheduleModel>> getCompletedSchedule(
      String courseMentorId) async {
    try {
      final snapshot = await _db
          .collection('schedule')
          .where('courseMentorId', isEqualTo: courseMentorId)
          .get();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day); // Strips time

      return snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data()))
          .where((schedule) {
        final scheduleDate = schedule.scheduleDate;
        final startTime = parseTimeString(schedule.scheduleStartTime);

        if (scheduleDate.isAfter(today)) {
          return false; // Future date, ignore
        }

        if (scheduleDate.year == now.year &&
            scheduleDate.month == now.month &&
            scheduleDate.day == now.day) {
          // Check if the schedule is today
          final currentTime = TimeOfDay.now();
          return startTime.hour < currentTime.hour ||
              (startTime.hour == currentTime.hour &&
                  startTime.minute <= currentTime.minute);
        } else {
          // Past date, include it
          return true;
        }
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  TimeOfDay parseTimeString(String timeString) {
    try {
      // Clean the input string
      final cleanedTime = timeString
          .trim()
          .replaceAll(RegExp(r'[^\w\s:]'), '')
          .replaceAll(RegExp(r'\s+'), ' '); // Normalize spaces

      if (cleanedTime.contains('PM') || cleanedTime.contains('pm')) {
        final timeWithoutSuffix =
            cleanedTime.replaceAll(RegExp(r'[APMapm]'), '').trim();
        final parts = timeWithoutSuffix.split(':');
        var hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (hour < 12) hour += 12;
        return TimeOfDay(hour: hour, minute: minute);
      } else if (cleanedTime.contains('AM') || cleanedTime.contains('am')) {
        final timeWithoutSuffix =
            cleanedTime.replaceAll(RegExp(r'[APMapm]'), '').trim();
        final parts = timeWithoutSuffix.split(':');
        var hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      } else {
        // 24-hour format
        final parts = cleanedTime.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0); // Return midnight as fallback
    }
  }

  Future<List<ScheduleModel>> getSchedule(String courseMentorId) async {
    try {
      final schedule = await _db
          .collection('schedule')
          .where('courseMentorId', isEqualTo: courseMentorId)
          .get();
      return schedule.docs
          .map((doc) => ScheduleModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getMentorID(String userId) async {
    try {
      final mentor = await _db
          .collection('mentors')
          .where('accountId', isEqualTo: userId)
          .get();
      if (mentor.docs.isNotEmpty) {
        return mentor.docs.first.id;
      } else {
        throw Exception('Mentor not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getMentorIDs() async {
    try {
      final mentors = await _db.collection('mentors').get();
      if (mentors.docs.isEmpty) {
        return [];
      }
      return mentors.docs.map((doc) => doc.id).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getAccountIDInMentor() async {
    try {
      final mentors = await _db.collection('mentors').get();
      return mentors.docs
          .map((doc) => doc.data()['accountId'].toString())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  User getFirebaseUser() {
    return FirebaseAuth.instance.currentUser!;
  }

  String generateUniqueId() {
    return _db.collection('mentors').doc().id;
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final users = await _db.collection('users').get();
      return users.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUser(String id) async {
    try {
      final user = await _db.collection('users').doc(id).get();
      return UserModel.fromJson(user.data()!);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUserThroughEmail(String email) async {
    try {
      final user =
          await _db.collection('users').where('email', isEqualTo: email).get();
      return UserModel.fromJson(user.docs.first.data());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getAPIId() async {
    try {
      final users = await _db.collection('users').get();
      return users.docs
          .map((doc) => doc.data()['accountApiID'].toString())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getMentorAPIIds() async {
    try {
      final mentors = await _db.collection('mentors').get();
      return mentors.docs
          .map((doc) => doc.data()['accountId'].toString())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getMentorAccountId(String mentorId) async {
    try {
      final mentor = await _db.collection('mentors').doc(mentorId).get();
      return mentor.data()!['accountId'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getMenteeAPIIds() async {
    try {
      final mentees = await _db.collection('mentees').get();
      return mentees.docs
          .map((doc) => doc.data()['accountId'].toString())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MentorModel>> getMentorsThroughStatus(String status) async {
    try {
      final mentor = await _db
          .collection('mentors')
          .where('mentorStatus', isEqualTo: status)
          .where('mentorSoftDeleted', isEqualTo: false)
          .get();
      return mentor.docs
          .map((doc) => MentorModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMentor(String mentorId) async {
    try {
      await _db.collection('mentors').doc(mentorId).update({
        'mentorSoftDeleted': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMentorStatus(String mentorId, String status) async {
    try {
      await _db.collection('mentors').doc(mentorId).update({
        'mentorStatus': status,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getMenteeId(String accountId) async {
    try {
      final mentee = await _db
          .collection('mentee')
          .where('accountId', isEqualTo: accountId)
          .get();
      if (mentee.docs.isNotEmpty) {
        return mentee.docs.first.id;
      } else {
        throw Exception('Mentee not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMennteeAlocStatus(
      String courseAllocId, String menteeId, String status) async {
    try {
      if (status == 'removed') {
        status = 'rejected';
      }
      await _db
          .collection('menteeCourseAlloc')
          .where('courseMentorId', isEqualTo: courseAllocId)
          .where('menteeId', isEqualTo: menteeId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'mcaAllocStatus': status});
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getCourseMentorId(String mentorId) async {
    try {
      final courseMentor = await _db
          .collection('courseMentor')
          .where("mentorId", isEqualTo: mentorId)
          .get();
      return CourseMentorModel.fromJson(courseMentor.docs.first.data())
          .courseMentorId;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getCourseMentorIdFromMca(String mcaDocId) async {
    try {
      final mca = await _db.collection('menteeCourseAlloc').doc(mcaDocId).get();
      if (!mca.exists) return '';
      return mca.data()?['courseMentorId'] ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<UserModel> getUserThroughAccId(String accId) async {
    try {
      final user = await _db
          .collection('users')
          .where('accountApiID', isEqualTo: accId)
          .get();
      return UserModel.fromJson(user.docs.first.data());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getMentees(String status) async {
    try {
      final MentorModel mentor =
          await getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);
      final String courseMentor = await getCourseMentorDocId(mentor.mentorId);
      final menteeAllocations = await _db
          .collection('menteeCourseAlloc')
          .where('mcaAllocStatus', isEqualTo: status)
          .where('courseMentorId', isEqualTo: courseMentor)
          .get();

      List<UserModel> users = [];
      for (var allocation in menteeAllocations.docs) {
        final menteeId = allocation.data()['menteeId'];

        final menteeDoc = await _db.collection('mentee').doc(menteeId).get();
        if (menteeDoc.exists) {
          users.add(await getUser(menteeDoc.data()!['accountId']));
        }
      }
      return users;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getMentors() async {
    try {
      // Query mentors collection and exclude soft deleted mentors
      final mentors = await _db
          .collection('mentors')
          .where('mentorSoftDeleted',
              isEqualTo: false) // filter out soft deleted
          .get();

      List<UserModel> users = [];

      for (var mentor in mentors.docs) {
        final accId = mentor.data()['accountId'];
        final user = await getUserThroughAccId(
            accId); // Make sure you're using this version
        users.add(user);
      }

      return users;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadPostContent(PostContentModel postContent) async {
    try {
      String uniqueID = generateUniqueId();
      await _db.collection('postContent').doc(uniqueID).set({
        'contentCategory': postContent.contentCategory,
        'contentCreatedTimestamp': postContent.contentCreatedTimestamp,
        'contentDescription': postContent.contentDescription,
        'contentFiles': postContent.contentFiles,
        'contentImage': postContent.contentImage,
        'contentModifiedTimestamp': postContent.contentModifiedTimestamp,
        'contentSoftDelete': postContent.contentSoftDelete,
        'contentTitle': postContent.contentTitle,
        'contentVideo': postContent.contentVideo,
        'courseMentorId': postContent.courseMentorId,
        'contentLinks': postContent.contentLinks,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourseModel>> getCourses() async {
    try {
      final courses = await _db
          .collection('course')
          .where('courseSoftDelete', isEqualTo: false)
          .get();
      List<CourseModel> courseList = [];
      for (var course in courses.docs) {
        courseList.add(
            CourseModel.fromJson(course.data(), course.id)); //l Pass doc.id
      }
      return courseList;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourseModel>> getActiveCourses() async {
    try {
      final courses = await _db
          .collection('course')
          .where('courseSoftDelete', isEqualTo: false)
          .where('courseStatus', isEqualTo: 'active')
          .get();
      List<CourseModel> courseList = [];
      for (var course in courses.docs) {
        courseList.add(
            CourseModel.fromJson(course.data(), course.id)); //l Pass doc.id
      }
      return courseList;
    } catch (e) {
      rethrow;
    }
  }

  Future<CourseModel> getCourse(String courseId) async {
    try {
      final course = await _db.collection('course').doc(courseId).get();
      return CourseModel.fromJson(course.data()!, course.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> archiveCourse(String courseId) async {
    try {
      await _db.collection('course').doc(courseId).update({
        'courseStatus': 'archived',
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> unarchiveCourse(String courseId) async {
    try {
      await _db.collection('course').doc(courseId).update({
        'courseStatus': 'active',
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourseModel>> getArchivedCourses() async {
    try {
      final courses = await _db
          .collection('course')
          .where('courseSoftDelete', isEqualTo: false)
          .where('courseStatus', isEqualTo: 'archived')
          .get();
      List<CourseModel> courseList = [];
      for (var course in courses.docs) {
        courseList.add(
            CourseModel.fromJson(course.data(), course.id)); //l Pass doc.id
      }
      return courseList;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setCourse(CourseModel course) async {
    try {
      String uniqueID = generateUniqueId();
      await _db.collection('course').doc(uniqueID).set(course.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      await _db.collection('course').doc(courseId).update({
        'courseSoftDelete': true,
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setCourseMentor(String courseId, String mentorId) async {
    try {
      String uniqueID = generateUniqueId();
      final cm = CourseMentorModel(
        courseMentorId: uniqueID,
        courseId: courseId,
        mentorId: mentorId,
        courseMentorCreatedTimestamp: DateTime.now(),
        courseMentorSoftDeleted: false,
      );
      await _db.collection('courseMentor').doc(uniqueID).set(cm.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateInitialCourseMentor(
      String email, String newMentorId) async {
    try {
      CourseMentorModel courseMentor =
          await getCourseMentorThroughMentor(email);
      await _db
          .collection('courseMentor')
          .doc(courseMentor.courseMentorId)
          .update({
        'mentorId': newMentorId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourseMentorModel>> getCourseMentorsThroughCourseId(
      String courseId) async {
    try {
      final courseMentors = await _db
          .collection('courseMentor')
          .where('courseId', isEqualTo: courseId)
          .get();
      return courseMentors.docs
          .map((doc) => CourseMentorModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCourseMentor(
      String courseMentorId, String courseId, String mentorId) async {
    try {
      await _db.collection('courseMentor').doc(courseMentorId).update({
        'courseId': courseId,
        'mentorId': mentorId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getTotalMentorsForCourse(String docId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('courseMentor')
          .where('courseId', isEqualTo: docId)
          .where('courseMentorSoftDelete', isEqualTo: false)
          .get();
      //print(querySnapshot.docs.length);

      return querySnapshot.docs.length; // Return the count
    } catch (e) {
      print('Error fetching course mentors: $e');
      return 0;
    }
  }

  Future<int> getTotalMenteeForCourse(String docId) async {
    try {
      // Step 1: Get the list of courseMentors that match the provided course ID
      final courseMentorQuerySnapshot = await FirebaseFirestore.instance
          .collection('courseMentor')
          .where('courseId', isEqualTo: docId)
          .where('courseMentorSoftDeleted', isEqualTo: false)
          .get();

      // Initialize mentee count
      int menteeCount = 0;
      print("Total Coursementores--------");
      print(courseMentorQuerySnapshot.docs.length);

      // Step 2: For each courseMentor, get the matching menteeCourseAllocID
      for (var courseMentorDoc in courseMentorQuerySnapshot.docs) {
        final courseMentorId = courseMentorDoc.id;

        // Step 3: Get the mentees for this courseMentorId by matching menteeCourseAllocID
        final menteeQuerySnapshot = await FirebaseFirestore.instance
            .collection('menteeCourseAlloc')
            .where('courseMentorId', isEqualTo: courseMentorId)
            .where('mcaSoftDeleted', isEqualTo: false)
            .get();

        // Increment the mentee count based on the number of matching mentees
        menteeCount += menteeQuerySnapshot.docs.length;
      }

      print("Total Mentees for Course $docId: $menteeCount");

      return menteeCount;
    } catch (e) {
      print('Error fetching course mentees: $e');
      return 0;
    }
  }

  Future<List<UserModel>> getMenteeAccountsForCourse(
      String docId, String status) async {
    try {
      // Step 1: Get the list of courseMentors that match the provided course ID
      final courseMentorQuerySnapshot = await FirebaseFirestore.instance
          .collection('courseMentor')
          .where('courseId', isEqualTo: docId)
          .where('courseMentorSoftDeleted', isEqualTo: false)
          .get();

      // Initialize mentee count
      List<String> menteesIds = [];
      print("Total Coursementores--------");
      print(courseMentorQuerySnapshot.docs.length);

      // Step 2: For each courseMentor, get the matching menteeCourseAllocID
      for (var courseMentorDoc in courseMentorQuerySnapshot.docs) {
        final courseMentorId = courseMentorDoc.id;

        // Step 3: Get the mentees for this courseMentorId by matching menteeCourseAllocID
        final menteeQuerySnapshot = await FirebaseFirestore.instance
            .collection('menteeCourseAlloc')
            .where('courseMentorId', isEqualTo: courseMentorId)
            .where('mcaAllocStatus', isEqualTo: status)
            .where('mcaSoftDeleted', isEqualTo: false)
            .get();

        menteesIds.addAll(menteeQuerySnapshot.docs
            .map((doc) => doc.data()['menteeId'].toString())
            .toList());
      }

      List<UserModel> users = [];
      for (String id in menteesIds) {
        final menteeDoc = await _db.collection('mentee').doc(id).get();
        if (menteeDoc.exists) {
          users.add(await getUser(menteeDoc.data()!['accountId']));
        }
      }

      return users;
    } catch (e) {
      print('Error fetching course mentees: $e');
      return [];
    }
  }

  Future<List<UserModel>> getMenteesThroughCourseMentor(
      String courseMentorId) async {
    try {
      final menteeAllocations = await _db
          .collection('menteeCourseAlloc')
          .where('courseMentorId', isEqualTo: courseMentorId)
          .where('mcaSoftDeleted', isEqualTo: false)
          .where('mcaAllocStatus', isEqualTo: 'accepted')
          .get();

      List<UserModel> users = [];
      for (var allocation in menteeAllocations.docs) {
        final menteeId = allocation.data()['menteeId'];

        final menteeDoc = await _db.collection('mentee').doc(menteeId).get();
        if (menteeDoc.exists) {
          users.add(await getUser(menteeDoc.data()!['accountId']));
        }
      }
      return users;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getMenteeStatus(String mcaId) async {
    try {
      final mentee = await _db.collection('menteeCourseAlloc').doc(mcaId).get();
      if (mentee.exists) {
        return mentee.data()!['mcaAllocStatus'];
      } else {
        throw Exception('Mentee not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<MenteeModel?> getMenteeThroughId(String menteeId) async {
    try {
      final mentee = await _db.collection('mentee').doc(menteeId).get();

      if (!mentee.exists) {
        return null;
      }

      final menteeData = mentee.data();
      if (menteeData == null) {
        return null;
      }

      return MenteeModel.fromJson(menteeData, mentee.id);
    } catch (e) {
      debugPrint('Error fetching mentee: $e');
      rethrow; // Or return a default MenteeModel if preferred
    }
  }

  Future<MenteeModel> getMenteeThroughAccId(String accId) async {
    try {
      final mentee = await _db
          .collection('mentee')
          .where('accountId', isEqualTo: accId)
          .get();
      return MenteeModel.fromJson(
          mentee.docs.first.data(), mentee.docs.first.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> enrollThisCourse(
      String mentorId, String userId, String courseId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final Timestamp createdTimestamp = Timestamp.now();

      // Step 1: Query courseMentor collection where courseId matches
      final courseMentorQuery = firestore
          .collection('courseMentor')
          .where('courseId', isEqualTo: courseId);

      final courseMentorSnapshot = await courseMentorQuery.get();

      if (courseMentorSnapshot.docs.isEmpty) {
        print("CourseMentor does not exist. Cannot enroll.");
        return;
      }

      // Step 2: Get the courseMentorId from the first matching document
      final courseMentorId = courseMentorSnapshot.docs.first.id;

      // Step 3: Add record to menteeCourseAlloc
      await firestore.collection('menteeCourseAlloc').add({
        'courseMentorId': courseMentorId,
        'mcaAllocStatus': 'accepted',
        'mcaCreatedTimestamp': createdTimestamp,
        'mcaSoftDeleted': false,
        'menteeId': userId,
      });

      print("Successfully enrolled in the course!");
    } catch (e) {
      print("Error enrolling in the course: $e");
    }
  }

  Future<List<UserModel>> getCourseMentors(String courseId) async {
    try {
      final courseMentorQuery = await _db
          .collection('courseMentor')
          .where('courseId', isEqualTo: courseId)
          .get();

      List<UserModel> users = [];

      for (var courseMentorDoc in courseMentorQuery.docs) {
        final mentorId = courseMentorDoc.data()['mentorId'];

        // Get mentor document by ID
        final mentorDoc = await _db.collection('mentors').doc(mentorId).get();

        if (mentorDoc.exists) {
          final accountId = mentorDoc.data()?['accountId'];
          if (accountId != null) {
            final user = await getUser(accountId);
            users.add(user);
          }
        }
      }

      return users;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getUserDocIdThroughEmail(String email) async {
    try {
      final userSnapshot = await _db
          .collection('users')
          .where('accountApiEmail', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception("No user found with email: $email");
      }

      return userSnapshot.docs.first.id;
    } catch (e) {
      rethrow;
    }
  }
}
