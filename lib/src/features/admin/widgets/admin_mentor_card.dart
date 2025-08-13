import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/controllers/course_mentor_controller.dart';
import 'package:voyager/src/features/admin/controllers/create_mentor_controller.dart';
import 'package:voyager/src/features/admin/controllers/admin_mentor_controller.dart';
import 'package:voyager/src/features/admin/screens/mentors/mentor_profile.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';

class AdminMentorCard extends StatelessWidget {
  final MentorModel mentorModel;
  final UserModel userModel;
  final String mentor;
  final String email;
  final String studentId;
  final String schedule;
  final List<String> course;
  final String? courseId;
  final VoidCallback? onActionComplete;

  const AdminMentorCard({
    super.key,
    required this.userModel,
    required this.mentorModel,
    required this.mentor,
    required this.email,
    required this.studentId,
    required this.schedule,
    required this.course,
    this.courseId,
    this.onActionComplete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isProcessing = false;

    return InkWell(
      onTap: () async {
        if (courseId != null) {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Assignment'),
              content: const Text(
                  'Are you sure you want to assign this mentor to the course?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => {
                    if (!isProcessing)
                    {
                    Navigator.pop(context, true),
                        isProcessing = true,
                    }
                    },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );

          if (confirmed == true ) {
            await CourseMentorController()
                .createCourseMentor(courseId!, mentorModel.mentorId);
            await AdminMentorController()
                .updateMentorStatus(mentorModel.mentorId, 'active');
            isProcessing = false;
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          } else if (confirmed == false) {
            // Navigator.pop(context);
          } else {
            Navigator.push(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(
                    builder: (context) => MentorProfile(
                          mentorModel: mentorModel,
                          user: userModel,
                        )));
          }
        } else {
          Navigator.push(
              context,
              CustomPageRoute(
                  page: MentorProfile(
                    mentorModel: mentorModel,
                    user: userModel,
                  ),
                  direction: AxisDirection.left));
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          side: BorderSide(
            color: Color(0xFF9494A0),
            width: 0.5,
          ),
        ),
        child: Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.02),
            child: SizedBox(
                height: screenHeight * 0.09,
                width: screenWidth * 0.9,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SizedBox(
                    width: screenWidth * 0.2,
                    child: userModel.accountApiPhoto.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust for desired roundness
                            child: Image.network(
                              userModel.accountApiPhoto,
                              fit: BoxFit
                                  .cover, // Ensures the image covers the space
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                            ),
                          )
                        : CircleAvatar(
                            radius: screenWidth * 0.05,
                            child: Icon(
                              Icons.person,
                              size: screenWidth * 0.05,
                            ),
                          ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(builder: (context){
                          mentor;
                          double baseFontSize = screenWidth * 0.040;
                          double dynamicFontSize = mentor.length > 17
                              ? baseFontSize * (18 / mentor.length)
                              : baseFontSize;

                          return Text(mentor,
                            style: TextStyle(
                              color: Colors.black,
                              // fontSize: screenWidth * 0.04,
                              fontSize: dynamicFontSize,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ));

                        },),
                        
                        SizedBox(height: screenHeight * 0.002),
                        Row(children: [
                          Builder(
                            builder: (context) {
                              email;
                              double baseFontSize = screenWidth * 0.035;
                              double dynamicFontSize = email.length > 20
                                  ? baseFontSize * (20 / email.length)
                                  : baseFontSize;

                              return Text(
                                email,
                                style: TextStyle(
                                  color: Colors.blue,
                                  // fontSize: screenWidth * 0.035,
                                  fontSize: dynamicFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ]),
                        Row(children: [
                          // Day indicators with accent background
                          _buildDayPills(schedule, context),
                          SizedBox(width: screenWidth * 0.015),

                          // Time range
                          Builder(
                            builder: (context) {
                              String sched = schedule.substring(
                                schedule.indexOf(' ') + 1);
                                double baseFontSize = screenWidth * 0.035;
                                double dynamicFontSize = sched.length > 15
                                    ? baseFontSize * (15 / sched.length)
                                    : baseFontSize;

                                return Text(
                                sched, // Get time portion
                                style: TextStyle(
                                  color: Colors.black87,
                                  // fontSize: screenWidth * 0.035,
                                  fontSize: dynamicFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }
                          )
                          

                          // IntrinsicWidth(
                          //   child: Container(
                          //     padding: EdgeInsets.only(left: 7, right: 7),
                          //     decoration: BoxDecoration(
                          //       color: Colors.blue[100],
                          //       borderRadius: BorderRadius.all(
                          //         Radius.circular(10),
                          //       ),
                          //     ),
                          //     child: Builder(
                          //       builder: (context) {
                          //         course[0]; //will make this array later
                          //         String dynamicText = '';
                          //         if (course[0].length > 17) {
                          //           for (var element
                          //               in course[0].split(' ')) {
                          //             if (element.isNotEmpty &&
                          //                 element[0].toUpperCase() ==
                          //                     element[0]) {
                          //               String sub = element.substring(0, 3);
                          //               dynamicText += sub;
                          //             }
                          //           }
                          //           course[0] = dynamicText;
                          //         }

                          //         return Text(course[0],
                          //             style: TextStyle(
                          //               color: Colors.blue[800],
                          //               fontSize: screenWidth * 0.025,
                          //               fontWeight: FontWeight.w600,
                          //             ));
                          //       },
                          //     ),
                          //   ),
                          // ),
                        ]),
                      ]),
                  Spacer(),
                  if (courseId == null)
                    IconButton(
                      onPressed: () {},
                      icon: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.black),
                        onSelected: (String value) async {
                          switch (value) {
                            // case 'archive':
                            //   if (mentorModel.mentorStatus == 'archived') {
                            //     await CreateMentorController().updateMentorStatus(
                            //         mentorModel.mentorId, 'active');
                            //     onActionComplete!();
                            //   } else {
                            //     await CreateMentorController().updateMentorStatus(
                            //         mentorModel.mentorId, 'archived');
                            //     onActionComplete!();
                            //   }

                            //   break;

                            case 'suspend':
                              if (mentorModel.mentorStatus == 'suspended') {
                                await CreateMentorController()
                                    .updateMentorStatus(
                                        mentorModel.mentorId, 'active');
                                onActionComplete!();
                              } else {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title:
                                        const Text('Confirm Mentor Suspension'),
                                    content: const Text(
                                        'Are you sure you want to suspend this mentor?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Confirm'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  await CreateMentorController()
                                      .updateMentorStatus(
                                          mentorModel.mentorId, 'suspended');
                                  onActionComplete!();
                                }
                              }

                              break;

                            case 'delete':
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Mentor Delete'),
                                  content: const Text(
                                      'Are you sure you want to delete this mentor?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await CreateMentorController()
                                    .deleteMentor(mentorModel.mentorId);
                                onActionComplete!();
                              }
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'suspend',
                            child: Text(mentorModel.mentorStatus == 'suspended'
                                ? 'Lift Suspension'
                                : 'Suspend Mentor'),
                          ),
                          // PopupMenuItem<String>(
                          //   value: 'archive',
                          //   child: Text(mentorModel.mentorStatus == 'archived'
                          //       ? 'Unarchive Mentor'
                          //       : 'Archive Mentor'),
                          // ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete Mentor',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    )
                ]))),
      ),
    );
  }

  Widget _buildDayPills(String fullSchedule, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dayPart = fullSchedule.substring(0, fullSchedule.indexOf(' '));
    final days = _parseDays(dayPart);

    // return Wrap(
    //   spacing: screenWidth * 0.01,
    //   children: days.map((day) => _buildDayPill(day, context)).toList(),
    // );
    return Row(children: [
      Text(
        'Sched: ',
        style: TextStyle(
          color: Colors.black87,
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.bold,
        ),
      ),
      Builder(builder: (context){
        String day = days.join('');
        double baseFontSize = screenWidth * 0.035;
        double dynamicFontSize = day.length > 3
            ? baseFontSize * (4 / day.length)
            : baseFontSize;
        return Text(
          day,
          style: TextStyle(
            color: Colors.black87,
            // fontSize: screenWidth * 0.035,
            fontSize: dynamicFontSize,
            fontWeight: FontWeight.w500,
          ),
        );
      },)
    ]);
  }

  List<String> _parseDays(String dayAbbreviation) {
    final days = <String>[];
    int i = 0;
    while (i < dayAbbreviation.length) {
      if (i + 1 < dayAbbreviation.length &&
          dayAbbreviation.substring(i, i + 2) == 'Th') {
        days.add('Th');
        i += 2;
      } else {
        days.add(dayAbbreviation[i]);
        i += 1;
      }
    }
    return days;
  }

}
