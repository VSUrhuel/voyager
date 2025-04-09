import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/schedule_conrtoller.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/completed_sched_card.dart';

class CompletedSession extends StatefulWidget {
  const CompletedSession({super.key});

  @override
  State<CompletedSession> createState() => _CompletedSessionState();
}

class _CompletedSessionState extends State<CompletedSession> {
  final FirestoreInstance firestore = Get.put(FirestoreInstance());
  final ScheduleConrtoller scheduleController = Get.put(ScheduleConrtoller());
  late UserModel user;
  late List<ScheduleModel> completedSessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final [sessions, userData] = await Future.wait([
        scheduleController.getCompletedSchedule(),
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
                fullName: user.accountApiName,
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
