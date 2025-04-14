import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/apigeeregistry/v1.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';

class AdminPersonalInformation extends StatefulWidget {
  const AdminPersonalInformation({
    super.key,
    required this.userModel,
  });
  final UserModel userModel;

  @override
  State<AdminPersonalInformation> createState() =>
      _AdminPersonalInformationState();
}

class _AdminPersonalInformationState extends State<AdminPersonalInformation> {
  late UserModel userModel;

  @override
  void initState() {
    super.initState();
    userModel = widget.userModel;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final supabase = Supabase.instance.client;
    final imageUrl = (userModel.accountApiPhoto.isNotEmpty)
        ? (userModel.accountApiPhoto.startsWith('http')
            ? userModel.accountApiPhoto
            : supabase.storage
                .from('profile-picture')
                .getPublicUrl(userModel.accountApiPhoto))
        : 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture/profile.png';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            // Profile Header with Image
            SliverAppBar(
              expandedHeight: screenHeight * 0.3,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              backgroundColor: Colors.transparent,
            ),

            // Profile Content
            SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Admin Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userModel.accountApiName,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.028,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userModel.accountApiEmail,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: screenHeight * 0.018,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Administrator",
                              style: TextStyle(
                                color: Color(0xFF1877F2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // About Section
                      _buildSectionTitle("About"),
                      SizedBox(height: screenHeight * 0.01),
                      _buildInfoCard(
                          "As the administrator of Eduvate, I oversee the platform's operations, ensuring smooth functionality and user satisfaction. My role involves managing user accounts, resolving technical issues, and implementing platform improvements to enhance the mentorship experience for both mentors and mentees.",
                          context),

                      SizedBox(height: screenHeight * 0.02),

                      // Responsibilities Section
                      _buildSectionTitle("Key Responsibilities"),
                      SizedBox(height: screenHeight * 0.01),
                      _buildResponsibilityItem(
                          "Platform Management", Icons.settings),
                      _buildResponsibilityItem(
                          "User Support", Icons.support_agent),
                      _buildResponsibilityItem(
                          "Content Moderation", Icons.verified_user),
                      _buildResponsibilityItem(
                          "Feature Implementation", Icons.developer_mode),

                      SizedBox(height: screenHeight * 0.02),

                      // Contact Information
                      _buildSectionTitle("Contact Information"),
                      SizedBox(height: screenHeight * 0.01),
                      _buildContactInfo(
                          Icons.email, "Admin Email", "admin@eduvate.com"),
                      _buildContactInfo(
                          Icons.phone, "Support Line", "+63 (909) 915-3546"),

                      SizedBox(height: screenHeight * 0.04),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1877F2),
      ),
    );
  }

  Widget _buildInfoCard(String text, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildResponsibilityItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF1877F2), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
