import 'package:flutter/material.dart';

class ExperienceContainer extends StatelessWidget {
  final int index;
  final TextEditingController experienceHeader;
  final TextEditingController experienceDesc;
  final VoidCallback? onRemove;

  const ExperienceContainer({
    super.key,
    required this.index,
    required this.experienceHeader,
    required this.experienceDesc,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Experience #$index',
                  style: TextStyle(
                    fontSize: isSmallScreen ? screenWidth * 0.045 : 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onRemove,
                    tooltip: 'Remove experience',
                  ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            TextFormField(
              controller: experienceHeader,
              style: TextStyle(
                fontSize: isSmallScreen ? screenWidth * 0.04 : 16,
              ),
              decoration: InputDecoration(
                labelText: 'Title/Role',
                labelStyle: TextStyle(
                  fontSize: isSmallScreen ? screenWidth * 0.038 : 15,
                  color: Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 12 : 16,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            TextFormField(
              controller: experienceDesc,
              style: TextStyle(
                fontSize: isSmallScreen ? screenWidth * 0.04 : 16,
              ),
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                labelStyle: TextStyle(
                  fontSize: isSmallScreen ? screenWidth * 0.038 : 15,
                  color: Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 12 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
