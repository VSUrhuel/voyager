import 'package:flutter/material.dart';

class ModelOnboarding {
  final String title1;
  final String title2;
  final TextSpan description;
  final String image;
  final int currentPage;

  ModelOnboarding({
    required this.title1,
    required this.title2,
    required this.description,
    required this.image,
    required this.currentPage,
  });
}
