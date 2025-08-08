import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';

class CourseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive list of courses
  RxList<CourseModel> courses = <CourseModel>[].obs;

  // Loading indicator
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
  }

  // Function to fetch courses from Firestore
  Future<void> fetchCourses() async {
    try {
      isLoading.value = true;

      final querySnapshot = await _firestore
          .collection('course')
          .where('courseSoftDelete', isEqualTo: false)
          .get();

      courses.value = querySnapshot.docs.map((doc) {
        return CourseModel.fromJson(
            doc.data(), doc.id); // Pass doc.id as the docId
      }).toList();
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
