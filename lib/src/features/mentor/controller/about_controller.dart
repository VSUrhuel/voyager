import 'package:flutter/material.dart';

class AboutController extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();

  ValueNotifier<TextEditingValue> get valueListenable => textController;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
