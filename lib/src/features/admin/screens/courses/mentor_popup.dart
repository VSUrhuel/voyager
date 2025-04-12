import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/admin/widgets/admin_mentor_card.dart';
import 'package:voyager/src/features/admin/widgets/admin_search_bar.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/widgets/normal_search_bar.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voyager/src/features/admin/screens/mentors/add_mentor.dart';



class MentorPopup extends StatefulWidget {
  final String course;
  const MentorPopup({
    super.key,
    required this.course,
    });

  @override
  State<MentorPopup> createState() => _MentorPopupState();
}

class _MentorPopupState extends State<MentorPopup> {
  final firestore = FirestoreInstance();
  List<AdminMentorCard> mentorCards = [];
  List<AdminMentorCard> filteredMentorCards = [];
  bool isLoading = false;
  String show = '';

  @override
  void initState() {
    super.initState();
    show = 'active';
    getMentors(show);
  }

  Future<void> getMentors(show) async {
    List<MentorModel> mentors = [];
    List<CourseMentorModel> courseMentors = [];
    isLoading = true;
    try {
      courseMentors = await firestore.getCourseMentorsThroughCourseId(widget.course);
      mentors = await firestore.getMentorsThroughStatus(show);
       final assignedMentorIds = courseMentors.map((cm) => cm.mentorId).toSet();
      mentors = mentors.where((mentor) => !assignedMentorIds.contains(mentor.mentorId)).toList();
    } catch (e) {
      throw Exception('Failed to fetch mentors: $e');
    }

    List<AdminMentorCard> mCards = [];
    try {
      List<Future<UserModel>> userFutures = mentors.map((mentor) {
        return firestore.getUserThroughAccId(mentor.accountId);
      }).toList();

      List<UserModel> users = await Future.wait(userFutures);

      for (int i = 0; i < mentors.length; i++) {
        var mentor = mentors[i];
        var user = users[i];
        String regDay = '';
        for (var day in mentor.mentorRegDay) {
          if (day.toLowerCase() == 'thursday') {
            regDay += '${day[0]}h';
            continue;
          }
          regDay += day[0];
        }
        mCards.add(AdminMentorCard(
          userModel: user,
          mentorModel: mentor,
          mentor: user.accountApiName,
          email: user.accountApiEmail,
          studentId: user.accountStudentId,
          schedule:
              '$regDay  ${(mentor.mentorRegStartTime.hour % 12).toString().padLeft(2, '0')}:${mentor.mentorRegStartTime.minute.toString().padLeft(2, '0')} - ${(mentor.mentorRegEndTime.hour % 12).toString().padLeft(2, '0')}:${mentor.mentorRegEndTime.minute.toString().padLeft(2, '0')}',
          course: mentor.mentorExpertise,
        ));
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }

    setState(() {
      mentorCards = mCards;
      filteredMentorCards = mCards;
      isLoading = false;
    });
  }

  String search = '';


  List<AdminMentorCard> filter(List<AdminMentorCard> mentorCards) {
    if (search.isNotEmpty) {
      return filteredMentorCards =  mentorCards
          .where((mentorCard) =>
              mentorCard.mentor.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    return mentorCards;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mentor List',
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NormalSearchbar widget
              SizedBox(
                height: screenHeight * 0.09,
                child: AdminSearchbar(
                  onSearchChanged: (query) {
                    setState(() {
                      if (query.isNotEmpty) {
                       search = query;
                      filteredMentorCards = filter(mentorCards);
                      }
                      
                    });
                  },
                ),
              ),
              SizedBox(height: 10),

              // List of Mentor Cards in Scrollable View
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        if (isLoading) CircularProgressIndicator(),
                        if (mentorCards.isNotEmpty)
                          for (var mentorCard in filteredMentorCards)
                            AdminMentorCard(
                              mentorModel: mentorCard.mentorModel,
                              userModel: mentorCard.userModel,
                              mentor: mentorCard.mentor,
                              email: mentorCard.email,
                              studentId: mentorCard.studentId,
                              schedule: mentorCard.schedule,
                              course: mentorCard.course,
                              courseId: widget.course,
                            ),
                        SizedBox(height: 10),
                        Builder(
                          builder: (context) {
                            if (isLoading) {
                              return Text('');
                            }
                            if (mentorCards.isEmpty) {
                              return Text('No $show mentor');
                            }
                            return Text('Nothing follows');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
