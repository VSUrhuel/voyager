import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/controller/mentee_schedule_controller.dart';
import 'package:voyager/src/features/mentee/screens/session/completed_card.dart';
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
        completedSessions = sessions;
        user = userData;
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
    } else if (completedSessions.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Lottie.asset(
                'assets/images/empty-session.json',
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                repeat: true,
              ),
              const SizedBox(height: 2),
              Text(
                "No Completed Sessions Yet",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Your completed mentoring sessions will appear here",
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
      height: screenHeight * 0.53,
      child: content,
    );
  }
}
