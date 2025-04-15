import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/screens/home/mentor_profile.dart';
import 'package:voyager/src/features/mentee/widgets/skills_display.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';

class MentorCard extends StatelessWidget {
  final MentorModel mentorModel;
  final UserModel user;
  const MentorCard({super.key, required this.mentorModel, required this.user});

  @override
  Widget build(BuildContext context) {
    // Format name to show initials + last name
    String formatName(String fullName) {
      final nameParts = fullName.split(" ");
      if (nameParts.isEmpty) return "";
      if (nameParts.length == 1) return nameParts[0];
      return "${nameParts[0][0]}. ${nameParts.last}";
    }

    // Get profile image URL
    String getProfileImageUrl() {
      if (user.accountApiPhoto.isEmpty) {
        return 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture/profile.png';
      }
      return user.accountApiPhoto.startsWith('http')
          ? user.accountApiPhoto
          : Supabase.instance.client.storage
              .from('profile-picture')
              .getPublicUrl(user.accountApiPhoto);
    }

    // Shorten motto to max 6 words
    String shortenMotto(String mentorMotto) {
      final words = mentorMotto.split(" ");
      return words.length <= 6
          ? mentorMotto
          : "${words.sublist(0, 6).join(" ")}...";
    }

    final screenSize = MediaQuery.of(context).size;
    final mentorName = formatName(user.accountApiName);
    final motto = shortenMotto(mentorModel.mentorMotto);
    final skills = mentorModel.mentorExpertise;
    final imageUrl = getProfileImageUrl();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MentorProfilePage(
            mentorModel: mentorModel,
            user: user,
          ),
        ),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: screenSize.width * 0.6,
            maxWidth: screenSize.width * 0.6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Container
              SizedBox(
                height: screenSize.height * 0.22,
                child: Stack(
                  children: [
                    // Profile Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.person, size: 50),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Year Badge - positioned at top right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF52CA82),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          mentorModel.mentorYearLvl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content below image
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mentor Name
                    Text(
                      mentorName,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Mentor Motto with icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            motto,
                            style: TextStyle(
                              fontSize: screenSize.width * 0.035,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Single Skill Display
                    if (skills.isNotEmpty) ...[
                      Text(
                        'Expertise',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.038,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SkillsDisplay(
                        color: Theme.of(context).primaryColor,
                        text: skills.first.split(" ").first,
                        widthFactor: 0.4,
                        heightFactor: 0.035,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
