import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
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
        'accountApiPhoto':
            auth.firebaseUser.value?.photoURL ?? "", // Handle null safely
        'accountPassword': '',
        'accountUsername': auth.firebaseUser.value?.displayName ??
            "Unknown", // Provide default username
        'accountRole': await FirestoreInstance().getUserRole(userUid),
        'accountStudentId': '',
        'accountCreatedTimestamp': DateTime.now(),
        'accountModifiedTimestamp': DateTime.now(),
        'accountSoftDeleted': false,
      });
      print("doneee");
    } catch (e) {
      Get.snackbar('Error', e.toString());
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
          .get();
      return CourseMentorModel.fromJson(courseMentor.docs.first.data());
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
      final menteeAllocations = await _db
          .collection('menteeCourseAlloc')
          .where('mcaAllocStatus', isEqualTo: status)
          .get();

      List<UserModel> users = [];
      for (var allocation in menteeAllocations.docs) {
        final menteeId = allocation.data()['menteeId'];

        final menteeDoc = await _db.collection('mentee').doc(menteeId).get();
        print(menteeId);
        if (menteeDoc.exists) {
          users.add(await getUser(menteeDoc.data()!['accountId']));
        }
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
      });
    } catch (e) {
      rethrow;
    }
  }
}
