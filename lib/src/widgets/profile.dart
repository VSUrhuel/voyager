import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatefulWidget {
  final String role;

  const Profile({super.key, required this.role});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? profileImage;
  late String fullNmae = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImage();
  }

  Future<void> fetchImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirestoreInstance firestoreInstance = Get.put(FirestoreInstance());
        UserModel userData = await firestoreInstance.getUser(user.uid);
        if (mounted) {
          setState(() {
            profileImage = _validateImageUrl(userData.accountApiPhoto);
            _isLoading = false;
            fullNmae = userData.accountApiName;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          profileImage = null;
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

  Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'mentee':
        return Colors.green[100] ?? Colors.green;
      case 'mentor':
        return Colors.blue[100] ?? Colors.blue;
      case 'admin':
        return Colors.yellow[100] ?? Colors.yellow;
      default:
        return Colors.grey[500] ??
            Colors.grey; // Default color for unknown roles
    }
  }

  String formatName(String fullName) {
    if (fullName.isEmpty) return "John Doe";
    List<String> nameParts = fullName.split(" ");

    if (nameParts.isEmpty) return "";

    if (nameParts.length == 1) {
      // If there's only one name, capitalize the first letter and lowercase the rest
      return nameParts[0][0].toUpperCase() +
          nameParts[0].substring(1).toLowerCase();
    }

    // Extract last name and format it (capitalize first letter, lowercase the rest)
    String lastName = nameParts.last[0].toUpperCase() +
        nameParts.last.substring(1).toLowerCase();

    // Convert all given names (except last) to initials
    String initials = nameParts
        .sublist(0, nameParts.length - 1)
        .map((name) => name[0].toUpperCase()) // Get first letter as uppercase
        .join(""); // Join initials

    return "$initials $lastName"; // Combine initials and formatted last name
  }

  String toCapitalize(String text) {
    String capitalizedText =
        text[0].toUpperCase() + text.substring(1).toLowerCase();
    return capitalizedText;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    User? user = FirebaseAuth.instance.currentUser;
    String formattedName = formatName(fullNmae);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildProfileImage(screenWidth),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user?.email}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.037,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenWidth * 0.006),
                  decoration: BoxDecoration(
                    color: getRoleColor(widget.role),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    toCapitalize(widget.role),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.grey),
                onPressed: () {
                  FirebaseAuthenticationRepository().logout();
                },
              ),
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

    if (profileImage == null) {
      return _buildPlaceholderAvatar();
    }

    return CachedNetworkImage(
      imageUrl: profileImage!,
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
              'assets/images/application_images/profile.png', // Placeholder image path
              fit: BoxFit.cover,
            ),
    );
  }
}
