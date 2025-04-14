import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';

class PickMentorCard extends StatelessWidget {
  final MentorModel mentorModel;
  final UserModel user;
  final bool isSelected;
  final VoidCallback onTap;

  const PickMentorCard({
    super.key,
    required this.mentorModel,
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String formatTime(TimeOfDay time) {
      final now = DateTime.now();
      final dateTime =
          DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mm a').format(dateTime);
    }

    String formatDays(List<String> days) {
      return days.map((day) {
        if (day == 'Thursday') {
          return 'Th';
        } else {
          return day[0];
        }
      }).join('');
    }

    final supabase = Supabase.instance.client;
    final imageUrl = (user.accountApiPhoto.isNotEmpty)
        ? (user.accountApiPhoto.startsWith('http')
            ? user.accountApiPhoto
            : supabase.storage
                .from('profile-picture')
                .getPublicUrl(user.accountApiPhoto))
        : 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture/profile.png';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
          color: Colors.white,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: screenWidth * 0.18,
                height: screenWidth * 0.18,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),

            // Mentor Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.accountApiName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    "Schedule: ${formatDays(mentorModel.mentorRegDay)} ${formatTime(mentorModel.mentorRegStartTime)} - ${formatTime(mentorModel.mentorRegEndTime)}",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // Year Level Tag
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.003,
                        horizontal: screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mentorModel.mentorYearLvl,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
