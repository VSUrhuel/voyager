import 'package:flutter/material.dart';

class ProfileListTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? iconData;

  const ProfileListTile(
      {super.key, required this.text, required this.onTap, this.iconData});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.005),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: ListTile(
          leading: iconData != null
              ? Icon(iconData, color: Colors.black54, size: 24)
              : null,
          title: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 18, color: Colors.black54),
          onTap: () {
            onTap();
          },
        ),
      ),
    );
  }
}
