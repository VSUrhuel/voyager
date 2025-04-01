import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/schedule_conrtoller.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/upcoming_sched_card.dart';

class UpcomingSession extends StatefulWidget {
  const UpcomingSession({super.key});

  @override
  State<UpcomingSession> createState() => _UpcomingSessionState();
}

class _UpcomingSessionState extends State<UpcomingSession> {
  FirestoreInstance firestore = Get.put(FirestoreInstance());
  ScheduleConrtoller scheduleController = Get.put(ScheduleConrtoller());
  late UserModel user;
  late List<ScheduleModel> upcomingSched = [];
  bool isLoading = true;

  void getUpcomingSchedule() async {
    upcomingSched = await scheduleController.getUpcomingSchedule();
    user = await firestore.getUser(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void initState() {
    super.initState();
    getUpcomingSchedule();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final [sessions, userData] = await Future.wait([
        scheduleController.getUpcomingSchedule(),
        firestore.getUser(FirebaseAuth.instance.currentUser!.uid),
      ]);

      setState(() {
        upcomingSched = sessions as List<ScheduleModel>;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Widget content;

    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (upcomingSched.isEmpty) {
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
          //  padding: const EdgeInsets.all(7),
          itemCount: upcomingSched.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: UpcomingSchedCard(
                scheduleModel: upcomingSched[index],
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
