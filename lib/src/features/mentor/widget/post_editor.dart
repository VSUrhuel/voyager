import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

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

class _UserProfileSection extends StatefulWidget {
  const _UserProfileSection();

  @override
  State<_UserProfileSection> createState() => _UserProfileSectionState();
}

class _UserProfileSectionState extends State<_UserProfileSection> {
  late UserModel _userModel = UserModel(
    accountApiName: '',
    accountApiEmail: '',
    accountApiID: '',
    accountPassword: '',
    accountApiPhoto: '',
    accountUsername: '',
    accountRole: '',
    accountStudentId: '',
    accountSoftDeleted: false,
    accountCreatedTimestamp: DateTime.now(),
    accountModifiedTimestamp: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final FirestoreInstance firestoreInstance = Get.put(FirestoreInstance());
      final userData = await firestoreInstance.getUser(user.uid);

      setState(() {
        _userModel = userData;
      });
    } catch (e) {
      setState(() {});
      debugPrint('Error fetching user: $e');
    }
  }

  String _formatName(String name) {
    if (name.isEmpty) return name;

    return name.split(' ').map((part) {
      if (part.isEmpty) return part;
      if (part.length == 1) return part.toUpperCase();
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).join(' ');
  }

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatName(_userModel.accountApiName),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _userModel.accountApiEmail,
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
