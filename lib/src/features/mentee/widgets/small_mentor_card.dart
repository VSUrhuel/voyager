import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/screens/home/mentor_profile.dart';
import 'package:voyager/src/features/mentee/widgets/skills_display.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';

class SmallMentorCard extends StatelessWidget {
  final MentorModel mentorModel;
  final UserModel user;
  const SmallMentorCard({
    super.key,
    required this.mentorModel,
    required this.user,
  });

  String formatName(String fullName) {
    List<String> nameParts = fullName.split(" ");
    if (nameParts.isEmpty) return "";
    if (nameParts.length == 1) return nameParts[0];
    return "${nameParts[0][0]}. ${nameParts.last}";
  }

  String shortenMotto(String mentorMotto) {
    List<String> words = mentorMotto.split(" ");
    if (words.length <= 6) return mentorMotto;
    return "${words.sublist(0, 6).join(" ")}...";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final mentorName = formatName(user.accountApiName);
    final motto = shortenMotto(mentorModel.mentorMotto);
    final primarySkill = mentorModel.mentorExpertise.isNotEmpty
        ? mentorModel.mentorExpertise[0].split(" ").first
        : null;

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
        child: SizedBox(
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Container(
                height: 135,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/images/application_images/profile.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  color: Colors.grey[300],
                ),
              ),
              // Details Section
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
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
                    // Name
                    Text(
                      mentorName,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Motto
                    Text(
                      motto,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Single Skill
                    if (primarySkill != null)
                      SkillsDisplay(
                        color: Colors.blue[300]!,
                        text: primarySkill,
                        widthFactor: 0.4,
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
