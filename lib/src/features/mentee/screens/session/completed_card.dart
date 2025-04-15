import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class UpcomingCard extends StatefulWidget {
  const UpcomingCard({
    super.key,
    required this.email,
    required this.scheduleModel,
  });

  final String email;
  final ScheduleModel scheduleModel;

  @override
  State<UpcomingCard> createState() => _UpcomingCardState();
}

class _UpcomingCardState extends State<UpcomingCard> {
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
    final isSmallScreen = screenWidth < 360 || screenHeight < 700;

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
            style: TextStyle(
              fontSize:
                  isSmallScreen ? screenWidth * 0.04 : screenWidth * 0.045,
            ),
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
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: MeetingCard(
          scheduleModel: widget.scheduleModel,
          user: _user!,
          isSmallScreen: isSmallScreen,
        ),
      ),
    );
  }
}

class MeetingCard extends StatelessWidget {
  const MeetingCard({
    super.key,
    required this.scheduleModel,
    required this.user,
    required this.isSmallScreen,
  });

  final ScheduleModel scheduleModel;
  final UserModel user;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fullName = _formatName(user.accountUsername);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${DateFormat('MMM d, y').format(scheduleModel.scheduleDate)} • ${scheduleModel.scheduleStartTime}",
              style: TextStyle(
                fontSize:
                    isSmallScreen ? screenWidth * 0.04 : screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getRemainingTime(scheduleModel),
              style: TextStyle(
                fontSize:
                    isSmallScreen ? screenWidth * 0.035 : screenWidth * 0.04,
                color: const Color(0xFF52CA82),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImage(user),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen
                          ? screenWidth * 0.04
                          : screenWidth * 0.045,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    scheduleModel.scheduleTitle,
                    style: TextStyle(
                      fontSize: isSmallScreen
                          ? screenWidth * 0.035
                          : screenWidth * 0.04,
                      color: Colors.grey[700],
                    ),
                    maxLines: isSmallScreen ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileImage(UserModel user) {
    final url = _getProfileImageUrl(user.accountApiPhoto);

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: isSmallScreen ? 20 : 25,
        backgroundImage: imageProvider,
      ),
      placeholder: (_, __) => CircleAvatar(
        radius: isSmallScreen ? 20 : 25,
        backgroundColor: Colors.grey[200],
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (_, __, ___) => CircleAvatar(
        radius: isSmallScreen ? 20 : 25,
        backgroundColor: Colors.grey[200],
        child: Icon(
          Icons.person,
          size: isSmallScreen ? 20 : 25,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _getProfileImageUrl(String apiPhoto) {
    if (apiPhoto.isEmpty) {
      return 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture/profile.png';
    }
    return apiPhoto.startsWith('http')
        ? apiPhoto
        : Supabase.instance.client.storage
            .from('profile-picture')
            .getPublicUrl(apiPhoto);
  }

  String _formatName(String? name) {
    if (name == null || name.trim().isEmpty) return "Unknown";

    final parts = name.trim().split(" ");
    if (parts.length == 1) return _capitalize(parts.first);

    final initials = parts
        .sublist(0, parts.length - 1)
        .map((e) => e[0].toUpperCase())
        .join();
    final lastName = _capitalize(parts.last);

    return "$initials $lastName";
  }

  String _capitalize(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();

  String _getRemainingTime(ScheduleModel model) {
    final instance = Get.find<FirestoreInstance>();
    final startTime = instance.parseTimeString(model.scheduleStartTime);
    final sessionDate = DateTime(
        model.scheduleDate.year,
        model.scheduleDate.month,
        model.scheduleDate.day,
        startTime.hour,
        startTime.minute);
    final now = DateTime.now();
    final diff = sessionDate.difference(now);

    if (diff.isNegative) return "Session ended";
    if (diff.inMinutes == 0) return "Starting now";
    if (diff.inMinutes == 1) return "1 min to go";
    if (diff.inMinutes < 60) return "${diff.inMinutes} mins to go";
    if (diff.inHours == 1) return "1 hour to go";
    if (diff.inHours < 24) return "${diff.inHours} hours to go";
    if (diff.inDays == 1) return "1 day to go";

    return "${diff.inDays} days to go";
  }
}
