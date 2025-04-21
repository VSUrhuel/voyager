import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/controller/mentee_schedule_controller.dart';
import 'package:voyager/src/features/mentee/screens/session/completed_card.dart';
import 'package:voyager/src/features/mentee/screens/session/upcoming_card.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class MenteeSessionCompleted extends StatefulWidget {
  const MenteeSessionCompleted({super.key});

  @override
  State<MenteeSessionCompleted> createState() => _MenteeSessionCompletedState();
}

class _MenteeSessionCompletedState extends State<MenteeSessionCompleted> {
  final FirestoreInstance firestore = Get.put(FirestoreInstance());
  final MenteeScheduleController menteeScheduleController =
      Get.put(MenteeScheduleController());
  late UserModel user;
  late List<ScheduleModel> completedSessions = [];
  late List<UserModel> completedMentors = [];
  bool isLoading = true;
  final currentUser = FirebaseAuth.instance.currentUser;
  late String userEmail;

  @override
  void initState() {
    super.initState();
    userEmail = currentUser?.email ?? '';
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        menteeScheduleController.getCompletedScheduleForMentee(userEmail),
        menteeScheduleController.getMentorsForCompleted(userEmail),
        firestore.getUser(FirebaseAuth.instance.currentUser!.uid),
      ]);

      final sessions = results[0] as List<ScheduleModel>;
      final mentors = results[1] as List<UserModel>;
      final userData = results[2] as UserModel;

      setState(() {
        completedSessions = sessions;
        completedMentors = mentors;
        user = userData;
        isLoading = false;
      });

      setState(() {
        completedSessions = sessions as List<ScheduleModel>;
        user = userData as UserModel;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Optionally show error message
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    Widget content;

    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (completedSessions.isEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No completed sessions"),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    } else {
      content = RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          //padding: const EdgeInsets.all(5),
          itemCount: completedSessions.length,
          itemBuilder: (context, index) {
            return FutureBuilder<String>(
              future: menteeScheduleController.getCourseNameFromCourseMentorId(
                  completedSessions[index].courseMentorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading course name"));
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: CompletedCard(
                      scheduleModel: completedSessions[index],
                      email: completedMentors[index].accountApiEmail,
                      courseName: snapshot.data ?? "Unknown Course",
                    ),
                  );
                }
              },
            );
          },
        ),
      );
    }

    return SizedBox(
      height: screenHeight * 0.65,
      child: content,
    );
  }
}
