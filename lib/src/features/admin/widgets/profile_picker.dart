import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 

class ProfilePicker extends StatefulWidget {
  final Function(XFile?)? onImagePicked;
  const ProfilePicker({super.key, this.onImagePicked});

  @override
  ProfilePickerState createState() => ProfilePickerState();
}

class ProfilePickerState extends State<ProfilePicker> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

    void resetImage() {
    setState(() {
      _image = null;
    });
    // widget.onImagePicked(null); // Notify parent
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, 
      );

      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
        
        if (widget.onImagePicked != null) {
          widget.onImagePicked!(_image);
        }
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.2, // Increased height for better preview
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: screenWidth * 0.08,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to upload profile picture',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_image!.path), // Display the selected image
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover, // Ensure the image covers the container
                ),
              ),
      ),
    );
  }
}