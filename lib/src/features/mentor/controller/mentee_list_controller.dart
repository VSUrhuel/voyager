import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/model/mentee_model.dart';

class MenteeListController extends GetxController {
  final TextEditingController searchMenteeController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxInt currentStatus = 0.obs; // 0=Accepted, 1=Pending, 2=Rejected
  final RxBool isSearching = false.obs;
  final RxList<MenteeModel> filteredMentees = <MenteeModel>[].obs;
  final List<MenteeModel> allMentees = []; // Initialize with your mentee data

  @override
  void onInit() {
    super.onInit();
    filteredMentees.assignAll(allMentees);
  }

  @override
  void onClose() {
    searchMenteeController.dispose();
    super.onClose();
  }
}
