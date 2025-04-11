import 'dart:io';
import 'package:flutter/material.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';

class PostController {
  static PostController get instance => Get.find();

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

  final posts = <PostContentModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final int _limit = 10;
  DateTime? lastTimesTamp = DateTime.now();
  bool _hasMore = true;

  // Future<PostsResult> getPosts(
  //     {required int limit, DocumentSnapshot? lastDocument}) async {
  //   FirestoreInstance firestoreInstance = FirestoreInstance();

  //   MentorModel mentor = await firestoreInstance
  //       .getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);

  //   String courseMentor =
  //       await firestoreInstance.getCourseMentorDocId(mentor.mentorId);

  //   List<PostContentModel> posts =
  //       await firestoreInstance.getPostContentThroughCourseMentor(courseMentor);

  //     Query query = FirebaseFirestore.instance
  //       .collection('posts') // Replace with your actual collection name
  //       .where('courseMentorId', isEqualTo: courseMentor)
  //       .orderBy('contentModifiedTimestamp', descending: true)
  //       .limit(limit);

  //   // Apply pagination if lastDocument is provided
  //   if (lastDocument != null) {
  //     query = query.startAfterDocument(lastDocument);
  //   }

  //   // Execute query
  //   QuerySnapshot querySnapshot = await query.get();

  //   // Convert documents to PostContentModel
  //   List<PostContentModel> postsList = querySnapshot.docs.map((doc) {
  //     return PostContentModel.fromFirestore(doc); // Ensure you have this method
  //   }).toList();

  //   // Get the last document for pagination
  //   DocumentSnapshot? newLastDocument =
  //       querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

  //   return PostsResult(
  //     posts: postsList,
  //     lastDocument: newLastDocument,
  //     hasMore: postsList.length == limit,
  //   );
  // }
  Future<PostsResult> getPosts({
    required int limit,
    DateTime? lastPostTimestamp, // Use timestamp instead of DocumentSnapshot
  }) async {
    try {
      FirestoreInstance firestoreInstance = FirestoreInstance();

      MentorModel mentor = await firestoreInstance
          .getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);

      String courseMentor =
          await firestoreInstance.getCourseMentorDocId(mentor.mentorId);

      List<PostContentModel> allPosts = await firestoreInstance
          .getPostContentThroughCourseMentor(courseMentor);

      // Filter and sort
      allPosts = allPosts.where((post) => !post.contentSoftDelete).toList()
        ..sort((a, b) =>
            b.contentModifiedTimestamp.compareTo(a.contentModifiedTimestamp));

      // Find starting index
      int startIndex = 0;
      if (lastPostTimestamp != null) {
        startIndex = allPosts.indexWhere(
                (post) => post.contentModifiedTimestamp == lastPostTimestamp) +
            1;
        if (startIndex < 0) startIndex = 0;
      }

      // Get paginated results
      int endIndex = startIndex + limit;
      if (endIndex > allPosts.length) endIndex = allPosts.length;

      List<PostContentModel> paginatedPosts =
          allPosts.sublist(startIndex, endIndex);

      // Get last post's timestamp for next page
      DateTime? newLastTimestamp = paginatedPosts.isNotEmpty
          ? paginatedPosts.last.contentModifiedTimestamp
          : null;

      return PostsResult(
        posts: paginatedPosts,
        lastTimestamp: newLastTimestamp, // Return timestamp instead
        hasMore: endIndex < allPosts.length,
      );
    } catch (e) {
      debugPrint('Error getting posts: $e');
      rethrow;
    }
  }

  Future<void> loadPosts() async {
    try {
      if (isLoading.value) return;
      isLoading.value = true;
      error.value = '';
      PostsResult postsResult = await getPosts(
        limit: _limit,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        posts.assignAll(postsResult.posts);
        lastTimesTamp = postsResult.lastTimestamp;
        _hasMore = postsResult.hasMore;
      });
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

    try {
      isLoading.value = true;
      final result = await getPosts(
        limit: _limit,
        lastPostTimestamp: lastTimesTamp, // Use timestamp for pagination
      );
      posts.addAll(result.posts);
      lastTimesTamp = result.lastTimestamp;
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
    lastTimesTamp = DateTime.now();
    _hasMore = true;
  }

  Future<String> getUsername() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirestoreInstance firestoreInstance = FirestoreInstance();
    String username = await firestoreInstance.getUsername(uid);
    return username;
  }

  Future<String> getApiPhoto() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirestoreInstance firestoreInstance = FirestoreInstance();
    String apiPhoto = await firestoreInstance.getAccountPhoto(uid);
    return apiPhoto;
  }

  Future<bool> requestStoragePermission() async {
    try {
      // Add this critical line first
      WidgetsFlutterBinding.ensureInitialized();

      // Check Android version
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        // For Android 13+ (API 33+)
        if (androidInfo.version.sdkInt >= 33) {
          final photosStatus = await Permission.photos.status;
          if (!photosStatus.isGranted) {
            final result = await Permission.photos.request();
            return result.isGranted;
          }
          return true;
        }
        // For Android 10-12
        else if (androidInfo.version.sdkInt >= 29) {
          final status = await Permission.storage.status;
          if (!status.isGranted) {
            final result = await Permission.storage.request();
            return result.isGranted;
          }
          return true;
        }
        // For Android <10
        else {
          final status = await Permission.storage.status;
          if (!status.isGranted) {
            final result = await Permission.storage.request();
            return result.isGranted;
          }
          return true;
        }
      }
      // For iOS
      else if (Platform.isIOS) {
        final status = await Permission.photos.status;
        if (!status.isGranted) {
          final result = await Permission.photos.request();
          return result.isGranted;
        }
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String> getPublicDownloadsPath() async {
    if (Platform.isAndroid) {
      // Try standard Downloads path
      const downloadsDir = '/storage/emulated/0/Download';
      if (await Directory(downloadsDir).exists()) return downloadsDir;

      // Try alternative path
      const altDownloadsDir = '/sdcard/Download';
      if (await Directory(altDownloadsDir).exists()) return altDownloadsDir;
    }

    // Fallback
    final dir = await getDownloadsDirectory();
    return dir?.path ??
        (throw Exception('Could not access downloads directory'));
  }
}

class PostsResult {
  final List<PostContentModel> posts;
  final DateTime? lastTimestamp; // Changed from DocumentSnapshot
  final bool hasMore;

  PostsResult({
    required this.posts,
    this.lastTimestamp,
    required this.hasMore,
  });
}
