// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:voyager/src/features/mentor/controller/post_controller.dart';

class DisplayFilesLink extends StatefulWidget {
  final List<String> files;
  const DisplayFilesLink({super.key, required this.files});

  @override
  State<DisplayFilesLink> createState() => _DisplayFilesLinkState();
}

class _DisplayFilesLinkState extends State<DisplayFilesLink> {
  bool _isDownloading = false;
  int? _currentDownloadIndex;
  PostController postController = Get.put(PostController());
  @override
  Widget build(BuildContext context) {
    if (widget.files.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.files.length,
            itemBuilder: (context, index) {
              return _buildAttachmentItem(widget.files[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(String fileLink, int index) {
    try {
      final uri = Uri.parse(fileLink);
      final fileName = uri.pathSegments.last;
      final fileExt =
          fileName.split('.').length > 1 ? fileName.split('.').last : 'file';

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: _getFileIcon(fileExt),
          title: Text(fileName, overflow: TextOverflow.ellipsis),
          subtitle: _currentDownloadIndex == index && _isDownloading
              ? const LinearProgressIndicator()
              : const Text('Click to download'),
          trailing: IconButton(
            icon: Icon(Icons.download_rounded, color: Colors.blue, size: 20),
            onPressed: () => _downloadFile(fileLink, index),
          ),
          onTap: () => _downloadFile(fileLink, index),
        ),
      );
    } catch (e) {
      debugPrint('Error processing file link: $e');
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: const ListTile(
          leading: Icon(Icons.error),
          title: Text('Invalid file link'),
        ),
      );
    }
  }

  Widget _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green);
      case 'zip':
      case 'rar':
        return const Icon(Icons.archive, color: Colors.orange);
      default:
        return const Icon(Icons.insert_drive_file);
    }
  }

  Future<void> _downloadFile(String url, int index) async {
    try {
      setState(() {
        _isDownloading = true;
        _currentDownloadIndex = index;
      });

      // 1. Request storage permissions
      if (!await postController.requestStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      // 2. Get public Downloads path
      final downloadsPath = await postController.getPublicDownloadsPath();
      final fileName = url.split('/').last;
      final savePath = '$downloadsPath/$fileName';

      // 3. Download file with progress
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toInt();
            debugPrint('Download progress: $progress%');
          }
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved to Downloads/$fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isDownloading = false;
        _currentDownloadIndex = null;
      });
    }
  }
}
