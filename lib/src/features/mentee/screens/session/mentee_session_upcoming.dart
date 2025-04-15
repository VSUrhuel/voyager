import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/controller/mentee_schedule_controller.dart';
import 'package:voyager/src/features/mentee/screens/session/upcoming_card.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class MenteeSessionUpcoming extends StatefulWidget {
  const MenteeSessionUpcoming({super.key});

  @override
  State<MenteeSessionUpcoming> createState() => _MenteeSessionUpcomingState();
}

class _MenteeSessionUpcomingState extends State<MenteeSessionUpcoming> {
  final FirestoreInstance firestore = Get.put(FirestoreInstance());
  final MenteeScheduleController menteeScheduleController =
      Get.put(MenteeScheduleController());
  late UserModel user;
  late List<ScheduleModel> upcomingSched = [];
  late List<UserModel> upcomingMentors = [];
  bool isLoading = true;
  final currentUser = FirebaseAuth.instance.currentUser;
  late String userEmail;

  Future<void> getUpcomingSchedule() async {
    upcomingSched = await menteeScheduleController.getUpcomingScheduleForMentee(
      userEmail, // Pass the userEmail here
    );
    upcomingMentors = await menteeScheduleController.getMentorsForUpcoming(
      userEmail,
    );
  }

  @override
  void initState() {
    super.initState();
    userEmail = currentUser?.email ?? '';
    _loadData(); // only this
  }

  Future<void> _loadData() async {
    try {
      final [sessions, userData, mentors] = await Future.wait([
        menteeScheduleController.getUpcomingScheduleForMentee(userEmail),
        firestore.getUser(FirebaseAuth.instance.currentUser!.uid),
        menteeScheduleController.getMentorsForUpcoming(userEmail),
      ]);

      setState(() {
        upcomingSched = sessions as List<ScheduleModel>;
        user = userData as UserModel;
        upcomingMentors = mentors as List<UserModel>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    Widget content;

    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (upcomingSched.isEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No upcoming sessions."),
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
          itemCount: upcomingSched.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: UpcomingCard(
                scheduleModel: upcomingSched[index],
                email: upcomingMentors[index].accountApiEmail,
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
