import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/controller/notification_controller.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/screens/profile/view-course.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';

class MenteePersonalInformation extends StatefulWidget {
  const MenteePersonalInformation({
    super.key,
    required this.userModel,
  });
  final UserModel userModel;

  @override
  State<MenteePersonalInformation> createState() =>
      _MenteePersonalInformationState();
}

class _MenteePersonalInformationState extends State<MenteePersonalInformation> {
  late UserModel userModel;
  final firestore = FirestoreInstance();
  List<CourseModel> enrolledCourses = [];
  List<CourseMentorModel> courseMentorModels = [];
  bool isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    userModel = widget.userModel;
    fetchEnrolledCourses();
  }

  Future<void> fetchCourseMentor(String courseId) async {
    try {
      final courseMentor =
          await firestore.getCourseMentorsThroughCourseId(courseId);

      setState(() {
        courseMentorModels = courseMentor;
      });
    } catch (e) {
      print("❌ Error fetching course mentor: $e");
    }
  }

  String formatName(String fullName) {
    if (fullName.isEmpty) return "John Doe";

    fullName = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    List<String> nameParts = fullName.split(" ");

    if (nameParts.isEmpty) return "John Doe";

    List<String> givenNames =
        nameParts.length >= 2 ? nameParts.sublist(0, 2) : [nameParts.first];

    String? lastName = nameParts.length > 1 ? nameParts.last : null;

    List<String> formattedParts = givenNames
        .map((name) => name.isNotEmpty
            ? name[0].toUpperCase() + name.substring(1).toLowerCase()
            : "")
        .toList();

    if (lastName != null && !givenNames.contains(lastName)) {
      formattedParts.add(
        lastName[0].toUpperCase() + lastName.substring(1).toLowerCase(),
      );
    }

    String formattedName = formattedParts.join(" ").trim();

    return formattedName.isNotEmpty ? formattedName : "John Doe";
  }

  Future<void> fetchEnrolledCourses() async {
    setState(() {
      isLoadingCourses = true;
    });

    try {
      final userEmail = userModel.accountApiEmail;
      final notificationController = NotificationController();
      final userId =
          await notificationController.getUserIdThroughEmail(userEmail);
      final courseMentorIds =
          await notificationController.getCourseMentorIdsForMentee(userId);

      if (courseMentorIds.isEmpty) {
        setState(() {
          enrolledCourses = [];
          isLoadingCourses = false;
        });
        return;
      }

      List<CourseModel> fetchedCourses = [];

      for (String mentorId in courseMentorIds) {
        final course = await firestore.getMentorCourseThroughId(mentorId);
        if (course != null) {
          await fetchCourseMentor(course.docId);
          fetchedCourses.add(course);
        }
      }

      final uniqueCourses = {
        for (var course in fetchedCourses) course.docId: course
      }.values.toList();

      setState(() {
        enrolledCourses = uniqueCourses;
        isLoadingCourses = false;
      });
    } catch (e) {
      print("❌ Error fetching enrolled courses: $e");
      setState(() {
        isLoadingCourses = false;
      });
    }
  }

  Widget _buildCapabilityItem(
    BuildContext context,
    IconData icon,
    CourseModel course,
    double screenWidth,
  ) {
    fetchCourseMentor(course.docId);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CustomPageRoute(
            page: ViewCourse(
              courseModel: course,
              courseMentors: courseMentorModels,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: screenWidth * 0.05,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Text(
                course.courseName,
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCardInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.025,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school,
                  color: Theme.of(context).primaryColor,
                  size: screenWidth * 0.06,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  "Enrolled Courses",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            if (isLoadingCourses)
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.03),
                child: Lottie.asset(
                  'assets/images/loading.json',
                  fit: BoxFit.cover,
                  width: screenHeight * 0.08,
                  height: screenWidth * 0.2,
                  repeat: true,
                ),
              )
            else if (enrolledCourses.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Text(
                  "No enrolled courses",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.4,
                ),
                child: ListView.separated(
                  itemCount: enrolledCourses.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) =>
                      SizedBox(height: screenHeight * 0.015),
                  itemBuilder: (context, index) {
                    final course = enrolledCourses[index];
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _buildCapabilityItem(
                        context,
                        Icons.menu_book,
                        course,
                        screenWidth,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final supabase = Supabase.instance.client;
    final imageUrl = (userModel.accountApiPhoto.isNotEmpty)
        ? (userModel.accountApiPhoto.startsWith('http')
            ? userModel.accountApiPhoto
            : supabase.storage
                .from('profile-picture')
                .getPublicUrl(userModel.accountApiPhoto))
        : 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture/profile.png';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: screenHeight * 0.3,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: Colors.transparent,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatName(
                                      userModel.accountApiName.toUpperCase()),
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.028,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userModel.accountApiEmail,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: screenHeight * 0.018,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Mentee",
                              style: TextStyle(
                                color: Color(0xFF1877F2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildAdminCardInfo(context),
                      SizedBox(height: screenHeight * 0.04),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
