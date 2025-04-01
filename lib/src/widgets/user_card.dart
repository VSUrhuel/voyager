// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

// ignore: must_be_immutable
class UserCard extends StatelessWidget {
  UserCard(
      {super.key,
      required this.user,
      required this.height,
      required this.actions,
      required this.onActionCompleted});

  final UserModel user;
  final double height;
  final List<String> actions;
  final VoidCallback? onActionCompleted;

  FirestoreInstance firestore = FirestoreInstance();

  Future<void> updateStatus(UserModel user, String status) async {
    MentorModel mentor = await firestore
        .getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);
    String courseMentorId = await firestore.getCourseMentorId(mentor.mentorId);
    String menteeId = await firestore.getMenteeId(user.accountApiID);
    await firestore.updateMennteeAlocStatus(courseMentorId, menteeId, status);
    Future.delayed(const Duration(seconds: 3));
  }

  Future<void> approveMentee(UserModel user) async {
    //get ID sa mentor
    //get courseAlloc of the mentor
    //modify the menteeCourseAlloc status with the same courseAlloc and menteeID

    MentorModel mentor = await firestore
        .getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);

    String courseMentorId = await firestore.getCourseMentorId(mentor.mentorId);

    String menteeId = await firestore.getMenteeId(user.accountApiID);
    await firestore.updateMennteeAlocStatus(
        courseMentorId, menteeId, 'approved');
  }

  Future<void> rejectMentee(UserModel user) async {}

  Future<void> removeMentee(UserModel user) async {}

  Future<void> blockMentee(UserModel user) async {}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    void showMessage(BuildContext context, String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    return Container(
      width: screenWidth * 0.85,
      height: screenHeight * 0.11, // Slightly increased for better spacing
      padding: EdgeInsets.only(left: screenHeight * 0.007, top: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: const Color(0xFF9494A0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(9),
              bottomLeft: Radius.circular(9),
            ),
            child: Image.asset(
              'assets/images/application_images/code.jpg',
              width: screenWidth * 0.15,
              height: screenHeight * 0.09,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10), // Spacing

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.accountApiName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user.accountApiEmail,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.016,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                ),
                Text(
                  user.accountStudentId,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.015,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // More options button
          actions.isEmpty
              ? const SizedBox()
              : PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: screenHeight * 0.035,
                  ),
                  onSelected: (value) async {
                    if (value == 'Accept') {
                      await updateStatus(user, 'accepted');

                      showMessage(context, 'Accepted');
                    } else if (value == 'Reject') {
                      await updateStatus(user, 'rejected');
                      showMessage(context, 'Rejected');
                    } else if (value == 'Remove') {
                      await updateStatus(user, 'removed');
                      showMessage(context, 'Removed');
                    }
                    onActionCompleted!.call();
                  },
                  itemBuilder: (BuildContext context) => List.generate(
                      actions.length,
                      (index) => PopupMenuItem<String>(
                            value: actions[index],
                            child: Text(actions[index]),
                          )) as List<PopupMenuEntry<String>>,
                ),
        ],
      ),
    );
  }
}
