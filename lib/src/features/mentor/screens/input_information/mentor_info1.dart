import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voyager/src/features/admin/widgets/profile_picker.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/about_controller.dart';
import 'package:voyager/src/features/mentor/controller/mentor_controller.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/screens/input_information/mentor_info2.dart';
import 'package:voyager/src/features/mentor/widget/image_preview_dialog.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_button.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MentorInfo1 extends StatefulWidget {
  const MentorInfo1({super.key, this.mentorModel, this.userModel});
  final UserModel? userModel;
  final MentorModel? mentorModel;

  @override
  State<MentorInfo1> createState() => _MentorInfo1State();
}

class _MentorInfo1State extends State<MentorInfo1> {
  final AboutController aboutController = AboutController();
  File _image = File('');
  String imageUrl = '';
  final controller = Get.put(MentorController());

  Future<UserModel?> getUserModel(String email) async {
    try {
      return await FirestoreInstance().getUserThroughEmail(email);
    } catch (e) {
      return null;
    }
  }

  void _showImagePreview(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => ImagePreviewDialog(imageFile: imageFile),
    );
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) return;
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _image = pickedImageFile;
    });
    _showImagePreview(pickedImageFile);
  }

  String getName(String? name) {
    List names = name!.split(' ');
    return names.sublist(0, names.length - 1).join(' ');
  }

  bool hasParam = false;

  @override
  void initState() {
    super.initState();
    hasParam = widget.mentorModel != null;
    if (hasParam) {
      controller.mentorYearLvl.text = widget.mentorModel!.mentorYearLvl;
      controller.mentorAbout.text = widget.mentorModel!.mentorAbout;
      controller.mentorSessionCompleted.text =
          widget.mentorModel!.mentorSessionCompleted.toString();
      controller.mentorUserName.text = widget.userModel!.accountUsername;
      controller.mentorMotto.text = widget.mentorModel!.mentorMotto;
      controller.selectedLanguages = widget.mentorModel!.mentorLanguages.obs;
      imageUrl = widget.userModel!.accountApiPhoto;
    }
  }

  @override
  void dispose() {
    super.dispose();

    // controller.mentorYearLvl.clear();
    // controller.mentorAbout.clear();
    // controller.mentorUserName.clear();
    // controller.mentorSessionCompleted.clear();
    // controller.mentorMotto.clear();
    // controller.mentorLanguages.clear();
    // controller.mentorExpHeader.clear();
    // controller.mentorExpDesc.clear();
    // controller.mentorRegDay.clear();
    // controller.mentorRegStartTime.clear();
    // controller.mentorRegEndTime.clear();
    // controller.mentorFbUrl.clear();
    // controller.mentorGitUrl.clear();
    // controller.mentorStatus.clear();
    // controller.mentorExpertise.clear();
    // controller.mentorSoftDeleted.clear();
    // controller.selectedSkills.clear();
    // controller.selectedDays.clear();
    // controller.selectedExpHeader.clear();
    // controller.selectedExpDesc.clear();
    // controller.selectedLanguages.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            dispose();
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        actionsIconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Padding(
          padding: EdgeInsets.only(
              left: screenWidth * 0.05, right: screenWidth * 0.05),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Input information',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kindly provide the needed information',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  child: Text(
                    'General Information',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  width: screenWidth * 0.4,
                  height: screenWidth * 0.20,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Year level',
                      hintText: controller.mentorYearLvl.text.isEmpty
                          ? null
                          : controller.mentorYearLvl.text,
                      hintStyle: TextStyle(
                        fontSize: screenWidth * 0.04,
                        height: 1,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
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
                    items: <String>[
                      '1st Year',
                      '2nd Year',
                      '3rd Year',
                      '4th Year',
                      '5th Year',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.normal,
                              color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      controller.mentorYearLvl.text = value.toString();
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5),
                  width: screenWidth,
                  height: screenWidth * 0.40,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      TextFormField(
                        controller: MentorController.instance.mentorAbout,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                        maxLength: 100,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'About information',
                          hintText: controller.mentorAbout.text.isEmpty
                              ? null
                              : controller.mentorAbout.text,
                          hintStyle: TextStyle(
                            fontSize: screenWidth * 0.04,
                            height: 1,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          labelStyle: TextStyle(
                            fontSize: screenWidth * 0.04,
                            height: 1,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          counterStyle: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  child: TextFormField(
                    controller: MentorController.instance.mentorUserName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                    decoration: InputDecoration(
                      icon: Icon(Icons.person_2_rounded,
                          size: screenWidth * 0.08),
                      labelText: 'Username',
                      hintText: controller.mentorUserName.text.isEmpty
                          ? null
                          : controller.mentorUserName.text,
                      hintStyle: TextStyle(
                        fontSize: screenWidth * 0.04,
                        height: 1,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
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
                Container(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  child: TextFormField(
                    controller:
                        MentorController.instance.mentorSessionCompleted,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                    decoration: InputDecoration(
                      icon: FaIcon(
                        FontAwesomeIcons.clock,
                        size: screenWidth * 0.08,
                      ),
                      labelText: 'Number of mentorship sessions completed',
                      labelStyle: TextStyle(
                        fontSize: screenWidth * 0.04,
                        height: 1,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      hintText: controller.mentorSessionCompleted.text.isEmpty
                          ? null
                          : controller.mentorSessionCompleted.text,
                      hintStyle: TextStyle(
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
                Container(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  child: TextFormField(
                    controller: MentorController.instance.mentorMotto,
                    maxLength: 30,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                    decoration: InputDecoration(
                      hintText: controller.mentorMotto.text.isEmpty
                          ? null
                          : controller.mentorMotto.text,
                      helperStyle: TextStyle(
                        fontSize: screenWidth * 0.04,
                        height: 1,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      labelText: 'Motto or Quote',
                      labelStyle: TextStyle(
                        fontSize: screenWidth * 0.04,
                        height: 1,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      counterStyle: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                if (hasParam)
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Picture',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (imageUrl.isNotEmpty && _image.path.isEmpty)
                          Center(
                              child: Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.02),
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: screenHeight * 0.01),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    imageBuilder: (context, imageProvider) =>
                                        SizedBox(
                                      height: screenWidth * 0.4,
                                      width: screenWidth * 0.4,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        _buildPlaceholderAvatar(
                                            isLoading: true),
                                    errorWidget: (context, url, error) =>
                                        _buildPlaceholderAvatar(),
                                  ),
                                ),
                              ),
                            ),
                          )),
                        if (_image.path.isNotEmpty)
                          Center(
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.02),
                              child: Padding(
                                padding:
                                    EdgeInsets.only(right: screenHeight * 0.01),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Image.file(
                                      _image,
                                      width: screenWidth * 0.4,
                                      height: screenWidth * 0.4,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (imageUrl.isEmpty && _image.path.isEmpty)
                          DefaultButton(
                            buttonText: 'Choose a Profile Picture',
                            bgColor: Colors.grey[300]!,
                            textColor: Colors.black,
                            isLoading: false,
                            borderColor: Colors.transparent,
                            onPressed: () async {
                              await _pickImage();
                            },
                          ),
                      ]),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: DefaultButton(
                    buttonText: 'Proceed',
                    bgColor: Color(0xFF1877F2),
                    textColor: Colors.white,
                    isLoading: false,
                    borderColor: Colors.transparent,
                    onPressed: () async {
                      Navigator.push(
                          context,
                          CustomPageRoute(
                              page: MentorInfo2(
                                userModel: widget.userModel,
                                mentorModel: widget.mentorModel,
                                controller: controller,
                                image: _image,
                              ),
                              direction: AxisDirection.left));
                    },
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
              ]),
        ),
      )),
    );
  }

  Widget _buildPlaceholderAvatar({bool isLoading = false}) {
    return GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 100,
          height: 100,
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
        ));
  }
}
