import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class SupabaseInstance {
  final SupabaseClient _supabase;

  SupabaseInstance(this._supabase);

  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('post-files')
          .upload('images/$fileName', imageFile);

      final url =
          _supabase.storage.from('post-files').getPublicUrl('images/$fileName');
      return url;
    } on StorageException catch (e) {
      throw Exception('Supabase storage error: ${e.message}');
    } catch (e) {
      return null;
    }
  }

  Future<List<String?>> uploadImages(List<File> imageFiles) async {
    List<String?> imageUrls = [];

    for (final image in imageFiles) {
      final url = await uploadImage(image);
      imageUrls.add(url);
    }
    return imageUrls;
  }

  Future<String> uploadVideo(File videoFile) async {
    try {
      final videoName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _supabase.storage
          .from('post-files')
          .upload('videos/$videoName', videoFile);

      final url = _supabase.storage
          .from('post-files')
          .getPublicUrl('videos/$videoName');
      return url;
    } on StorageException catch (e) {
      debugPrint('Supabase storage error: ${e.message}');
      return '';
    } catch (e) {
      debugPrint('Error uploading video: $e');
      return '';
    }
  }

  Future<String> uploadFile(PlatformFile file) async {
    try {
      final fileName =
          'file_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';

      await _supabase.storage
          .from('post-files')
          .upload('files/$fileName', File(file.path!));

      final url =
          _supabase.storage.from('post-files').getPublicUrl('files/$fileName');
      return url;
    } on StorageException catch (e) {
      debugPrint('Supabase storage error: ${e.message}');
      return '';
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return '';
    }
  }

  Future<List<String>> uploadFiles(List<PlatformFile> files) async {
    List<String?> fileUrls = [];

    for (final file in files) {
      final url = await uploadFile(file);
      fileUrls.add(url);
    }
    return fileUrls.whereType<String>().toList();
  }
}
