import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
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
