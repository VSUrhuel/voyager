import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';

class NotificationController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retrieves the mentee's document ID using their account email.
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

  /// Fetches the list of accepted course mentor IDs for a given mentee.
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
      return [];
    }
  }

  /// Helper function to fetch posts based on mentor IDs and a timestamp condition.
  Future<List<PostContentModel>> _fetchPosts({
    required List<String> courseMentorIds,
    required Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)
        queryBuilder,
  }) async {
    if (courseMentorIds.isEmpty) return [];

    Query<Map<String, dynamic>> query = _db
        .collection('postContent')
        .where('contentSoftDelete', isEqualTo: false)
        .where('courseMentorId', whereIn: courseMentorIds);

    // Apply the specific time-based query conditions
    query = queryBuilder(query);

    final snapshot = await query.get();

    final posts = snapshot.docs
        .map((doc) => PostContentModel.fromFirestore(doc))
        .toList();

    posts.sort((a, b) =>
        b.contentCreatedTimestamp.compareTo(a.contentCreatedTimestamp));

    return posts;
  }

  Future<List<PostContentModel>> getTodayPostsForUser(String userEmail) async {
    try {
      final userId = await getUserIdThroughEmail(userEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return _fetchPosts(
        courseMentorIds: courseMentorIds,
        queryBuilder: (query) => query
            .where('contentCreatedTimestamp',
                isGreaterThanOrEqualTo: startOfDay)
            .where('contentCreatedTimestamp', isLessThan: endOfDay),
      );
    } catch (e) {
      return [];
    }
  }

  Future<List<PostContentModel>> getPreviousNotificationsForUser(
      String userEmail) async {
    try {
      final userId = await getUserIdThroughEmail(userEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      return _fetchPosts(
        courseMentorIds: courseMentorIds,
        queryBuilder: (query) =>
            query.where('contentCreatedTimestamp', isLessThan: startOfDay),
      );
    } catch (e) {
      return [];
    }
  }

  Future<List<PostContentModel>> getAllNotificationsForUser(
      String userEmail) async {
    try {
      final userId = await getUserIdThroughEmail(userEmail);
      final courseMentorIds = await getCourseMentorIdsForMentee(userId);

      // Fetch all posts without a time constraint and let the helper sort them
      return _fetchPosts(
        courseMentorIds: courseMentorIds,
        queryBuilder: (query) => query, // No extra time filter needed
      );
    } catch (e) {
      return [];
    }
  }
}
