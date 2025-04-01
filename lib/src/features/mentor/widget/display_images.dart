import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:voyager/src/features/mentor/controller/post_controller.dart';
import 'package:voyager/src/widgets/horizontal_slider.dart';

class DisplayImages extends StatefulWidget {
  final List<String> images;
  const DisplayImages({super.key, required this.images});

  @override
  State<DisplayImages> createState() => _DisplayImagesState();
}

class _DisplayImagesState extends State<DisplayImages> {
  bool _isDownloading = false;
  PostController postController = Get.put(PostController());
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _requestStoragePermission() async {
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

  Future<String> _getDownloadsPath() async {
    if (Platform.isAndroid) {
      const downloadsDir = '/storage/emulated/0/Download';
      if (await Directory(downloadsDir).exists()) {
        return downloadsDir;
      }

      // Method 2: Alternative path for some devices
      const altDownloadsDir = '/sdcard/Download';
      if (await Directory(altDownloadsDir).exists()) {
        return altDownloadsDir;
      }
    }

    // Fallback to getDownloadsDirectory() if direct paths fail
    final dir = await getDownloadsDirectory();
    return dir?.path ??
        (throw Exception('Could not access downloads directory'));
  }

  Future<void> _downloadImage(String url) async {
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
    });
    print('Downloading image');
    if (!await postController.requestStoragePermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission denied'),
        ),
      );
      setState(() {
        _isDownloading = false;
      });
      return;
    }
    print('Permission granted');
    final dio = Dio();
    final fileName = url.split('/').last;
    // 3. Get the Downloads directory
    final String downloadsDir = await postController.getPublicDownloadsPath();
    if (downloadsDir == '') {
      throw Exception('Could not access downloads directory');
    }

    // 4. Create the target file path
    final savePath = '$downloadsDir/$fileName';
    print('Save path: $savePath');
    final file = File(savePath);

    // 5. Download the file
    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    // 6. Save the file
    await file.writeAsBytes(response.data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image saved to gallery'),
      ),
    );

    setState(() {
      _isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return widget.images.isNotEmpty == true
        ? HorizontalWidgetSlider(widgets: [
            for (int i = 0; i < widget.images.length; i++)
              Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.01),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _showFullScreenImage(context, widget.images[i]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.images[i],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: screenHeight * 0.18,
                              height: screenHeight * 0.18,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: screenHeight * 0.18,
                              height: screenHeight * 0.18,
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey[400]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () => _downloadImage(
                            widget.images[i]), // Use current image URL
                        child: _isDownloading
                            ? SizedBox(
                                height: screenHeight * 0.02,
                                width: screenHeight * 0.02,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.blue),
                                ),
                              )
                            : Icon(
                                Icons.download_rounded,
                                color: Colors.blue,
                                size: screenHeight * 0.02,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
          ])
        : SizedBox(
            height: 0,
          );
  }
}
