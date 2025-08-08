import 'dart:io';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostController {
  static PostController get instance => Get.find();

  // Centralized service instances
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreInstance _firestoreInstance = FirestoreInstance();

  // GetX observable state variables
  final posts = <PostContentModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  // Private state for pagination
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
      if (currentUser == null) throw Exception("User not logged in.");

      // Get the current mentor's courseMentor ID
      final MentorModel mentor =
          await _firestoreInstance.getMentorThroughAccId(currentUser.uid);
      final String courseMentorId =
          await _firestoreInstance.getCourseMentorDocId(mentor.mentorId);

      // Build a single, paginated, server-side query
      Query query = _db
          .collection('postContent')
          .where('courseMentorId', isEqualTo: courseMentorId)
          .where('contentSoftDelete', isEqualTo: false)
          .orderBy('contentModifiedTimestamp', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      final postList = querySnapshot.docs
          .map((doc) => PostContentModel.fromFirestore(doc))
          .toList();

      final newLastDocument =
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

      return PostsResult(
        posts: postList,
        lastDocument: newLastDocument,
        hasMore: postList.length == limit,
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
    final uid = _auth.currentUser!.uid;
    return await _firestoreInstance.getUsername(uid);
  }

  Future<String> getApiPhoto() async {
    final uid = _auth.currentUser!.uid;
    return await _firestoreInstance.getAccountPhoto(uid);
  }

  Future<bool> requestStoragePermission() async {
    final PermissionStatus status;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      // Android 13+ (API 33+) uses granular photo permissions
      if (androidInfo.version.sdkInt >= 33) {
        status = await Permission.photos.request();
      } else {
        // Older versions use general storage permission
        status = await Permission.storage.request();
      }
    } else {
      // iOS uses photos permission
      status = await Permission.photos.request();
    }
    return status.isGranted;
  }

  Future<String> getPublicDownloadsPath() async {
    // This is the correct and stable way to get the downloads directory
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
