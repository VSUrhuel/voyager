import 'package:voyager/src/features/admin/widgets/admin_mentor_card.dart';
import 'package:voyager/src/features/admin/widgets/admin_search_bar.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/widgets/normal_search_bar.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voyager/src/features/admin/screens/mentors/add_mentor.dart';



class MentorList extends StatefulWidget {
  const MentorList({super.key});

  @override
  State<MentorList> createState() => _MentorListState();
}

class _MentorListState extends State<MentorList> {
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
    isLoading = true;
    try {
      mentors = await firestore.getMentorsThroughStatus(show);
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


              // Buttons to filter mentors by status (active, archived, suspended)
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05, right: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active Button
                    SizedBox(
                      height: screenHeight * 0.030,
                      width: screenWidth * 0.18,
                      child: Builder(
                        builder: (context) {
                          String bg = '0xFFa6a2a2';
                          String txt = '0xFF4A4A4A';

                          if (show == 'active') {
                            bg = '0xFF7eb3f7';
                            txt = '0xFF0765e0';
                          }
                          return OutlinedButton(
                            onPressed: () {
                              setState(() {
                                show = 'active';
                                getMentors(show);
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(int.parse(bg)),
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              textStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide.none,
                              foregroundColor: Color(int.parse(txt)),
                            ),
                            child: Text('Active'),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),

                    // Archived Button
                    SizedBox(
                      height: screenHeight * 0.030,
                      width: screenWidth * 0.18,
                      child: Builder(
                        builder: (context) {
                          String bg = '0xFFa6a2a2';
                          String txt = '0xFF4A4A4A';

                          if (show == 'archived') {
                            bg = '0xFF7eb3f7';
                            txt = '0xFF0765e0';
                          }
                          return OutlinedButton(
                            onPressed: () {
                              setState(() {
                                show = 'archived';
                                getMentors(show);
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(int.parse(bg)),
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              textStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide.none,
                              foregroundColor: Color(int.parse(txt)),
                            ),
                            child: Text('Archived'),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),

                    // Suspended Button
                    SizedBox(
                      height: screenHeight * 0.030,
                      width: screenWidth * 0.19,
                      child: Builder(
                        builder: (context) {
                          String bg = '0xFFa6a2a2';
                          String txt = '0xFF4A4A4A';

                          if (show == 'suspended') {
                            bg = '0xFF7eb3f7';
                            txt = '0xFF0765e0';
                          }
                          return OutlinedButton(
                            onPressed: () {
                              setState(() {
                                show = 'suspended';
                                getMentors(show);
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(int.parse(bg)),
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              textStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide.none,
                              foregroundColor: Color(int.parse(txt)),
                            ),
                            child: Text('Suspended'),
                          );
                        },
                      ),
                    ),
                    Spacer(),

                    // Add Mentor Button
                    SizedBox(
                      height: screenHeight * 0.035,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddMentor()),
                          );
                        },
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ],
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
