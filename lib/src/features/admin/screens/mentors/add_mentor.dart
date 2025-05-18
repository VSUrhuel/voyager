//addmentor

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/admin/controllers/course_controller.dart';
import 'package:voyager/src/features/admin/controllers/course_mentor_controller.dart';
import 'package:voyager/src/features/admin/controllers/create_mentor_controller.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/admin/widgets/profile_picker.dart';
import 'package:voyager/src/widgets/custom_button.dart';

// import 'package:voyager/src/features/admin/widgets/regular_sched_picker.dart';

class AddMentor extends StatefulWidget {
  const AddMentor({super.key});

  @override
  State<AddMentor> createState() => _AddMentorState();
}

class _AddMentorState extends State<AddMentor> {
  late Future<void> futureCourses;
  @override
  void initState() {
    super.initState();
    futureCourses = fetchCourses();
  }

  Future<void> fetchCourses() async {
    final CourseController courseController = Get.put(CourseController());
    await courseController.fetchActiveCourses();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // final MentorController controller = Get.put(MentorController());
    final CourseController courseController = Get.put(CourseController());
    final CreateMentorController createMentorController =
        Get.put(CreateMentorController());
    final CourseMentorController courseMentorController =
        Get.put(CourseMentorController());
    final GlobalKey<ProfilePickerState> profilePickerKey = GlobalKey();

    return SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Add Mentor',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: FutureBuilder(
              future: futureCourses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset(
                      'assets/images/loading.json',
                      fit: BoxFit.cover,
                      width: screenHeight * 0.08,
                      height: screenWidth * 0.04,
                      repeat: true,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.08,
                      right: screenWidth * 0.08,
                    ),
                    child: Container(
                      padding: EdgeInsets.only(
                        bottom: screenHeight * 0.04,
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Add Mentor\'s Information',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            Text('Kindly provide the needed information',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w500,
                                )),

                            Container(
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.02),
                              child: Obx(() {
                                if (courseController.isLoading.value) {
                                  return Center(
                                    child: Lottie.asset(
                                      'assets/images/loading.json',
                                      fit: BoxFit.cover,
                                      width: screenHeight * 0.08,
                                      height: screenWidth * 0.04,
                                      repeat: true,
                                    ),
                                  );
                                }

                                if (courseController.activeCourses.isEmpty) {
                                  return Text("No courses available",
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04));
                                }

                                return DropdownButtonFormField<CourseModel>(
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        left: screenWidth * 0.05,
                                        top: screenHeight * 0.016,
                                        bottom: screenHeight * 0.016),
                                    labelText: 'Course to Mentor',
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
                                  items: courseController.activeCourses
                                      .map((course) {
                                    return DropdownMenuItem<CourseModel>(
                                      value: course,
                                      child: Text(
                                        course.courseName,
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: FontStyle.normal,
                                            color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      courseMentorController.courseId.text =
                                          value.docId;
                                    }
                                  },
                                );
                              }),
                            ),

                            Container(
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.02),
                              child: TextFormField(
                                controller: createMentorController.studentID,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      left: screenWidth * 0.05,
                                      top: screenHeight * 0.016,
                                      bottom: screenHeight * 0.016),
                                  labelText: 'Enter mentor\'s student ID ',
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
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.02),
                              child: TextFormField(
                                controller: createMentorController.fullName,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      left: screenWidth * 0.05,
                                      top: screenHeight * 0.016,
                                      bottom: screenHeight * 0.016),
                                  labelText: 'Enter mentor\'s name ',
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
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.02),
                              child: TextFormField(
                                controller: createMentorController.email,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      left: screenWidth * 0.05,
                                      top: screenHeight * 0.016,
                                      bottom: screenHeight * 0.016),
                                  labelText: 'Enter mentor\'s email ',
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
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.02),
                              child: TextFormField(
                                controller: createMentorController.password,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      left: screenWidth * 0.05,
                                      top: screenHeight * 0.016,
                                      bottom: screenHeight * 0.016),
                                  labelText:
                                      'Enter mentor\'s default password ',
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
                            //profile pic
                            Container(
                              // color: Colors.black,
                              alignment: Alignment.center,

                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.02),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade600,
                                    // width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: screenHeight * 0.2,
                                width: screenWidth * 0.5,
                                child: ProfilePicker(
                                  key: profilePickerKey,
                                  onImagePicked: (image) {
                                    createMentorController.profileImage = image;
                                  },
                                ),
                              ),
                            ),

                            Spacer(),

                            SizedBox(height: screenHeight * 0.02),
                            DefaultButton(
                              buttonText: 'Proceed',
                              bgColor: Color(0xFF1877F2),
                              textColor: Colors.white,
                              isLoading: false,
                              borderColor: Colors.transparent,
                              onPressed: () async {
                                final currentContext = context;
                                final messenger =
                                    ScaffoldMessenger.of(currentContext);

                                if (createMentorController
                                        .studentID.text.isNotEmpty &&
                                    createMentorController
                                        .fullName.text.isNotEmpty &&
                                    createMentorController
                                        .email.text.isNotEmpty &&
                                    createMentorController
                                        .password.text.isNotEmpty) {
                                  try {
                                    // Show loading dialog
                                    showDialog(
                                      context: currentContext,
                                      barrierDismissible: false,
                                      builder: (_) => Center(
                                        child: Lottie.asset(
                                          'assets/images/loading.json',
                                          fit: BoxFit.cover,
                                          width: screenHeight * 0.08,
                                          height: screenWidth * 0.04,
                                          repeat: true,
                                        ),
                                      ),
                                    );

                                    if (await createMentorController
                                        .registerUser()) {
                                      courseMentorController.mentorId.text =
                                          createMentorController.email.text;

                                      if (courseMentorController
                                          .courseId.text.isNotEmpty) {
                                        await courseMentorController
                                            .createInitialCourseMentor();
                                      }

                                      // Clear all fields
                                      courseController.allCourses.clear();
                                      courseMentorController.courseId.clear();
                                      courseMentorController.mentorId.clear();
                                      createMentorController.studentID.clear();
                                      createMentorController.fullName.clear();
                                      createMentorController.email.clear();
                                      createMentorController.password.clear();
                                      profilePickerKey.currentState
                                          ?.resetImage();

                                      if (currentContext.mounted) {
                                        Navigator.of(currentContext).pop();

                                        messenger.showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Mentor added successfully')),
                                        );

                                        Navigator.of(currentContext).pop();
                                      }
                                    }
                                  } catch (e) {
                                    if (currentContext.mounted) {
                                      Navigator.of(currentContext).pop();
                                    }

                                    messenger.showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Error: ${e.toString()}')),
                                    );
                                  }
                                } else {
                                  messenger.showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Please fill in necessary fields')),
                                  );
                                }
                              },
                            ),
                          ]),
                    ));
              },
            )));
  }
}
