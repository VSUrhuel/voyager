import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/admin/widgets/admin_initial_mentor_draft.dart';
import 'package:voyager/src/features/admin/widgets/admin_mentor_card.dart';
import 'package:voyager/src/features/admin/widgets/admin_search_bar.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voyager/src/features/admin/screens/mentors/add_mentor.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';

class MentorList extends StatefulWidget {
  const MentorList({super.key});

  @override
  State<MentorList> createState() => _MentorListState();
}

class _MentorListState extends State<MentorList> {
  final firestore = FirestoreInstance();
  List<AdminMentorCard> mentorCards = [];
  List<MentorDraftCard> mentorDraftCards = [];
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
    List<UserModel> initUser = [];
    isLoading = true;
    try {
      if (show == 'archived') {
        mentors = await firestore.getMentorsThroughStatus(show);
        initUser = await firestore.getinitialMentorsCreated(mentors);
      } else {
        mentors = await firestore.getMentorsThroughStatus(show);
      }
    } catch (e) {
      throw Exception('Failed to fetch mentors: $e');
    }

    List<AdminMentorCard> mCards = [];
    List<MentorDraftCard> mDraftCards = [];
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
          onActionComplete: () => getMentors(show),
        ));
      }
      if (show == 'archived' && initUser.isNotEmpty) {
        for (int i = 0; i < initUser.length; i++) {
          var user = initUser[i];
          mDraftCards.add(MentorDraftCard(
            userModel: user,
          ));
        }
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }

    setState(() {
      mentorCards = mCards;
      mentorDraftCards = mDraftCards;
      filteredMentorCards = mCards;
      isLoading = false;
    });
  }

  String search = '';

  List<AdminMentorCard> filter(List<AdminMentorCard> mentorCards) {
    if (search.isNotEmpty) {
      return filteredMentorCards = mentorCards
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
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
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
                        height: screenHeight * 0.038,
                        width: screenWidth * 0.22,
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
                                  mentorCards = [];
                                  show = 'active';
                                  getMentors(show);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color(int.parse(bg)),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                textStyle: TextStyle(
                                  fontSize: screenWidth * 0.04,
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
                        height: screenHeight * 0.038,
                        width: screenWidth * 0.22,
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
                                  mentorCards = [];
                                  show = 'archived';
                                  getMentors(show);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color(int.parse(bg)),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                textStyle: TextStyle(
                                  fontSize: screenWidth * 0.04,
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
                        height: screenHeight * 0.038,
                        width: screenWidth * 0.27,
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
                                  mentorCards = [];
                                  show = 'suspended';
                                  getMentors(show);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color(int.parse(bg)),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                textStyle: TextStyle(
                                  fontSize: screenWidth * 0.04,
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
                              CustomPageRoute(
                                  page: AddMentor(),
                                  direction: AxisDirection.left),
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
                 SizedBox(
                  height: screenHeight * 0.70,
                  child: SingleChildScrollView(
                    child:Column(
                    children: [
                       Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                    ),
                    child: Center(
                      child: Builder(
                        builder: (context){
                          int length;
                          if (mentorCards.length > 5)
                          {
                            length = 5;
                          } else {
                            length = mentorCards.length;
                          }
                          return SizedBox(
                          height: show == 'archived'? (screenHeight * 0.1 )* length : screenHeight * 0.70,
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (isLoading)
                              Lottie.asset(
                                'assets/images/loading.json',
                                fit: BoxFit.cover,
                                width: screenHeight * 0.08,
                                height: screenWidth * 0.04,
                                repeat: true,
                              ),
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
                                  onActionComplete: () => getMentors(show),
                                ),
                            // if (show == 'archived' && mentorDraftCards.isNotEmpty)
                            //   for (var mentorCard in mentorDraftCards)
                            //     MentorDraftCard(
                            //       userModel: mentorCard.userModel,
                            //       // onActionComplete: () => getMentors(show),
                            //     ),
                            SizedBox(height: 10),
                            Builder(
                              builder: (context) {
                                if (isLoading) {
                                  return Text('');
                                }
                                if (mentorCards.isEmpty && show != 'archived') {
                                  return Text('No $show mentor',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screenWidth * 0.033,
                                      ));
                                }
                                if (mentorDraftCards.isEmpty &&
                                    mentorCards.isEmpty &&
                                    show == 'archived') {
                                  return Text('No archived pending mentor',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screenWidth * 0.033,
                                      ));
                                }
                                if (show != 'archived') {
                                  return Text('Nothing follows',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screenWidth * 0.033,
                                      ));
                                }
                                return Text('',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: screenWidth * 0.01,
                                    ));
                              },
                            ),
                          ],
                        ),
                      ),
                      );
                        }
                      ),
                    ),
                  ),
                if (show == 'archived' && mentorDraftCards.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                      ),
                      child: Center(
                        child: SizedBox(
                          height: (screenHeight * 0.11)*mentorDraftCards.length,
                          child: SingleChildScrollView(
                            child: Column(
                          children: [
                           Container(
                            height: 7,
                           decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.grey, width: 4)
                           ),
                           ),
                           ),
                            if (mentorDraftCards.isNotEmpty)
                              for (var mentorCard in mentorDraftCards)
                                MentorDraftCard(
                                  userModel: mentorCard.userModel,
                                  // onActionComplete: () => getMentors(show),
                                ),
                            SizedBox(height: 10),
                            Builder(
                              builder: (context) {
                                if (isLoading) {
                                  return Text('');
                                }
                                // if (mentorDraftCards.isEmpty) {
                                //   return Text('No archived pending mentor',
                                //       style: TextStyle(
                                //         color: Colors.grey,
                                //         fontSize: screenWidth * 0.033,
                                //       ));
                                // }
                                return Text('Nothing follows',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: screenWidth * 0.033,
                                    ));
                              },
                            ),
                          ],
                        ),
                          ),
                          ),
                      ),
                    ),
                    ],
                  ),
                  ),
                 ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
