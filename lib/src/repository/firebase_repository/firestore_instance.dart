import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
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

  Future<MentorModel> getMentorThroughAccId(String accId) async {
    try {
      final mentor = await _db
          .collection('mentors')
          .where('accountId', isEqualTo: accId)
          .get();
      return MentorModel.fromJson(mentor.docs.first.data());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScheduleModel>> getScheduleByDay(DateTime date) async {
    try {
      DateTime dateOnly = DateTime(date.year, date.month, date.day);
      DateTime nextDay = dateOnly.add(Duration(days: 1));
      final schedule = await _db
          .collection('schedule')
          .where('scheduleDate', isGreaterThanOrEqualTo: dateOnly)
          .where('scheduleDate', isLessThan: nextDay)
          .get();

      if (schedule.docs.isNotEmpty) {
        return schedule.docs
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

  Future<List<String>> getMentorApPIIds() async {
    try {
      final mentors = await _db.collection('mentors').get();
      return mentors.docs
          .map((doc) => doc.data()['accountId'].toString())
          .toList();
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
          .get();
      return mentor.docs
          .map((doc) => MentorModel.fromJson(doc.data()))
          .toList();
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
      final mentors = await _db.collection('mentors').get();
      List<UserModel> users = [];
      for (var mentor in mentors.docs) {
        users.add(await getUser(mentor.data()['accountId']));
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
}
