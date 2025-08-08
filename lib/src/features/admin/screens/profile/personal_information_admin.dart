import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Widget _buildCapabilityItem(
    BuildContext context,
    IconData icon,
    String text,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: screenWidth * 0.05,
            // ignore: deprecated_member_use
            color: Theme.of(context).primaryColor.withOpacity(0.7),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCardInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.45,
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Icon(
            //       Icons.info,
            //       color: Theme.of(context).primaryColor,
            //       size: screenWidth * 0.06,
            //     ),
            //     SizedBox(width: screenWidth * 0.03),
            //     Text(
            //       'Admin Info',
            //       style: TextStyle(
            //         fontSize: screenWidth * 0.045,
            //         fontWeight: FontWeight.w600,
            //         color: Theme.of(context).primaryColor,
            //       ),
            //     ),
            //   ],
            // ),

            SizedBox(height: screenHeight * 0.01),

            // Course Info

            Column(
              children: [
                // Admin badge with icon
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: Theme.of(context).primaryColor,
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        "Application Administrator",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Admin capabilities in a card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      children: [
                        Text(
                          "Administrative Privileges",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        _buildCapabilityItem(
                          context,
                          Icons.people_alt,
                          "Manage user accounts and roles",
                          screenWidth,
                        ),
                        _buildCapabilityItem(
                          context,
                          Icons.security,
                          "Configure application permissions",
                          screenWidth,
                        ),
                        _buildCapabilityItem(
                          context,
                          Icons.settings,
                          "Adjust platform settings",
                          screenWidth,
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer note with divider
                SizedBox(height: screenHeight * 0.03),
                Divider(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.3),
                  thickness: 1,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Eduvate Admin Console - Demo Version',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                              // ignore: deprecated_member_use
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

                      _buildAdminCardInfo(context),

                      SizedBox(height: screenHeight * 0.02),

                      // Contact Information
                      _buildSectionTitle("Developer's Contact Information"),
                      SizedBox(height: screenHeight * 0.01),
                      _buildContactInfo(
                          Icons.email, "Email", "johnrhuell@gmail.com"),
                      _buildContactInfo(
                          Icons.phone, "Phone", "+63 (909) 915-3546"),

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
