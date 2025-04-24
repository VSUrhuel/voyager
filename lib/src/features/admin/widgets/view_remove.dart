import 'package:flutter/material.dart';

Future<void> _showCustomDialog(BuildContext context) async {
  final choice = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Make a choice'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Choice A'),
            onTap: () => Navigator.pop(context, 'Choice A'),
          ),
          ListTile(
            title: Text('Choice B'),
            onTap: () => Navigator.pop(context, 'Choice B'),
          ),
          ListTile(
            title: Text('Choice C'),
            onTap: () => Navigator.pop(context, 'Choice C'),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );

  if (choice != null) {
    // Handle the selected choice
    print('Selected: $choice');
  }
}