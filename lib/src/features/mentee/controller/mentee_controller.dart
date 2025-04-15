import 'package:flutter/material.dart';

class MenteeController {
  final searchCategory = TextEditingController();
  final searchText = TextEditingController();

  void updateSearchCategory(String value) {
    searchCategory.text = value;
  }
}
