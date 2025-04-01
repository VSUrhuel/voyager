// ignore_for_file: use_build_context_synchronously

import 'package:voyager/src/features/mentor/controller/mentor_controller.dart';
import 'package:voyager/src/features/mentor/widget/experience_input.dart';
import 'package:voyager/src/features/mentor/widget/multiselect.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:voyager/src/widgets/custom_button.dart';
import 'package:voyager/src/widgets/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MentorInfo2 extends StatelessWidget {
  const MentorInfo2({super.key});

  @override
  Widget build(BuildContext context) {
    final MentorController controller = Get.put(MentorController());

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
                        fontSize: screenWidth * 0.04,
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
                  Multiselect(
                    items: [
                      "Monday",
                      "Tuesday",
                      "Wednesday",
                      "Thursday",
                      "Friday"
                    ],
                    label: "Select Days",
                    controller: MentorController.instance,
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
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Multiselect(
                      items: ['English', 'Filipino', 'Cebuano', 'Waray-Waray'],
                      label: 'Language Known',
                      controller: MentorController.instance),
                  Multiselect(
                    items: [
                      'Web Development',
                      'Mobile Development',
                      'UI/UX',
                      'Data Science'
                    ],
                    label: 'Skills',
                    controller: MentorController.instance,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: screenHeight * 0.015, bottom: 10),
                    child: Text(
                      'Social Media Links',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
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
                  ExperienceInput(
                      experienceHeader:
                          MentorController.instance.mentorExpHeader,
                      experienceDesc: MentorController.instance.mentorExpDesc,
                      controller: MentorController.instance),
                  DefaultButton(
                    buttonText: 'Proceed',
                    bgColor: Color(0xFF1877F2),
                    textColor: Colors.white,
                    isLoading: false,
                    borderColor: Colors.transparent,
                    onPressed: () async {
                      await controller.generateMentor();
                      await controller.updateUsername();
                      Navigator.pushNamed(
                        context,
                        MRoutes.splash,
                      );
                      controller.dispose();
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
