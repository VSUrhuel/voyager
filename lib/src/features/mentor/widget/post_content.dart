import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/post_controller.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/screens/post/display_video_link.dart';
import 'package:voyager/src/features/mentor/widget/display_files_link.dart';
import 'package:voyager/src/features/mentor/widget/display_images.dart';
import 'package:voyager/src/features/mentor/widget/display_links.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

import '../model/mentor_model.dart';

class PostContent extends StatefulWidget {
  final PostContentModel post;
  const PostContent({super.key, required this.post});

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  PostController postController = Get.put(PostController());
  PostContentModel get _post => widget.post;
  late final List<Map<String, String>> links;
  late final String contentCategory;
  late final DateTime contentCreatedTimestamp;
  late final String contentDescription;
  late final List<String> contentFiles;
  late final List<String> contentImage;
  late final DateTime contentModifiedTimestamp;
  late final bool contentSoftDelete;
  late final String contentTitle;
  late final List<String> contentVideo;
  late String username = '';
  late String apiPhoto = '';

  bool _showAttachments = false;
  bool isExpanded = false;
  @override
  void dispose() {
    Get.delete<PostController>();
    _showAttachments = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    links = _post.contentLinks;
    contentCategory = _post.contentCategory;
    contentCreatedTimestamp = _post.contentCreatedTimestamp;
    contentDescription = _post.contentDescription;
    contentFiles = _post.contentFiles;
    contentImage = _post.contentImage;
    contentModifiedTimestamp = _post.contentModifiedTimestamp;
    contentSoftDelete = _post.contentSoftDelete;
    contentTitle = _post.contentTitle;
    contentVideo = _post.contentVideo;
    _initializeUserdetails();
  }

  Future<void> _initializeUserdetails() async {
    String courseMentorId = _post.courseMentorId;
    FirestoreInstance firestoreInstance = FirestoreInstance();

    String mentor =
        await firestoreInstance.getMentorThroughCourseMentorId(courseMentorId);

    MentorModel mentorModel = await firestoreInstance.getMentor(mentor);
    UserModel user =
        await firestoreInstance.getUserThroughAccId(mentorModel.accountId);

    username = user.accountUsername;
    apiPhoto = user.accountApiPhoto;

    setState(() {
      username = user.accountUsername;
      apiPhoto = user.accountApiPhoto;
    });
  }

  bool checkIfHasAttachements() {
    if (contentImage.isNotEmpty ||
        contentVideo.isNotEmpty ||
        contentFiles.isNotEmpty ||
        links.isNotEmpty) {
      return true;
    } else {
      return false;
    }
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
      // constraints: BoxConstraints(
      //   minHeight: screenHeight * 0.2, // Set minimum height
      // ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.013,
          horizontal: screenHeight * 0.01,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for SingleChildScrollView
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Row
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(screenHeight * 0.027),
                  child: CircleAvatar(
                    radius: screenHeight * 0.027,
                    backgroundImage: apiPhoto == ''
                        ? AssetImage(
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
                      Container(
                        alignment: Alignment.center,
                        width: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: contentCategory == 'Announcement'
                              ? Color.fromARGB(80, 123, 222, 118)
                              : Color(0x501877F2),
                        ),
                        child: Text(
                          contentCategory,
                          style: TextStyle(
                            color: contentCategory == 'Announcement'
                                ? Color.fromARGB(119, 0, 1, 0)
                                : Color(0xFF1877F2),
                            fontSize: screenHeight * 0.015,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                  // Move isExpanded outside the builder or make it persistent

                  return Builder(
                    builder: (context) {
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
                          Container(
                            width: screenWidth * 0.9,
                            child: AnimatedSize(
                              duration: Duration(milliseconds: 300),
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
                                if (isExpanded) {
                                  isExpanded = false;
                                } else {
                                  isExpanded = true;
                                }
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
                  );
                },
              ),
            ),

            Column(
              children: [
                // Attachment header with dropdown button
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
                        Spacer(),
                        Icon(
                          _showAttachments
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: checkIfHasAttachements()
                              ? screenHeight * 0.025
                              : screenHeight * 0,
                        ),
                      ],
                    ),
                  ),
                ),

                // Collapsible attachments section
                AnimatedSize(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _showAttachments
                      ? Column(
                          children: [
                            // Image Attachment
                            contentImage.isEmpty == true
                                ? SizedBox(
                                    height: 0,
                                  )
                                : DisplayImages(images: contentImage),

                            SizedBox(height: screenHeight * 0.01),

                            // Video Attachment
                            contentVideo.isEmpty == true
                                ? SizedBox(
                                    height: 0,
                                  )
                                : DisplayVideoLink(
                                    videoLink: contentVideo.isNotEmpty
                                        ? contentVideo[0]
                                        : '',
                                  ),

                            SizedBox(height: screenHeight * 0.01),

                            // File Attachment
                            contentFiles.isEmpty == true
                                ? SizedBox()
                                : DisplayFilesLink(
                                    files: contentFiles,
                                  ),

                            SizedBox(height: screenHeight * 0.01),

                            links.isEmpty == true
                                ? SizedBox.shrink()
                                : DisplayLinks(
                                    links: links,
                                  ),
                          ],
                        )
                      : SizedBox.shrink(),
                ),

                // Links section (unchanged)
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
