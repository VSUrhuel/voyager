import 'package:voyager/src/features/mentor/controller/mentor_controller.dart';
import 'package:voyager/src/features/mentor/widget/experience_container.dart';
import 'package:flutter/material.dart';

class ExperienceInput extends StatefulWidget {
  const ExperienceInput(
      {super.key, this.experienceHeader, this.experienceDesc, this.controller});

  final TextEditingController? experienceHeader;
  final TextEditingController? experienceDesc;
  final MentorController? controller;

  @override
  State<ExperienceInput> createState() => _ExperienceInputState();
}

class _ExperienceInputState extends State<ExperienceInput> {
  List<Widget> experienceContainers = [];
  late final double screenWidth;
  List<String> selectedExpHeader = [];
  List<String> selectedExpDesc = [];
  final List<TextEditingController> newHeaderController = [];
  final List<TextEditingController> newDescController = [];

  @override
  void initState() {
    super.initState();
    if (widget.controller!.mentorExpHeader.text.isNotEmpty &&
        widget.experienceDesc!.text.isNotEmpty) {
      // Split the comma-separated strings into lists
      final headers = widget.experienceHeader!.text.split(',');
      final descriptions = widget.experienceDesc!.text.split(',');

      // Ensure we have matching pairs

      for (int i = 0; i < headers.length; i++) {
        existingAddExperienceContainer(headers[i], descriptions[i]);
      }
    }
  }

  void existingAddExperienceContainer(
      String expereienceHeader, String experienceDesc) {
    setState(() {
      var headerController = TextEditingController(text: expereienceHeader);
      var descController = TextEditingController(text: experienceDesc);

      // Add controllers to lists
      newHeaderController.add(headerController);
      newDescController.add(descController);

      // Listen to text changes and update the list
      headerController.addListener(() {
        selectedExpHeader =
            newHeaderController.map((controller) => controller.text).toList();
        widget.experienceHeader!.text = selectedExpHeader.join(',');
      });

      descController.addListener(() {
        selectedExpDesc =
            newDescController.map((controller) => controller.text).toList();
        widget.experienceDesc!.text = selectedExpDesc.join(',');
      });

      // Add new experience container
      experienceContainers.add(ExperienceContainer(
        index: experienceContainers.length + 1,
        experienceHeader: headerController,
        experienceDesc: descController,
      ));
    });
  }

  void _addExperienceContainer() {
    setState(() {
      var headerController = TextEditingController();
      var descController = TextEditingController();

      // Add controllers to lists
      newHeaderController.add(headerController);
      newDescController.add(descController);

      // Listen to text changes and update the list
      headerController.addListener(() {
        selectedExpHeader =
            newHeaderController.map((controller) => controller.text).toList();
        widget.experienceHeader!.text = selectedExpHeader.join(',');
      });

      descController.addListener(() {
        selectedExpDesc =
            newDescController.map((controller) => controller.text).toList();
        widget.experienceDesc!.text = selectedExpDesc.join(',');
      });

      // Add new experience container
      experienceContainers.add(ExperienceContainer(
        index: experienceContainers.length + 1,
        experienceHeader: headerController,
        experienceDesc: descController,
      ));
    });
  }

  void _removeExperienceContainer() {
    setState(() {
      if (experienceContainers.isNotEmpty) {
        experienceContainers.removeLast();
        selectedExpDesc.removeLast();
        selectedExpHeader.removeLast();
        widget.controller!.updateSelectedExpHeader(selectedExpHeader);
        widget.controller!.updateSelectedExpDesc(selectedExpDesc);
        newHeaderController.removeLast().dispose();
        newDescController.removeLast().dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: TextButton.icon(
              onPressed: _addExperienceContainer,
              icon: Icon(Icons.add),
              label: Text('Add Experience'),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          ...experienceContainers,
          if (experienceContainers.isNotEmpty)
            Align(
              alignment: Alignment.topLeft,
              child: TextButton.icon(
                onPressed: _removeExperienceContainer,
                icon: Icon(Icons.remove),
                label: Text(
                  'Remove Experience',
                  style: TextStyle(color: Colors.red),
                ),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  iconColor: Colors.red,
                ),
              ),
            )
        ],
      ),
    );
  }
}
