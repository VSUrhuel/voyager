import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';

class Profile extends StatelessWidget {
  final String role;

  const Profile({super.key, required this.role});

  Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'mentee':
        return Colors.green[100] ?? Colors.green;
      case 'mentor':
        return Colors.blue[100] ?? Colors.blue;
      case 'admin':
        return Colors.yellow[100] ?? Colors.yellow;
      default:
        return Colors.grey[500] ??
            Colors.grey; // Default color for unknown roles
    }
  }

  String formatName(String fullName) {
    List<String> nameParts = fullName.split(" ");

    if (nameParts.length < 2)
      return fullName; // Return as is if there's no last name

    // Get the last name and format it properly (capitalize first letter, rest lowercase)
    String lastName = nameParts.last[0].toUpperCase() +
        nameParts.last.substring(1).toLowerCase();

    // Convert all given names (except last) to initials
    String initials = nameParts
        .sublist(0, nameParts.length - 1)
        .map((name) =>
            "${name[0].toUpperCase()}.") // Get first letter and add '.'
        .join(" "); // Join initials with space

    return "$initials $lastName"; // Combine initials and formatted last name
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    User? user = FirebaseAuth.instance.currentUser;
    String formattedName = formatName(user?.displayName ?? '');
    String profileImageURL =
        user?.photoURL ?? 'assets/images/application_images/profile.png';
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(profileImageURL)
                : AssetImage(profileImageURL) as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user?.email}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.005),
                  decoration: BoxDecoration(
                    color: getRoleColor(role),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.grey),
                onPressed: () {
                  FirebaseAuthenticationRepository().logout();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
