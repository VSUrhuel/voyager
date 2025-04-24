import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';

class NotificationController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get user ID through email
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
        throw Exception("No mentee found with mentorId: $userId");
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
          .where('mcaAllocStatus', isEqualTo: 'accepted')
          .get();

      return allocations.docs
          .map((doc) => doc.data()['courseMentorId'] as String)
          .toList();
    } catch (e) {
      print("❌ Error getting course mentor IDs: $e");
      return [];
    }
  }

  Future<List<PostContentModel>> getTodayPostsForUser(String userEmail) async {
    try {
      final userId = await getUserIdThroughEmail(userEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return [];

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _db
          .collection('postContent')
          .where('contentSoftDelete', isEqualTo: false)
          .where('courseMentorId', whereIn: courseMentorIds)
          .get();

      final posts = snapshot.docs
          .map((doc) => PostContentModel.fromFirestore(doc))
          .where((post) =>
              post.contentCreatedTimestamp.isAfter(startOfDay) &&
              post.contentCreatedTimestamp.isBefore(endOfDay))
          .toList();
      posts.sort((a, b) =>
          b.contentCreatedTimestamp.compareTo(a.contentCreatedTimestamp));

      return posts;
    } catch (e) {
      print("❌ Error fetching today's posts: $e");
      return [];
    }
  }

  Future<List<PostContentModel>> getPreviousNotificationsForUser(
      String userEmail) async {
    try {
      final userId = await getUserIdThroughEmail(userEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) return [];

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await _db
          .collection('postContent')
          .where('contentSoftDelete', isEqualTo: false)
          .where('courseMentorId', whereIn: courseMentorIds)
          .get();

      final posts = snapshot.docs
          .map((doc) => PostContentModel.fromFirestore(doc))
          .where((post) => post.contentCreatedTimestamp.isBefore(startOfDay))
          .toList();

      posts.sort((a, b) =>
          b.contentCreatedTimestamp.compareTo(a.contentCreatedTimestamp));

      return posts;
    } catch (e) {
      print("❌ Error fetching previous notifications: $e");
      return [];
    }
  }

  Future<List<PostContentModel>> getAllNotificationsForUser(
      String userEmail) async {
    try {
      final todayPosts = await getTodayPostsForUser(userEmail);
      final previousPosts = await getPreviousNotificationsForUser(userEmail);

      return [...todayPosts, ...previousPosts];
    } catch (e) {
      print("❌ Error fetching all notifications: $e");
      return [];
    }
  }
}
