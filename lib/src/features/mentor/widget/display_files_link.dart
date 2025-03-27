import 'package:flutter/material.dart';

class DisplayFilesLink extends StatelessWidget {
  final List<String> files;
  const DisplayFilesLink({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: files.length,
            itemBuilder: (context, index) {
              return _buildAttachmentItem(files[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(String fileLink) {
    try {
      final uri = Uri.parse(fileLink);
      final fileName = uri.pathSegments.last;
      final fileExt =
          fileName.split('.').length > 1 ? fileName.split('.').last : 'file';

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: _getFileIcon(fileExt),
          title: Text(
            fileName,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: const Text(
              'Click to view'), // Removed file size since we don't know it
          onTap: () => _launchFile(fileLink),
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

  Future<void> _launchFile(String url) async {
    // Implement your file opening logic here
    // For example, using url_launcher package:
    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url));
    // }
  }
}
