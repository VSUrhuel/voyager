// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/mentor_controller.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/widget/experience_input.dart';
import 'package:voyager/src/features/mentor/widget/multiselect.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:voyager/src/widgets/custom_button.dart';
import 'package:voyager/src/widgets/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MentorInfo2 extends StatefulWidget {
  const MentorInfo2(
      {super.key,
      this.mentorModel,
      this.userModel,
      this.controller,
      this.image});
  final UserModel? userModel;
  final MentorModel? mentorModel;
  final MentorController? controller;
  final File? image;
  @override
  State<MentorInfo2> createState() => _MentorInfo2State();
}

class _MentorInfo2State extends State<MentorInfo2> {
  bool isLoading = false;

  late final MentorController controller;
  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? Get.put(MentorController());
    if (widget.mentorModel != null) {
      controller.selectedDays.value = widget.mentorModel!.mentorRegDay;
      controller.mentorRegStartTime.text =
          "${widget.mentorModel!.mentorRegStartTime.hour.toString()} : ${widget.mentorModel!.mentorRegStartTime.minute.toString()}";
      controller.mentorRegEndTime.text =
          "${widget.mentorModel!.mentorRegEndTime.hour.toString()} : ${widget.mentorModel!.mentorRegEndTime.minute.toString()}";
      controller.mentorExpHeader.text =
          widget.mentorModel!.mentorExpHeader.join(',');
      controller.mentorExpDesc.text =
          widget.mentorModel!.mentorExpDesc.join(',');
      controller.mentorFbUrl.text = widget.mentorModel!.mentorFbUrl;
      controller.mentorGitUrl.text = widget.mentorModel!.mentorGitUrl;
      controller.mentorLanguages.text =
          widget.mentorModel!.mentorLanguages.join(',');

      controller.selectedSkills.value = widget.mentorModel!.mentorExpertise;
      print(
          "Selected header: ${controller.mentorExpHeader.text}"); // Debug print
    }
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
                      'Regular Mentorship Session',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Text(
                      'Days of the Week',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  MultiSelectChips(
                    items: [
                      "Monday",
                      "Tuesday",
                      "Wednesday",
                      "Thursday",
                      "Friday"
                    ],
                    label: "Select Days",
                    initialSelection: MentorController.instance.selectedDays,
                    onSelectionChanged: (selected) {
                      MentorController.instance.updateSelectedDays(selected);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.015),
                    child: Text(
                      'Time of the Day',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TimePicker(
                            titleLabel: "Start Time",
                            controller:
                                MentorController.instance.mentorRegStartTime),
                        SizedBox(width: 20),
                        // Add spacing between the pickers
                        TimePicker(
                            titleLabel: "End Time",
                            controller:
                                MentorController.instance.mentorRegEndTime),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: screenHeight * 0.015, bottom: 10),
                    child: Text(
                      'Language and Skills',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  MultiSelectChips(
                    items: ['English', 'Filipino', 'Cebuano', 'Waray-Waray'],
                    label: 'Language Known',
                    initialSelection:
                        MentorController.instance.selectedLanguages,
                    onSelectionChanged: (selected) {
                      MentorController.instance
                          .updateselectedLanguages(selected);
                    },
                  ),
                  MultiSelectChips(
                    items: [
                      'Web Development',
                      'Mobile Development',
                      'UI/UX',
                      'Data Science'
                    ],
                    label: 'Skills',
                    initialSelection: MentorController.instance.selectedSkills,
                    onSelectionChanged: (selected) {
                      MentorController.instance.updateSelectedSkills(selected);
                    },
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: screenHeight * 0.015, bottom: 2),
                    child: Text(
                      'Social Media Links',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Please ensure that the links are valid.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.015),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.facebook,
                          size: screenWidth * 0.13, // Adjust the size as needed
                        ),
                        SizedBox(
                            width:
                                10), // Add spacing between icon and text field
                        Expanded(
                          // Prevents overflow and ensures proper layout
                          child: TextFormField(
                            controller: controller.mentorFbUrl,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                            ),
                            decoration: InputDecoration(
                              hintText: controller.mentorFbUrl.text.isEmpty
                                  ? null
                                  : controller.mentorFbUrl.text,
                              hintStyle: TextStyle(
                                fontSize: screenWidth * 0.04,
                                height: 1,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              labelText: 'Social link',
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.015),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.github,
                          size: screenWidth * 0.13, // Adjust the size as needed
                        ),
                        SizedBox(
                            width:
                                10), // Add spacing between icon and text field
                        Expanded(
                          // Prevents overflow and ensures proper layout
                          child: TextFormField(
                            controller: controller.mentorGitUrl,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                            ),
                            decoration: InputDecoration(
                              hintText: controller.mentorGitUrl.text.isEmpty
                                  ? null
                                  : controller.mentorGitUrl.text,
                              hintStyle: TextStyle(
                                fontSize: screenWidth * 0.04,
                                height: 1,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              labelText: 'Github link',
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
                      ],
                    ),
                  ),
                  ExperienceInput(controller: controller),
                  DefaultButton(
                    buttonText: 'Proceed',
                    bgColor: Color(0xFF1877F2),
                    textColor: Colors.white,
                    isLoading: isLoading,
                    borderColor: Colors.transparent,
                    onPressed: () async {
                      FirestoreInstance firestoreInstance = FirestoreInstance();
                      if (!firestoreInstance
                          .parseTimeString(controller.mentorRegStartTime.text)
                          .isBefore(firestoreInstance.parseTimeString(
                              controller.mentorRegEndTime.text))) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Start time must be less than end time.'),
                          ),
                        );
                        return;
                      }
                      if (controller.selectedDays.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select at least one day.'),
                          ),
                        );
                        return;
                      }
                      if (controller.selectedSkills.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select at least one skill.'),
                          ),
                        );
                        return;
                      }
                      if (controller.selectedLanguages.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please select at least one language.'),
                          ),
                        );
                        return;
                      }
                      if (controller.mentorFbUrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter your Facebook link.'),
                          ),
                        );
                        return;
                      }
                      if (controller.mentorGitUrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter your Github link.'),
                          ),
                        );
                        return;
                      }
                      final uri = Uri.tryParse(controller.mentorFbUrl.text);
                      if (uri == null ||
                          !uri.hasScheme ||
                          !uri.host.contains('facebook.com')) {
                        // Ensure it's a Facebook link
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please enter a valid Facebook link (e.g., https://facebook.com/username)'),
                          ),
                        );
                        return;
                      }

                      final uri2 = Uri.tryParse(controller.mentorGitUrl.text);
                      if (uri2 == null ||
                          !uri2.hasScheme ||
                          !uri2.host.contains('github.com')) {
                        // Ensure it's a GitHub link
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please enter a valid GitHub link (e.g., https://github.com/username)'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      await controller.generateMentor();

                      await controller.updateUsername(widget.image);

                      if (widget.userModel != null &&
                          widget.mentorModel != null) {
                        await controller.updateMentorInformation();
                      }
                      Navigator.pushNamed(
                        context,
                        MRoutes.splash,
                      );
                      //controller.dispose();
                    },
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
