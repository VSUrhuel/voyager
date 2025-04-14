import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/controller/mentee_schedule_controller.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/completed_sched_card.dart';

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
      final [sessions, userData] = await Future.wait([
        menteeScheduleController.getCompletedScheduleForMentee(
            userEmail), // Pass the userEmail here
        firestore.getUser(FirebaseAuth.instance.currentUser!.uid),
      ]);

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
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: CompletedSchedCard(
                scheduleModel: completedSessions[index],
                fullName: user.accountApiEmail,
              ),
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
