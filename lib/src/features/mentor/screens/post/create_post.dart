import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
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
  const CreatePost({super.key});

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

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) return;
    final pickedImageFile = File(pickedImage.path);
    setState(() => _images.add(pickedImageFile));
    _showImagePreview(pickedImageFile);
  }

  Future<void> _pickVideo() async {
    final pickedVideo = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedVideo == null) return;
    setState(() => _video = File(pickedVideo.path));
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _platformFiles.addAll(result.files));
      });
    }
  }

  Future<void> postContent() async {
    print("called");
    SupabaseInstance supabase = SupabaseInstance(Supabase.instance.client);
    FirestoreInstance firestore = FirestoreInstance();
    MentorModel mentor = await firestore
        .getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);
    CourseMentorModel courseMentor =
        await firestore.getCourseMentorThroughMentor(mentor.mentorId);
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
      courseMentorId: courseMentor.courseMentorId,
      contentLinks: _links,
    );

    await firestore.uploadPostContent(postContent);

    print("Post content uploaded");

    // Save post content to database
    // await _supabase.savePostContent(postContent);
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

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenSize.height * 0.02),
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
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
              child: const Text('Post', style: TextStyle(fontSize: 16)),
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
    );
  }
}
