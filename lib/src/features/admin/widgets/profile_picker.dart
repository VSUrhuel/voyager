

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class ProfilePicker extends StatefulWidget{
  const ProfilePicker({super.key});

  @override
  ProfilePickerState createState() => ProfilePickerState();
}

class ProfilePickerState extends State<ProfilePicker> {
  XFile? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState((){
        _image = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    String fileName = _image != null
    ? basename(_image!.path)
    :'Pick Mentor\'s Profile Picture';
    return TextButton(
          onPressed: _pickImage,
           child: Text(fileName,
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