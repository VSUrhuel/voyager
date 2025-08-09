// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 


class CoverPhotoPicker extends StatefulWidget {
    final Function(XFile?)? onImagePicked;
    final XFile? initialImage;
  const CoverPhotoPicker({
    super.key, 
    this.onImagePicked,
    this.initialImage,
    });
  

  @override
  CoverPhotoPickerState createState() => CoverPhotoPickerState();
}

class CoverPhotoPickerState extends State<CoverPhotoPicker> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState(){
    super.initState();
    if (widget.initialImage != null) {
      _image = widget.initialImage;
    }
  }

    void resetImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _pickImage() async {
  try {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {

      final file = File(pickedFile.path);
      if (await file.exists()) {
        setState(() {
          _image = pickedFile;
        });
        

        await Future.delayed(Duration(milliseconds: 50));
        
        if (widget.onImagePicked != null) {
          widget.onImagePicked!(pickedFile);
        }
      } else {
        debugPrint("Selected file doesn't exist at path: ${pickedFile.path}");
      }
    }
  } catch (e) {
    debugPrint("Image picker error: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to load image: ${e.toString()}")),
    );
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
            height: screenHeight * 0.2,
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
                        'Tap to upload cover photo',
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
  // class CoverPhotoPicker extends StatefulWidget {