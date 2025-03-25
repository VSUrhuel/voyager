import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: UpcomingSchedCard(),
        ),
      ),
    );
  }
}

class UpcomingSchedCard extends StatelessWidget {
  const UpcomingSchedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MeetingCard(),
    );
  }
}

String formatName(String fullName) {
  List<String> nameParts = fullName.split(" ");

  if (nameParts.length < 2) {
    return fullName; // Return as is if there's no last name
  }

  // The last name is always the last word in the full name
  String lastName = nameParts.last;

  // Convert all given names (except last) to initials
  String initials = nameParts
      .sublist(0, nameParts.length - 1)
      .map((name) => "${name[0]}.") // Get first letter and add '.'
      .join(" "); // Join initials with space

  return "$initials $lastName"; // Combine initials and last name
}

class MeetingCard extends StatelessWidget {
  const MeetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String fullName = "John Rhuel Laurente";
    List<String> nameParts = fullName.split(" ");
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
            "Today 1:00 PM",
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
                      "CS3 Mentor Since 2022",
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
                "15 mins to go",
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
}
