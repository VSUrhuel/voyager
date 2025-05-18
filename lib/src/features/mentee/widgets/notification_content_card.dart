import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class NotificationContentCard extends StatefulWidget {
  final PostContentModel post;

  const NotificationContentCard({super.key, required this.post});

  @override
  State<NotificationContentCard> createState() =>
      _NotificationContentCardState();
}

class _NotificationContentCardState extends State<NotificationContentCard> {
  String mentorName = '';
  String courseName = '';
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchMentorName();
  }

  Future<void> _showCustomDialog(
    BuildContext context, {
    required String title,
    required String mentor,
    required String course,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (mentorName == '' || courseName == '') {
      await _fetchMentorName();
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'Mentor: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: mentor,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'Course: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: course,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
                            text: description,
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
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: isExpanded
                                      ? SizedBox(
                                          height: screenHeight * 0.5,
                                          child: SingleChildScrollView(
                                              child: Text(
                                            description,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: screenHeight * 0.019,
                                            ),
                                          )))
                                      : Text(
                                          description,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onPressed,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(fontSize: screenHeight * 0.018),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchMentorName() async {
    await Future.delayed(const Duration(seconds: 1));
    FirestoreInstance firestoreInstance = FirestoreInstance();
    final mentorId = await firestoreInstance
        .getMentorThroughCourseMentorId(widget.post.courseMentorId);
    final mentor = await firestoreInstance.getMentor(mentorId);
    final courseMentor =
        await firestoreInstance.getCourseMentorThroughMentor(mentor.mentorId);

    final course = await firestoreInstance.getCourse(courseMentor!.courseId);
    final user = await firestoreInstance.getUser(mentor.accountId);
    setState(() {
      mentorName = _formatMentorName(user.accountApiName);
      courseName = course.courseName;
    });
  }

  String _formatMentorName(String fullName) {
    if (fullName.isEmpty) return '';
    fullName = fullName.trim();
    final names = fullName.split(' ');

    if (names.length == 1) return fullName;

    if (names.length > 2) {
      return '${names.first[0]}. ${names[1][0]}. ${names.last[0]}${names.last.substring(1).toLowerCase()}';
    }
    return '${names.first[0]}. ${names.last[0]}${names.last.substring(1).toLowerCase()}';
  }

  String _formatTimestamp(DateTime timestamp) {
    return intl.DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp);
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return '1d ago';
    return '${difference.inDays}d ago';
  }

  IconData _getPostIcon() {
    if (widget.post.contentCategory.toLowerCase().contains('announcement')) {
      return Icons.campaign_rounded;
    } else if (widget.post.contentCategory
        .toLowerCase()
        .contains('resources')) {
      return Icons.attach_file_rounded;
    }
    return Icons.post_add_rounded;
  }

  Color _getCategoryColor() {
    if (widget.post.contentCategory.toLowerCase().contains('announcement')) {
      return const Color(0xFF4285F4); // Blue for announcements
    } else if (widget.post.contentCategory
        .toLowerCase()
        .contains('resources')) {
      return const Color(0xFF34A853); // Green for resources
    }
    return const Color(0xFFEA4335); // Red for others
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = true;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.012,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      elevation: 0, // Removed elevation since we're using borders
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showCustomDialog(context,
              title: widget.post.contentTitle,
              mentor: mentorName,
              course: courseName,
              description: widget.post.contentDescription,
              buttonText: 'Close', onPressed: () {
            Navigator.pop(context);
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getCategoryColor().withOpacity(0.1),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon with colored background
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getPostIcon(),
                    size: screenWidth * 0.065,
                    color: _getCategoryColor(),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip and time ago
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.025,
                              vertical: screenHeight * 0.003,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.post.contentCategory.toUpperCase(),
                              style: TextStyle(
                                fontSize: screenWidth * 0.025,
                                color: _getCategoryColor(),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            _getTimeAgo(widget.post.contentCreatedTimestamp),
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.008),

                      // Mentor name
                      if (mentorName.isNotEmpty)
                        Text(
                          'Posted by: $mentorName',
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (courseName.isNotEmpty)
                        Text(
                          'Course: $courseName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      SizedBox(height: screenHeight * 0.008),

                      // Title
                      Text(
                        widget.post.contentTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.042,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description
                      Text(
                        widget.post.contentDescription,
                        style: TextStyle(
                          fontSize: screenWidth * 0.036,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: isSmallScreen ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.012),

                      // Full timestamp
                      Text(
                        _formatTimestamp(widget.post.contentCreatedTimestamp),
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:voyager/src/features/mentor/model/content_model.dart';
// import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

// class NotificationContentCard extends StatefulWidget {
//   final PostContentModel post;

//   const NotificationContentCard({super.key, required this.post});

//   @override
//   State<NotificationContentCard> createState() =>
//       _NotificationContentCardState();
// }

// class _NotificationContentCardState extends State<NotificationContentCard> {
//   String mentorName = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchMentorName();
//   }

//   void _fetchMentorName() async {
//     // Simulate fetching mentor name from a service or database
//     await Future.delayed(const Duration(seconds: 1));

//     FirestoreInstance firestoreInstance = FirestoreInstance();
//     final mentorId = await firestoreInstance
//         .getMentorThroughCourseMentorId(widget.post.courseMentorId);
//     final mentor = await firestoreInstance.getMentor(mentorId);
//     final user = await firestoreInstance.getUser(mentor.accountId);
//     setState(() {
//       mentorName = user.accountApiName;
//     });
//   }

//   String _formatTimestamp(DateTime timestamp) {
//     return DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp);
//   }

//   String _getTimeAgo(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes} min ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours} hr ago';
//     } else if (difference.inDays == 1) {
//       return '1 day ago';
//     } else {
//       return '${difference.inDays} days ago';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final isSmallScreen = screenWidth < 360 || screenHeight < 700;

//     return Card(
//       margin: EdgeInsets.symmetric(
//         horizontal: screenWidth * 0.03,
//         vertical: screenHeight * 0.01,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(screenWidth * 0.03),
//       ),
//       elevation: 1,
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.03),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Icon container with black color
//             Container(
//               padding: EdgeInsets.all(screenWidth * 0.02),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.grey[100],
//               ),
//               child: Icon(
//                 Icons.campaign,
//                 size: screenWidth * 0.08,
//                 color: Colors.black, // Changed to black
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.03),

//             // Text Content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.post.contentTitle,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: isSmallScreen
//                           ? screenWidth * 0.04
//                           : screenWidth * 0.045,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: screenHeight * 0.005),
//                   Text(
//                     widget.post.contentDescription,
//                     style: TextStyle(
//                       fontSize: isSmallScreen
//                           ? screenWidth * 0.035
//                           : screenWidth * 0.04,
//                       color: Colors.grey[700],
//                     ),
//                     maxLines: isSmallScreen ? 2 : 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: screenHeight * 0.01),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Flexible(
//                         child: Text(
//                           _formatTimestamp(widget.post.contentCreatedTimestamp),
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.03,
//                             color: Colors.grey,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Text(
//                         _getTimeAgo(widget.post.contentCreatedTimestamp),
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.03,
//                           color: const Color(
//                               0xFF52CA82), // Changed to green #52CA82
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
