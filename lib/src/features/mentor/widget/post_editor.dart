import 'package:flutter/material.dart';

class PostEditor extends StatelessWidget {
  final double screenHeight;
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onPickFile;
  final VoidCallback onAddLink;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const PostEditor({
    super.key,
    required this.screenHeight,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onPickFile,
    required this.onAddLink,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x60eaeaec),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: screenHeight * 0.013,
          left: screenHeight * 0.01,
        ),
        child: Column(
          children: [
            const _UserProfileSection(),
            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                height: screenHeight * 0.4,
                margin: EdgeInsets.only(
                  top: screenHeight * 0.02,
                  left: screenHeight * 0.01,
                  right: screenHeight * 0.02,
                ),
                child: Column(children: [
                  TextField(
                    controller: titleController,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintText: 'Post title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintText: 'Post description...',
                      border: InputBorder.none,
                    ),
                  )
                ])),
            _AttachmentButtons(
              onPickImage: onPickImage,
              onPickVideo: onPickVideo,
              onPickFile: onPickFile,
              onAddLink: onAddLink,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserProfileSection extends StatelessWidget {
  const _UserProfileSection();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      children: [
        CircleAvatar(
          radius: screenHeight * 0.027,
          child: Image.asset('assets/images/application_images/profile.png'),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'John Rhuel Laurente',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'johnrhuell@gmail.com',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AttachmentButtons extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onPickFile;
  final VoidCallback onAddLink;

  const _AttachmentButtons({
    required this.onPickImage,
    required this.onPickVideo,
    required this.onPickFile,
    required this.onAddLink,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.image),
          onPressed: onPickImage,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          icon: const Icon(Icons.video_call),
          onPressed: onPickVideo,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          icon: const Icon(Icons.file_copy_rounded),
          onPressed: onPickFile,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          icon: const Icon(Icons.insert_link),
          onPressed: onAddLink,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
