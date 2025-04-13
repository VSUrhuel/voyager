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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: screenSize.width * 0.6,
            maxWidth: screenSize.width * 0.6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Container(
                height: screenSize.height * 0.22,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52CA82),
                        borderRadius: BorderRadius.circular(20),
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
                    const SizedBox(height: 8),
                    // Mentor Name
                    Text(
                      mentorName,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Mentor Motto
                    Text(
                      motto,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.035,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Skills Display - Show only first 2 skills max
                    if (skills.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (int i = 0; i < skills.length && i < 2; i++)
                            SkillsDisplay(
                              color: i == 0
                                  ? Colors.blue[300]!
                                  : Colors.grey[300]!,
                              text: skills[i].split(" ").first,
                              widthFactor: 0.25,
                              heightFactor: 0.035,
                            ),
                        ],
                      ),
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
