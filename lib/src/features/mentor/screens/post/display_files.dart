import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

class DisplayFiles extends StatefulWidget {
  final List<PlatformFile> platformFiles;
  const DisplayFiles({super.key, required this.platformFiles});

  @override
  State<DisplayFiles> createState() => _DisplayFilesState();
}

class _DisplayFilesState extends State<DisplayFiles> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Attachments',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 2.0),
            Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.platformFiles.length,
                    itemBuilder: (context, index) {
                      final file = widget.platformFiles[index];
                      return _buildAttachmentItem(file, index);
                    }))
          ],
        ));
  }

  Widget _buildAttachmentItem(PlatformFile file, int index) {
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: _getFileIcon(file.extension),
          title: Text(
            file.name,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${(file.size / 1024).toStringAsFixed(2)} KB'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                widget.platformFiles.removeAt(index);
              });
            },
          ),
        ));
  }

  Widget _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      default:
        return const Icon(Icons.insert_drive_file);
    }
  }
}
