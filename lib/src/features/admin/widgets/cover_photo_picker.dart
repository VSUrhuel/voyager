// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:googleapis/androidpublisher/v3.dart' as google_api;
// import 'dart:io';
// import 'package:voyager/src/widgets/custom_button.dart';

class CoverPhotoPicker extends StatefulWidget {
  const CoverPhotoPicker({super.key});

  @override
  CoverPhotoPickerState createState() => CoverPhotoPickerState();
}

class CoverPhotoPickerState extends State<CoverPhotoPicker> {
  XFile? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    String fileName =
        _image != null ? basename(_image!.path) : 'Choose Course Cover Photo';
    return TextButton(
      onPressed: _pickImage,
      child: Text(
        fileName,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          height: 1,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
