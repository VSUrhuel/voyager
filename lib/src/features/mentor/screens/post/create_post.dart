// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/screens/mentor_dashboard.dart';
import 'package:voyager/src/features/mentor/screens/post/display_files.dart';
import 'package:voyager/src/features/mentor/screens/post/display_video.dart';
import 'package:voyager/src/features/mentor/widget/image_preview_dialog.dart';
import 'package:voyager/src/features/mentor/widget/toggle_button_icons.dart';
import 'package:voyager/src/features/mentor/widget/image_preview_section.dart';
import 'package:voyager/src/features/mentor/widget/link_dialog.dart';
import 'package:voyager/src/features/mentor/widget/link_section.dart';
import 'package:voyager/src/features/mentor/widget/post_editor.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/repository/supabase_repository/supabase_instance.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key, this.fromHome = false});
  final bool fromHome;

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final List<Map<String, String>> _links = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titlePostController = TextEditingController();
  final TextEditingController _descriptionPostController =
      TextEditingController();
  final TextEditingController _category = TextEditingController();
  final List<File> _images = [];
  File? _video;
  final List<PlatformFile> _platformFiles = [];
  bool _isPosting = false;

  // @override
  // void initState() {
  //   super.initState();
  // }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) return;
    final imageFile = File(pickedImage.path);
    final imageSize = await imageFile.length();
    if (imageSize > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Image size exceeds 5MB. Please select a smaller video or post it through links.'),
        ),
      );
      return;
    }
    final pickedImageFile = File(pickedImage.path);
    setState(() => _images.add(pickedImageFile));
    _showImagePreview(pickedImageFile);
  }

  Future<void> _pickVideo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Lottie.asset(
          'assets/images/loading.json',
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.width * 0.3,
          repeat: true,
        ),
      ),
    );
    try {
      final pickedVideo = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
      );
      if (pickedVideo == null) {
        Navigator.of(context).pop(); // Close the loading dialog
        return;
      }

      final pickedVideoFile = File(pickedVideo.path);
      final videoSize = await pickedVideoFile.length();

      // Check if the video size exceeds 10MB (10 * 1024 * 1024 bytes)
      if (videoSize > 10 * 1024 * 1024) {
        Navigator.of(context).pop(); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Video size exceeds 10MB. Please select a smaller video or post it through links.'),
          ),
        );
        return;
      }

      setState(() => _video = pickedVideoFile);
      Navigator.pop(context);
    } finally {}
  }

  Future<void> _pickFile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Lottie.asset(
          'assets/images/loading.json',
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.width * 0.3,
          repeat: true,
        ),
      ),
    );
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: true,
      );
      for (var file in result!.files) {
        final fileSize = file.size;
        // Check if the file size exceeds 5MB (5 * 1024 * 1024 bytes)
        if (fileSize > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'File size exceeds 5MB. Please select a smaller file or post it through links.'),
            ),
          );
          return;
        }
      }
      if (result.files.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _platformFiles.addAll(result.files));
        });
      }
      Navigator.pop(context);
    } finally {}
  }

  Future<void> postContent() async {
    if (_isPosting) return;
    setState(() {
      _isPosting = true;
    });

    try {
      SupabaseInstance supabase = SupabaseInstance(Supabase.instance.client);
      FirestoreInstance firestore = FirestoreInstance();
      MentorModel mentor = await firestore
          .getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);
      String courseMentor =
          await firestore.getCourseMentorDocId(mentor.mentorId);
      // Upload images
      final imageUrls = await supabase.uploadImages(_images);

      // Upload video
      final videoUrl =
          _video != null ? await supabase.uploadVideo(_video!) : null;

      // Upload files
      final fileUrls = await supabase.uploadFiles(_platformFiles);

      if (_titlePostController.text.isEmpty ||
          _descriptionPostController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Title and description cannot be empty'),
          ),
        );
        return;
      }

      // Create post content
      final postContent = PostContentModel(
        contentCategory: _category.text == '0' ? 'Announcement' : 'Resources',
        contentCreatedTimestamp: DateTime.now(),
        contentDescription: _descriptionPostController.text,
        contentFiles: fileUrls,
        contentImage: imageUrls.whereType<String>().toList(),
        contentModifiedTimestamp: DateTime.now(),
        contentSoftDelete: false,
        contentTitle: _titlePostController.text,
        contentVideo: videoUrl != null ? [videoUrl] : [],
        courseMentorId: courseMentor,
        contentLinks: List<Map<String, String>>.from(_links),
      );

      await firestore.uploadPostContent(postContent);
      //await uploadPostContent(postContent);
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  // In your FirestoreInstance class
  Future<void> uploadPostContent(PostContentModel post) async {
    // Check for recent posts with same title/content by same user
    final query = await FirebaseFirestore.instance
        .collection('posts')
        .where('courseMentorId', isEqualTo: post.courseMentorId)
        .where('contentTitle', isEqualTo: post.contentTitle)
        .where('contentDescription', isEqualTo: post.contentDescription)
        .orderBy('contentCreatedTimestamp', descending: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final lastPost = query.docs.first;
      final lastPostTime = lastPost['contentCreatedTimestamp'] as Timestamp;
      // If same post was created within last 5 seconds, reject
      if (DateTime.now().difference(lastPostTime.toDate()).inSeconds < 5) {
        throw Exception('Duplicate post detected');
      }
    }

    // Proceed with upload
    await FirebaseFirestore.instance.collection('posts').add({
      'contentCategory': post.contentCategory,
      'contentCreatedTimestamp': post.contentCreatedTimestamp,
      'contentDescription': post.contentDescription,
      'contentFiles': post.contentFiles,
      'contentImage': post.contentImage,
      'contentModifiedTimestamp': post.contentModifiedTimestamp,
      'contentSoftDelete': post.contentSoftDelete,
      'contentTitle': post.contentTitle,
      'contentVideo': post.contentVideo,
      'courseMentorId': post.courseMentorId,
      'contentLinks': post.contentLinks,
    });
  }

  void _removeImage(File image) => setState(() => _images.remove(image));
  void _removeLink(int index) => setState(() => _links.removeAt(index));

  void _showImagePreview(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => ImagePreviewDialog(imageFile: imageFile),
    );
  }

  Future<void> _addLink() async {
    _titleController.clear();
    _urlController.clear();

    final shouldAdd = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return LinkDialog(
          titleController: _titleController,
          urlController: _urlController,
          screenWidth: screenSize.width,
          screenHeight: screenSize.height,
        );
      },
    );

    if (shouldAdd == true) {
      setState(() {
        _links.add({
          'title': _titleController.text,
          'url': _urlController.text,
        });
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  CustomPageRoute(
                    page: widget.fromHome
                        ? MentorDashboard(index: 1)
                        : MentorDashboard(),
                    direction: AxisDirection.right,
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: screenSize.height * 0.02),
                child: ElevatedButton(
                  onPressed: _isPosting
                      ? null
                      : () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Center(
                              child: Lottie.asset(
                                'assets/images/loading.json',
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: MediaQuery.of(context).size.width * 0.3,
                                repeat: true,
                              ),
                            ),
                          );
                          await postContent();
                          Navigator.of(context).push(
                            CustomPageRoute(
                              page: MentorDashboard(),
                              direction: AxisDirection.right,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isPosting
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                  backgroundColor: Colors.white30,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Posting...',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          )
                        : Text('Post', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenSize.height * 0.01,
                horizontal: screenSize.height * 0.03,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Post Content",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  PostEditor(
                    screenHeight: screenSize.height,
                    onPickImage: _pickImage,
                    onPickVideo: _pickVideo,
                    onPickFile: _pickFile,
                    onAddLink: _addLink,
                    titleController: _titlePostController,
                    descriptionController: _descriptionPostController,
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  const Text(
                    "Category",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  ToggleButtonIcons(category: _category),
                  SizedBox(height: screenSize.height * 0.01),
                  ImagePreviewSection(
                    images: _images,
                    screenHeight: screenSize.height,
                    screenWidth: screenSize.width,
                    onAddImage: _pickImage,
                    onRemoveImage: _removeImage,
                  ),
                  if (_video != null)
                    DisplayVideo(
                      video: _video!,
                      onDelete: () => setState(() => _video = null),
                    ),
                  if (_platformFiles.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: DisplayFiles(platformFiles: _platformFiles),
                    ),
                  LinksSection(
                    links: _links,
                    onRemoveLink: _removeLink,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
