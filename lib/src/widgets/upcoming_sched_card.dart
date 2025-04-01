import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class UpcomingSchedCard extends StatefulWidget {
  const UpcomingSchedCard(
      {super.key, required this.fullName, required this.scheduleModel});
  final String fullName;
  final ScheduleModel scheduleModel;

  @override
  State<UpcomingSchedCard> createState() => _UpcomingSchedCardState();
}

class _UpcomingSchedCardState extends State<UpcomingSchedCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MeetingCard(
          scheduleModel: widget.scheduleModel, fullName: widget.fullName),
    );
  }
}

String formatName(String fullName) {
  List<String> nameParts = fullName.split(" ");

  if (nameParts.isEmpty) return "";

  if (nameParts.length == 1) {
    // If there's only one name, capitalize the first letter and lowercase the rest
    return nameParts[0][0].toUpperCase() +
        nameParts[0].substring(1).toLowerCase();
  }

  // Extract last name and format it (capitalize first letter, lowercase the rest)
  String lastName = nameParts.last[0].toUpperCase() +
      nameParts.last.substring(1).toLowerCase();

  // Convert all given names (except last) to initials
  String initials = nameParts
      .sublist(0, nameParts.length - 1)
      .map((name) => name[0].toUpperCase()) // Get first letter as uppercase
      .join(""); // Join initials

  return "$initials $lastName"; // Combine initials and formatted last name
}

class MeetingCard extends StatefulWidget {
  const MeetingCard(
      {super.key, required this.scheduleModel, required this.fullName});
  final ScheduleModel scheduleModel;
  final String fullName;

  @override
  State<MeetingCard> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String fullName = widget.fullName;
    String formattedName = formatName(fullName);
    User? user = FirebaseAuth.instance.currentUser;
    String profileImageURL =
        user?.photoURL ?? 'assets/images/application_images/profile.png';
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Prevent infinite height issue
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${DateFormat('MMM d, y').format(widget.scheduleModel.scheduleDate)} | ${widget.scheduleModel.scheduleStartTime}",
            style: TextStyle(
              fontSize: screenHeight * 0.025,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage:
                    NetworkImage(profileImageURL), // Replace with actual image
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.02,
                      ),
                    ),
                    Text(
                      widget.scheduleModel.scheduleTitle,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [],
              )
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Divider(),
          SizedBox(height: screenHeight * 0.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getRemainingTime(widget.scheduleModel.scheduleStartTime,
                    widget.scheduleModel.scheduleDate),
                style: TextStyle(color: Colors.blue),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle view action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    const Text("View", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getRemainingTime(String startTime, DateTime date) {
    FirestoreInstance firestoreInstance = Get.put(FirestoreInstance());
    final convertedTime = firestoreInstance.parseTimeString(startTime);
    final now = DateTime.now();
    DateTime newDate = DateTime(
      date.year,
      date.month,
      date.day,
      convertedTime.hour,
      convertedTime.minute,
    );
    final difference = newDate.difference(now);
    if (difference.isNegative) {
      return "Session has ended";
    } else if (difference.inMinutes == 0) {
      return "Session is starting now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} mins to go";
    } else if (difference.inHours < 24) {
      return "${(difference.inHours).toString()} hours to go";
    } else {
      return "${(difference.inDays).toString()} days to go";
    }
  }
}
