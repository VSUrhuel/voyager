import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/screens/home/mentor_profile.dart';
import 'package:voyager/src/features/mentee/widgets/skills_display.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';

class MentorCard extends StatelessWidget {
  final MentorModel mentorModel;
  final UserModel user;
  final bool isSmallCard;
  const MentorCard(
      {super.key,
      required this.mentorModel,
      required this.user,
      this.isSmallCard = false});

  @override
  Widget build(BuildContext context) {
    // Format name to show initials + last name
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
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallCard ? 8 : 12,
                          vertical: isSmallCard ? 4 : 6,
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
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallCard ? 10 : 12,
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
                    isSmallCard
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mentorName,
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.045,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '@${user.accountUsername}',
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.03,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mentorName,
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.045,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '@${user.accountUsername}',
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.03,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Single Skill Display

                    if (skills.isNotEmpty && !isSmallCard) ...[
                      Text(
                        'Expertise',
                        style: TextStyle(
                            fontSize: screenSize.width * 0.035,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32, // Fixed height for skills row
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: skills.take(3).map((skill) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SkillsDisplay(
                                color: Theme.of(context).colorScheme.primary,
                                text: skill.trim(),
                                isPrimary: skills.indexOf(skill) == 0,
                              ),
                            );
                          }).toList(),
                        ),
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
