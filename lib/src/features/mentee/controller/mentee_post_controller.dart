import 'dart:io';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenteePostController {
  static MenteePostController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreInstance _firestoreInstance = FirestoreInstance();

  final posts = <PostContentModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  String getTimePosted(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inSeconds}s ago';
    }
  }

  Future<PostsResult> getPosts({
    required int limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      // 1. Get mentee's course allocations and associated mentor IDs
      final mentee =
          await _firestoreInstance.getMenteeThroughAccId(currentUser.uid);
      if (mentee.menteeMcaId.isEmpty) {
        return PostsResult(posts: [], lastDocument: null, hasMore: false);
      }

      final mcaSnapshot = await _db
          .collection('menteeCourseAlloc')
          .where(FieldPath.documentId, whereIn: mentee.menteeMcaId)
          .where('mcaAllocStatus', isEqualTo: 'accepted')
          .get();

      if (mcaSnapshot.docs.isEmpty) {
        return PostsResult(posts: [], lastDocument: null, hasMore: false);
      }

      // List of course-links the mentee is directly enrolled in
      final enrolledCourseMentorIds = mcaSnapshot.docs
          .map((doc) => doc.data()['courseMentorId'] as String)
          .toList();

      final coursesEnrolled = await _db
          .collection("courseMentor")
          .where(
            FieldPath.documentId,
            whereIn: enrolledCourseMentorIds,
          )
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => doc.data()['courseId'] as String)
              .toList());

      final courseMentorEnrolled = await _db
          .collection("courseMentor")
          .where('courseId', whereIn: coursesEnrolled)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) => doc.id).toList());

      final uniqueMentorIds = await _db
          .collection('courseMentor')
          .where(FieldPath.documentId, whereIn: enrolledCourseMentorIds)
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => doc.data()['mentorId'] as String)
              .toList());

      List<String> allMentorCourseLinks = [];
      if (uniqueMentorIds.isNotEmpty) {
        final allMentorCoursesSnapshot = await _db
            .collection('courseMentor')
            .where('mentorId', whereIn: uniqueMentorIds)
            .get();
        allMentorCourseLinks =
            allMentorCoursesSnapshot.docs.map((doc) => doc.id).toList();
      }
      final resourcesQueryFuture = _db
          .collection('postContent')
          .where('courseMentorId', whereIn: courseMentorEnrolled)
          .where('contentCategory', isEqualTo: 'Resources')
          .where('contentSoftDelete', isEqualTo: false)
          .get();

      final mentorPostsQueryFuture = allMentorCourseLinks.isEmpty
          ? Future.value(null) // Avoid empty 'whereIn' query which throws error
          : _db
              .collection('postContent')
              .where('courseMentorId', whereIn: allMentorCourseLinks)
              .where('contentSoftDelete', isEqualTo: false)
              .get();
      final results =
          await Future.wait([resourcesQueryFuture, mentorPostsQueryFuture]);
      final resourcesSnapshot =
          results[0] as QuerySnapshot<Map<String, dynamic>>;
      final mentorPostsSnapshot =
          results[1] as QuerySnapshot<Map<String, dynamic>>;
      // 4. Merge and Deduplicate snapshots
      final uniqueSnapshots = <String, DocumentSnapshot>{};
      for (final doc in resourcesSnapshot.docs) {
        uniqueSnapshots[doc.id] = doc;
      }
      for (final doc in mentorPostsSnapshot.docs) {
        uniqueSnapshots[doc.id] = doc;
      }
      // 5. Sort and Paginate
      final sortedSnapshots = uniqueSnapshots.values.toList()
        ..sort((a, b) {
          final aTimestamp = (a.data()
              as Map<String, dynamic>)['contentModifiedTimestamp'] as Timestamp;
          final bTimestamp = (b.data()
              as Map<String, dynamic>)['contentModifiedTimestamp'] as Timestamp;
          return bTimestamp.compareTo(aTimestamp);
        });

      int startIndex = 0;
      if (lastDocument != null) {
        final lastTimestamp = (lastDocument.data()
            as Map<String, dynamic>)['contentModifiedTimestamp'] as Timestamp;
        startIndex = sortedSnapshots.indexWhere((doc) {
              final currentTimestamp = (doc.data()
                      as Map<String, dynamic>)['contentModifiedTimestamp']
                  as Timestamp;
              return currentTimestamp.microsecondsSinceEpoch ==
                  lastTimestamp.microsecondsSinceEpoch;
            }) +
            1;
      }

      final endIndex = (startIndex + limit > sortedSnapshots.length)
          ? sortedSnapshots.length
          : startIndex + limit;
      final paginatedSnapshots =
          (startIndex >= 0 && startIndex < sortedSnapshots.length)
              ? sortedSnapshots.sublist(startIndex, endIndex)
              : <DocumentSnapshot>[];

      final postList = paginatedSnapshots
          .map((doc) => PostContentModel.fromFirestore(doc))
          .toList();
      final newLastDocument =
          paginatedSnapshots.isNotEmpty ? paginatedSnapshots.last : null;

      return PostsResult(
        posts: postList,
        lastDocument: newLastDocument,
        hasMore: endIndex < sortedSnapshots.length,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadPosts() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    try {
      PostsResult postsResult = await getPosts(limit: _limit);
      posts.assignAll(postsResult.posts);
      _lastDocument = postsResult.lastDocument;
      _hasMore = postsResult.hasMore;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    resetPagination();
    await loadPosts();
  }

  Future<bool> loadMorePosts() async {
    if (!_hasMore || isLoading.value) return false;

    isLoading.value = true;
    try {
      final result = await getPosts(
        limit: _limit,
        lastDocument: _lastDocument,
      );
      posts.addAll(result.posts);
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;
      return _hasMore;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void resetPagination() {
    _lastDocument = null;
    _hasMore = true;
  }

  Future<String> getUsername() async {
    String uid = _auth.currentUser!.uid;
    return await _firestoreInstance.getUsername(uid);
  }

  Future<String> getApiPhoto() async {
    String uid = _auth.currentUser!.uid;
    return await _firestoreInstance.getAccountPhoto(uid);
  }

  Future<bool> requestStoragePermission() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      // Android 13+ (API 33+) uses granular permissions.
      if (androidInfo.version.sdkInt >= 33) {
        status = await Permission.photos.request();
      } else {
        // Earlier versions use general storage permission.
        status = await Permission.storage.request();
      }
    } else {
      // iOS uses photos permission.
      status = await Permission.photos.request();
    }

    return status.isGranted;
  }

  Future<String> getPublicDownloadsPath() async {
    // This is the correct and stable way to get the downloads directory.
    // Avoid hardcoding paths like '/storage/emulated/0/Download'.
    final Directory? dir = await getDownloadsDirectory();
    if (dir != null) {
      return dir.path;
    } else {
      throw Exception('Could not access downloads directory');
    }
  }
}

class PostsResult {
  final List<PostContentModel> posts;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PostsResult({
    required this.posts,
    required this.lastDocument,
    required this.hasMore,
  });
}
