import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class CompletedCard extends StatefulWidget {
  const CompletedCard({
    super.key,
    required this.email,
    required this.scheduleModel,
    required this.courseName, // Add course name
  });

  final String email;
  final ScheduleModel scheduleModel;
  final String courseName; // Add this line

  @override
  State<CompletedCard> createState() => _CompletedCardState();
}

class _CompletedCardState extends State<CompletedCard> {
  late final FirestoreInstance _firestoreInstance;
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _firestoreInstance = Get.put(FirestoreInstance());
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _firestoreInstance.getUserThroughEmail(widget.email);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          child: Text(
            "Failed to load user data",
            style: TextStyle(fontSize: screenWidth * 0.045),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.01,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      elevation: 1,
      child: CompletedMeetingCard(
        scheduleModel: widget.scheduleModel,
        user: _user!,
        courseName: widget.courseName, // Pass course name here
      ),
    );
  }
}

class CompletedMeetingCard extends StatelessWidget {
  const CompletedMeetingCard({
    super.key,
    required this.scheduleModel,
    required this.user,
    required this.courseName, // Receive course name
  });

  final ScheduleModel scheduleModel;
  final UserModel user;
  final String courseName;

  String _getProfileImageUrl() {
    if (user.accountApiPhoto.isEmpty) {
      return 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture/profile.png';
    }
    return user.accountApiPhoto.startsWith('http')
        ? user.accountApiPhoto
        : Supabase.instance.client.storage
            .from('profile-picture')
            .getPublicUrl(user.accountApiPhoto);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final profileImageUrl = _getProfileImageUrl();
    final dateTimeFormatted =
        "${DateFormat.yMMMd().format(scheduleModel.scheduleDate)} - ${scheduleModel.scheduleStartTime}";

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course name at the top
          Text(
            courseName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),

          Row(
            children: [
              CachedNetworkImage(
                imageUrl: profileImageUrl,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 24,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: 24,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatName(user.accountApiName),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      scheduleModel.scheduleTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dateTimeFormatted,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
