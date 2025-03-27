import 'dart:io';
import 'package:flutter/material.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
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

  Future<List<PostContentModel>> getPosts() async {
    FirestoreInstance firestoreInstance = FirestoreInstance();

    MentorModel mentor = await firestoreInstance
        .getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);
    print(mentor.mentorId);
    CourseMentorModel courseMentor =
        await firestoreInstance.getCourseMentorThroughMentor(mentor.mentorId);
    print(courseMentor.courseId);
    print(await firestoreInstance
        .getPostContentThroughCourseMentor(courseMentor.courseId));
    return await firestoreInstance
        .getPostContentThroughCourseMentor('WiyXcT5S5pKPV5ZGXPLX');
  }

  Future<bool> requestStoragePermission() async {
    try {
      // Add this critical line first
      WidgetsFlutterBinding.ensureInitialized();

      print('Requesting storage permission');

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
      print('Permission error: $e');
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
