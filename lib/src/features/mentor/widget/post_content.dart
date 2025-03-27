import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voyager/src/features/mentor/screens/post/display_video_link.dart';
import 'package:voyager/src/features/mentor/widget/display_files_link.dart';

class PostContent extends StatelessWidget {
  PostContent({super.key});

  final _links = ['link1', 'link2'];

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
      constraints: BoxConstraints(
        minHeight: screenHeight * 0.7, // Set minimum height
      ),
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
                CircleAvatar(
                  radius: screenHeight * 0.03,
                  child: Image.asset(
                      'assets/images/application_images/profile.png'),
                ),
                Padding(
                  padding: EdgeInsets.only(left: screenHeight * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'rhuelxx',
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
                            '2 hours ago',
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
                          color: Color(0x501877F2),
                        ),
                        child: Text(
                          'Announcement',
                          style: TextStyle(
                            color: Color(0xFF1877F2),
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
                  'Title',
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
              child: Text(
                'Hello, everyone! I am excited to announce that we will be having a webinar on the 30th of June. Please join us and learn more about the latest trends in the industry. See you there!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenHeight * 0.019,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.01),

            // Attachments
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenHeight * 0.01,
                vertical: screenHeight * 0.01,
              ),
              child: Text(
                'Attachments',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  fontSize: screenHeight * 0.019,
                ),
              ),
            ),

            // Image Attachment
            Padding(
              padding: EdgeInsets.only(right: screenHeight * 0.01),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/post-files/images/image_1743009700328.jpg',
                  width: screenHeight * 0.18,
                  height: screenHeight * 0.18,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.01),

            // Video Attachment
            DisplayVideoLink(
              videoLink:
                  'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/post-files/videos/video_1743044074168.mp4',
            ),

            SizedBox(height: screenHeight * 0.01),

            // File Attachment
            DisplayFilesLink(
              files: [
                'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/post-files/files/file_1743010021703.pdf'
              ],
            ),

            SizedBox(height: screenHeight * 0.01),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenHeight * 0.01,
                vertical: screenHeight * 0.01,
              ),
              child: Text(
                'Links',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  fontSize: screenHeight * 0.019,
                ),
              ),
            ),
            if (_links.isNotEmpty)
              Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenHeight * 0.01,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final link in _links)
                          Padding(
                            padding:
                                EdgeInsets.only(bottom: screenHeight * 0.01),
                            child: InkWell(
                              onTap: () async {
                                final uri = Uri.tryParse(link);
                                if (uri != null && await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              child: Text(
                                "helllo",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: screenHeight * 0.019,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                      ]))
          ],
        ),
      ),
    ));
  }
}
