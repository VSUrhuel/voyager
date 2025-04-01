import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: Center(
//           child: CompletedSchedCard(),
//         ),
//       ),
//     );
//   }
// }

class CompletedSchedCard extends StatefulWidget {
  const CompletedSchedCard(
      {super.key, required this.scheduleModel, required this.fullName});
  final ScheduleModel scheduleModel;
  final String fullName;

  @override
  State<CompletedSchedCard> createState() => _CompletedSchedCardState();
}

class _CompletedSchedCardState extends State<CompletedSchedCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MeetingCard(
          scheduleModel: widget.scheduleModel, name: widget.fullName),
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

class MeetingCard extends StatelessWidget {
  const MeetingCard(
      {super.key, required this.scheduleModel, required this.name});
  final ScheduleModel scheduleModel;
  final String name;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String fullName = name; // Replace with actual full name
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
          // Text(
          //   "Today 1:00 PM",
          //   style: TextStyle(
          //     fontSize: screenHeight * 0.025,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
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
                      scheduleModel.scheduleTitle,
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
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${getMonth(scheduleModel.scheduleDate.month)} ${scheduleModel.scheduleDate.day.toString().padLeft(2, '0')}, ${scheduleModel.scheduleDate.year} -  ${scheduleModel.scheduleStartTime}",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getMonth(int ind) {
    switch (ind) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "";
    }
  }
}
