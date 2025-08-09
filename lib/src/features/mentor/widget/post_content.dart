import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/controller/post_controller.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/screens/post/display_video_link.dart';
import 'package:voyager/src/features/mentor/widget/display_files_link.dart';
import 'package:voyager/src/features/mentor/widget/display_images.dart';
import 'package:voyager/src/features/mentor/widget/display_links.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class PostContent extends StatefulWidget {
  final PostContentModel post;
  const PostContent({super.key, required this.post});

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  final PostController postController = Get.put(PostController());
  PostContentModel get _post => widget.post;
  
  // Initialize all fields directly from the post model
  late final List<Map<String, String>> links = _post.contentLinks;
  late final String contentCategory = _post.contentCategory;
  late final DateTime contentCreatedTimestamp = _post.contentCreatedTimestamp;
  late final String contentDescription = _post.contentDescription;
  late final List<String> contentFiles = _post.contentFiles;
  late final List<String> contentImage = _post.contentImage;
  late final DateTime contentModifiedTimestamp = _post.contentModifiedTimestamp;
  late final bool contentSoftDelete = _post.contentSoftDelete;
  late final String contentTitle = _post.contentTitle;
  late final List<String> contentVideo = _post.contentVideo;

  // Initialize with default values that will be updated
  String courseName = 'Loading...';
  String username = 'Loading...';
  String apiPhoto = '';

  bool _showAttachments = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchCourseName(_post.courseMentorId);
    _initializeUserdetails();
  }

  @override
  void dispose() {
    Get.delete<PostController>();
    super.dispose();
  }

  Future<void> fetchCourseName(String courseMentorId) async {
    try {
      FirestoreInstance firestoreInstance = Get.put(FirestoreInstance());
      final course =
          await firestoreInstance.getCourseThroughCourseMentor(courseMentorId);
      if (mounted) {
        setState(() {
          courseName = course.courseName;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          courseName = "Unknown Course";
        });
      }
    }
  }

  Future<void> _initializeUserdetails() async {
    try {
      final courseMentorId = _post.courseMentorId;
      final firestoreInstance = FirestoreInstance();

      final mentor = await firestoreInstance
          .getMentorThroughCourseMentorId(courseMentorId);
      final mentorModel = await firestoreInstance.getMentor(mentor);
      final user =
          await firestoreInstance.getUserThroughAccId(mentorModel.accountId);

      if (mounted) {
        setState(() {
          username = user.accountUsername;
          apiPhoto = user.accountApiPhoto;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          username = 'Unknown User';
        });
      }
    }
  }

  bool checkIfHasAttachements() {
    return contentImage.isNotEmpty ||
        contentVideo.isNotEmpty ||
        contentFiles.isNotEmpty ||
        links.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[500]!),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.013,
            horizontal: screenHeight * 0.01,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Row
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(screenHeight * 0.027),
                    child: CircleAvatar(
                      radius: screenHeight * 0.027,
                      backgroundImage: apiPhoto.isEmpty
                          ? const AssetImage(
                              'assets/images/application_images/profile.png')
                          : NetworkImage(apiPhoto) as ImageProvider,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: screenHeight * 0.01),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenHeight * 0.019,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: screenHeight * 0.01),
                            Text(
                              '•',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: screenHeight * 0.019,
                              ),
                            ),
                            SizedBox(width: screenHeight * 0.01),
                            Text(
                              postController
                                  .getTimePosted(contentCreatedTimestamp),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: screenHeight * 0.015,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: screenWidth * 0.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: contentCategory == 'Announcement'
                                    ? const Color.fromARGB(80, 123, 222, 118)
                                    : const Color(0x501877F2),
                              ),
                              child: Text(
                                contentCategory,
                                style: TextStyle(
                                  color: contentCategory == 'Announcement'
                                      ? const Color.fromARGB(119, 0, 1, 0)
                                      : const Color(0xFF1877F2),
                                  fontSize: screenHeight * 0.015,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width:
                                  screenWidth * 0.4, // Limit width for ellipsis
                              child: Text(
                                courseName,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      screenHeight * 0.016, // Smaller font size
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Divider(
                color: Colors.grey[500]!,
                thickness: 1,
              ),

              // Title and Content
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.00,
                  horizontal: screenHeight * 0.01,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    contentTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: screenHeight * 0.019,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenHeight * 0.01,
                  vertical: screenHeight * 0.01,
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final textSpan = TextSpan(
                      text: contentDescription,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenHeight * 0.019,
                      ),
                    );

                    final textPainter = TextPainter(
                      text: textSpan,
                      maxLines: 3,
                      textDirection: TextDirection.ltr,
                    );
                    textPainter.layout(maxWidth: screenWidth * 0.9);

                    final hasOverflow = textPainter.didExceedMaxLines;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.9,
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: isExpanded
                                ? Text(
                                    contentDescription,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenHeight * 0.019,
                                    ),
                                  )
                                : Text(
                                    contentDescription,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenHeight * 0.019,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ),
                        if (hasOverflow)
                          GestureDetector(
                            onTap: () => setState(() {
                              isExpanded = !isExpanded;
                            }),
                            child: Text(
                              isExpanded ? 'See Less' : 'See More',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: screenHeight * 0.018,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              Column(
                children: [
                  // Attachment header with dropdown button
                  if (checkIfHasAttachements())
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showAttachments = !_showAttachments;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenHeight * 0.01,
                          vertical: screenHeight * 0.01,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Attachments',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                                fontSize: screenHeight * 0.019,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _showAttachments
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: screenHeight * 0.025,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Collapsible attachments section
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showAttachments
                        ? Column(
                            children: [
                              // Image Attachment
                              if (contentImage.isNotEmpty)
                                DisplayImages(images: contentImage),

                              if (contentImage.isNotEmpty)
                                SizedBox(height: screenHeight * 0.01),

                              // Video Attachment
                              if (contentVideo.isNotEmpty)
                                DisplayVideoLink(
                                  videoLink: contentVideo[0],
                                ),

                              if (contentVideo.isNotEmpty)
                                SizedBox(height: screenHeight * 0.01),

                              // File Attachment
                              if (contentFiles.isNotEmpty)
                                DisplayFilesLink(files: contentFiles),

                              if (contentFiles.isNotEmpty)
                                SizedBox(height: screenHeight * 0.01),

                              // Links
                              if (links.isNotEmpty) DisplayLinks(links: links),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
