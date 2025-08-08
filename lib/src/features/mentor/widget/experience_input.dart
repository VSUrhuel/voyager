// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/controller/mentor_controller.dart';
import 'package:voyager/src/features/mentor/widget/experience_container.dart';

class ExperienceInput extends StatefulWidget {
  const ExperienceInput({
    super.key,
    required this.controller,
  });

  final MentorController controller;

  @override
  State<ExperienceInput> createState() => _ExperienceInputState();
}

class _ExperienceInputState extends State<ExperienceInput> {
  late final List<ExperienceEntry> _experiences = [];
  final List<TextEditingController> _headerControllers = [];
  final List<TextEditingController> _descControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeExistingExperiences();
  }

  void _initializeExistingExperiences() {
    final controller = widget.controller;
    if (controller.selectedExpHeader.isNotEmpty &&
        controller.selectedExpDesc.isNotEmpty) {
      final headers = widget.controller.mentorExpHeader.text
          .split(',')
          .map((e) => e.trim())
          .toList();
      final descriptions = widget.controller.mentorExpDesc.text
          .split(',')
          .map((e) => e.trim())
          .toList();

      // Use the minimum length to avoid index errors
      final maxEntries = headers.length < descriptions.length
          ? headers.length
          : descriptions.length;

      for (int i = 0; i < maxEntries; i++) {
        _addExperience(
          header: headers[i],
          description: descriptions[i],
          updateController: false,
        );
      }
    } else {
      // Start with one empty experience by default
      _addExperience();
    }
  }

  void _addExperience({
    String header = '',
    String description = '',
    bool updateController = true,
  }) {
    final headerController = TextEditingController(text: header);
    final descController = TextEditingController(text: description);

    setState(() {
      _headerControllers.add(headerController);
      _descControllers.add(descController);
      _experiences.add(ExperienceEntry(
        index: _experiences.length + 1,
        headerController: headerController,
        descController: descController,
      ));
    });

    headerController.addListener(_updateControllerLists);
    descController.addListener(_updateControllerLists);

    if (updateController) {
      _updateControllerLists();
    }
  }

  void _removeExperience(int index) {
    if (index >= 0 && index < _experiences.length) {
      setState(() {
        _headerControllers[index].dispose();
        _descControllers[index].dispose();
        _headerControllers.removeAt(index);
        _descControllers.removeAt(index);
        _experiences.removeAt(index);

        // Update indexes
        for (int i = 0; i < _experiences.length; i++) {
          _experiences[i] = _experiences[i].copyWith(index: i + 1);
        }
      });
      _updateControllerLists();
    }
  }

  void _updateControllerLists() {
    final headers = _headerControllers.map((c) => c.text).toList();
    final descriptions = _descControllers.map((c) => c.text).toList();

    widget.controller.updateSelectedExpHeader(headers);
    widget.controller.updateSelectedExpDesc(descriptions);
  }

  @override
  void dispose() {
    for (final controller in _headerControllers) {
      controller.dispose();
    }
    for (final controller in _descControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(
            height: 12,
          ),
          Text(
              "If you have any previous experience inputted and it is not displayed, please go back the previous page to reload the information.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              )),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.topLeft,
            child: TextButton.icon(
              onPressed: () => _addExperience(),
              icon: const Icon(Icons.add),
              label: const Text('Add Experience'),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          ..._experiences.map((entry) => Column(
                children: [
                  ExperienceContainer(
                    index: entry.index,
                    experienceHeader: entry.headerController,
                    experienceDesc: entry.descController,
                    onRemove: () => _removeExperience(entry.index - 1),
                  ),
                  const SizedBox(height: 12),
                ],
              )),
        ],
      ),
    );
  }
}

class ExperienceEntry {
  final int index;
  final TextEditingController headerController;
  final TextEditingController descController;

  ExperienceEntry({
    required this.index,
    required this.headerController,
    required this.descController,
  });

  ExperienceEntry copyWith({
    int? index,
    TextEditingController? headerController,
    TextEditingController? descController,
  }) {
    return ExperienceEntry(
      index: index ?? this.index,
      headerController: headerController ?? this.headerController,
      descController: descController ?? this.descController,
    );
  }
}
