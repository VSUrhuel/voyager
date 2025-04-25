import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class UpcomingCard extends StatefulWidget {
  const UpcomingCard(
      {super.key, required this.email, required this.scheduleModel});
  final String email;
  final ScheduleModel scheduleModel;

  @override
  State<UpcomingCard> createState() => _UpcomingCardState();
}

final FirestoreInstance firestoreInstance = Get.put(FirestoreInstance());

class _UpcomingCardState extends State<UpcomingCard> {
  @override
  Widget build(BuildContext context) {
    final Future<UserModel> userName =
        firestoreInstance.getUserThroughEmail(widget.email);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<UserModel>(
        future: userName,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator
          } else if (snapshot.hasError) {
            return const Text('Error loading user data'); // Handle error
          } else if (snapshot.hasData) {
            return MeetingCard(
              scheduleModel: widget.scheduleModel,
              email: snapshot.data!.accountApiName,
            );
          } else {
            return const Text('No user data available'); // Handle no data
          }
        },
      ),
    );
  }
}

String formatName(String fullName) {
  if (fullName.isEmpty) return "John Doe";
  // Trim and remove extra spaces
  fullName = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
  List<String> nameParts = fullName.split(" ");

  if (nameParts.isEmpty) return "John Doe";

  // Handle single name
  if (nameParts.length == 1) {
    return nameParts[0].isNotEmpty
        ? nameParts[0][0].toUpperCase() +
            nameParts[0].substring(1).toLowerCase()
        : "John Doe";
  }

  // Format last name
  String lastName = nameParts.last.isNotEmpty
      ? nameParts.last[0].toUpperCase() +
          nameParts.last.substring(1).toLowerCase()
      : "";

  // Format initials
  String initials = nameParts
      .sublist(0, nameParts.length - 1)
      .where((name) => name.isNotEmpty)
      .map((name) => name[0].toUpperCase())
      .join("");

  return "$initials $lastName".trim();
}

class MeetingCard extends StatefulWidget {
  const MeetingCard(
      {super.key, required this.scheduleModel, required this.email});
  final ScheduleModel scheduleModel;
  final String email;

  @override
  State<MeetingCard> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  var profileImageURL = '';
  bool _isLoading = true;
  bool _hasError = false;
  @override
  void initState() {
    super.initState();
    fetchImage();
  }

  void fetchImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestoreInstance = Get.put(FirestoreInstance());
        final userData = await firestoreInstance.getUser(user.uid);
        if (mounted) {
          setState(() {
            profileImageURL = userData.accountApiPhoto;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String fullName = widget.email;
    String formattedName = formatName(fullName);

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
              _buildProfileImage(screenWidth),
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
              // ElevatedButton(
              //   onPressed: () {
              //     // Handle view action
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blue,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //   ),
              //   child:
              //       const Text("View", style: TextStyle(color: Colors.white)),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(double screenWidth) {
    if (_isLoading) {
      return _buildPlaceholderAvatar(isLoading: true);
    }

    if (profileImageURL == '' || _hasError) {
      return _buildPlaceholderAvatar();
    }

    return CachedNetworkImage(
      imageUrl: profileImageURL,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 30,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => _buildPlaceholderAvatar(isLoading: true),
      errorWidget: (context, url, error) => _buildPlaceholderAvatar(),
    );
  }

  Widget _buildPlaceholderAvatar({bool isLoading = false}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[600],
              ),
            )
          : Image.asset(
              'assets/images/application_images/profile.png',
              fit: BoxFit.cover,
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
    } else if (difference.inMinutes == 1) {
      return "1 min to go";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} mins to go";
    } else if (difference.inHours == 1) {
      return "1 hour to go";
    } else if (difference.inHours < 24) {
      return "${(difference.inHours).toString()} hours to go";
    } else if (difference.inDays == 1) {
      return "${(difference.inDays).toString()} day to go";
    } else {
      return "${(difference.inDays).toString()} days to go";
    }
  }
}
