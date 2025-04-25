import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
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
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Lottie.asset(
              'assets/images/loading.json',
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.width * 0.3,
              repeat: true,
            ),
            Text(
              "Loading sessions...",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    } else if (upcomingSched.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/images/empty-session.json',
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                repeat: true,
              ),
              const SizedBox(height: 24),
              Text(
                "No upcoming Sessions Yet",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Your upcoming mentoring sessions will appear here",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text("Refresh Sessions"),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    } else {
      content = RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          //  padding: const EdgeInsets.all(7),
          itemCount: upcomingSched.isEmpty ? 0 : upcomingSched.length,
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
