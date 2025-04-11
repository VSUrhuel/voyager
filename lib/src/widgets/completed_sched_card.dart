import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class CompletedSchedCard extends StatefulWidget {
  const CompletedSchedCard({
    super.key,
    required this.scheduleModel,
    required this.fullName,
  });

  final ScheduleModel scheduleModel;
  final String fullName;

  @override
  State<CompletedSchedCard> createState() => _CompletedSchedCardState();
}

class _CompletedSchedCardState extends State<CompletedSchedCard> {
  String? _profileImageUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestoreInstance = Get.put(FirestoreInstance());
        final userData = await firestoreInstance.getUser(user.uid);
        if (mounted) {
          setState(() {
            _profileImageUrl = _validateImageUrl(userData.accountApiPhoto);
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

  String? _validateImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (!url.startsWith('http') && !url.startsWith('https')) return null;
    return url;
  }

  String _formatName(String fullName) {
    final nameParts =
        fullName.split(" ").where((part) => part.isNotEmpty).toList();
    if (nameParts.isEmpty) return "";

    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase() +
          nameParts[0].substring(1).toLowerCase();
    }

    final lastName = nameParts.last[0].toUpperCase() +
        nameParts.last.substring(1).toLowerCase();
    final initials = nameParts
        .sublist(0, nameParts.length - 1)
        .map((name) => name.isNotEmpty ? name[0].toUpperCase() : "")
        .join("");

    return "$initials $lastName";
  }

  String _getMonth(int monthIndex) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return (monthIndex >= 1 && monthIndex <= 12) ? months[monthIndex] : "";
  }

  Widget _buildProfileImage() {
    if (_isLoading) {
      return _buildPlaceholderAvatar(isLoading: true);
    }

    if (_profileImageUrl == null || _hasError) {
      return _buildPlaceholderAvatar();
    }

    return CachedNetworkImage(
      imageUrl: _profileImageUrl!,
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final formattedName = _formatName(widget.fullName);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: screenSize.width * 0.9,
        padding: EdgeInsets.all(screenSize.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenSize.width * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenSize.width * 0.04),
            Row(
              children: [
                _buildProfileImage(),
                SizedBox(width: screenSize.width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenSize.height * 0.02,
                        ),
                      ),
                      Text(
                        widget.scheduleModel.scheduleTitle,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.height * 0.02),
            const Divider(),
            SizedBox(height: screenSize.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_getMonth(widget.scheduleModel.scheduleDate.month)} "
                  "${widget.scheduleModel.scheduleDate.day.toString().padLeft(2, '0')}, "
                  "${widget.scheduleModel.scheduleDate.year} - "
                  "${widget.scheduleModel.scheduleStartTime}",
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
