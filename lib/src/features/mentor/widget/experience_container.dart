import 'package:flutter/material.dart';

class ExperienceContainer extends StatelessWidget {
  final int index;
  final TextEditingController experienceHeader;
  final TextEditingController experienceDesc;

  const ExperienceContainer({
    super.key,
    required this.index,
    required this.experienceHeader,
    required this.experienceDesc,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.only(bottom: screenHeight * 0.00),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                bottom: screenHeight * 0.015, top: screenHeight * 0.015),
            child: TextFormField(
              controller: experienceHeader,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
              ),
              decoration: InputDecoration(
                labelText: 'Experience Header $index',
                labelStyle: TextStyle(
                  fontSize: screenWidth * 0.04,
                  height: 1,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          TextFormField(
            controller: experienceDesc,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
            maxLength: 100,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'About Experience $index',
              labelStyle: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                height: 1,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              counterStyle: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.035,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
