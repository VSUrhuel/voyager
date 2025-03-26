import 'dart:io';

import 'package:voyager/src/features/mentor/screens/post/display_files.dart';
import 'package:voyager/src/features/mentor/screens/post/display_video.dart';
import 'package:voyager/src/features/mentor/widget/toggle_button_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:voyager/src/widgets/custom_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final List<Map<String, String>> _links = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  List<bool> isSelected = [false, false];
  final List<File?> _images = [];
  File? _video;
  final List<PlatformFile> _platformFiles = [];

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) return;
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _images.add(pickedImageFile);
    });
    _showImagePreview(pickedImageFile);
  }

  Future<void> _pickVideo() async {
    final pickedVideo = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedVideo == null) return;
    final pickedVideoFile = File(pickedVideo.path);
    setState(() {
      _video = pickedVideoFile;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      // Schedule the state update for after the current build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _platformFiles.addAll(result.files);
        });
      });
    }
  }

  void removeAttachment(int index) {
    setState(() {
      _platformFiles.removeAt(index);
    });
  }

  void _showImagePreview(File imageFile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageFile,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Future<void> _addLink() async {
      _titleController.clear();
      _urlController.clear();

      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: screenWidth * 0.9, // 90% of screen width
                maxWidth: screenWidth * 0.9,
                maxHeight: screenHeight * 0.5, // 50% of screen height
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Important for dialog sizing
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add a new link",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    CustomTextField(
                      controllerParam: _titleController,
                      hintText: 'Link Title',
                      fieldWidth: screenWidth * 0.8,
                      fontSize: screenWidth * 0.04,
                    ),
                    CustomTextField(
                      controllerParam: _urlController,
                      hintText: 'Link URL',
                      fieldWidth: screenWidth * 0.8,
                      fontSize: screenWidth * 0.04,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () {
                            if (_titleController.text.isNotEmpty &&
                                _urlController.text.isNotEmpty) {
                              setState(() {
                                _links.add({
                                  'title': _titleController.text,
                                  'url': _urlController.text
                                });
                                print(_links);
                              });
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please enter both title and URL'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    @override
    void dispose() {
      _titleController.dispose();
      _urlController.dispose();
      super.dispose();
    }

    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.only(right: screenHeight * 0.02),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                ),
                child: Text('Post'),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01,
                    horizontal: screenHeight * 0.03),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Post Content",
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        height: screenHeight * 0.55,
                        decoration: BoxDecoration(
                          color: Color(0x60eaeaec),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                            padding: EdgeInsets.only(
                                top: screenHeight * 0.013,
                                left: screenHeight * 0.01),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: screenHeight *
                                          0.027, // Adjust radius as needed
                                      child: Image.asset(
                                          'assets/images/application_images/profile.png'), // Replace with your image URL
                                    ),
                                    SizedBox(width: 16),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'John Rhuel Laurente',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: screenHeight *
                                                  0.02, // Adjust font size as needed
                                              fontWeight:
                                                  FontWeight.w500, // Semi-bold
                                            ),
                                          ),
                                          Text(
                                            'johnrhuell@gmail.com',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: screenHeight *
                                                  0.015, // Adjust font size as needed
                                            ),
                                          ),
                                        ]),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  height: screenHeight * 0.4,
                                  margin: EdgeInsets.only(
                                      top: screenHeight * 0.02,
                                      left: screenHeight * 0.01,
                                      right: screenHeight * 0.02),
                                  child: TextField(
                                    maxLines: 10,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: 'Write something...',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.image),
                                      onPressed: _pickImage,
                                      constraints: BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.video_call),
                                      onPressed: _pickVideo,
                                      constraints: BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.file_copy_rounded),
                                      onPressed: _pickFile,
                                      constraints: BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.insert_link),
                                      onPressed: _addLink,
                                      constraints: BoxConstraints(),
                                    ),
                                  ],
                                )
                              ],
                            )),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text("Category",
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: screenHeight * 0.01),
                      ToggleButtonIcons(),
                      SizedBox(height: screenHeight * 0.01),
                      _images.isEmpty == true
                          ? SizedBox(height: screenHeight * 0.0)
                          : SizedBox(
                              height: screenHeight * 0.26,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Image Files",
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add_a_photo_rounded,
                                            color: Colors.black,
                                          ),
                                          onPressed: _pickImage,
                                        )
                                      ],
                                    ),
                                    SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for (var image in _images)
                                              Stack(children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right:
                                                          screenHeight * 0.01),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Image.file(
                                                      image!,
                                                      width:
                                                          screenHeight * 0.18,
                                                      height:
                                                          screenHeight * 0.18,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 2,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons
                                                            .remove_circle_outlined,
                                                        color: Colors.red),
                                                    onPressed: () {
                                                      setState(() {
                                                        _images.remove(image);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ])
                                          ],
                                        )),
                                  ]),
                            ),
                      _video == null
                          ? SizedBox(height: 0)
                          : DisplayVideo(
                              video: _video!,
                              onDelete: () {
                                setState(() {
                                  _video = null;
                                });
                              }),
                      _platformFiles.isEmpty == true
                          ? SizedBox(height: 0.0)
                          : SizedBox(
                              height: 200,
                              child: DisplayFiles(
                                platformFiles: _platformFiles,
                              )),
                      _links.isNotEmpty == false
                          ? SizedBox(
                              height: 0,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Attached Links',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      fontWeight: FontWeight.bold,
                                    )),
                                _links.isEmpty
                                    ? const SizedBox.shrink()
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _links.length,
                                        itemBuilder: (context, index) {
                                          final link = _links[index];
                                          return ListTile(
                                            title: InkWell(
                                              child:
                                                  new Text(link['text'] ?? ''),
                                              onTap: () async {
                                                final url = Uri.parse(
                                                    link['url'] ?? '');
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(url,
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Could not launch URL'),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () => setState(
                                                  () => _links.removeAt(index)),
                                            ),
                                          );
                                        },
                                      ),
                              ],
                            ),
                    ]))));
  }
}
