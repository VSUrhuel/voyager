import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentee/controller/mentee_controller.dart';

class SearchBarWithDropdown extends StatefulWidget {
  const SearchBarWithDropdown(
      {super.key, this.controller, this.searchController, this.onChanged});
  final MenteeController? controller;
  final Function? onChanged;
  final TextEditingController? searchController;

  @override
  State<SearchBarWithDropdown> createState() => _SearchBarWithDropdownState();
}

class _SearchBarWithDropdownState extends State<SearchBarWithDropdown> {
  String? _selectedCourse = 'Courses'; // Default value for the dropdown

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, // Fixed height for the entire widget
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Dropdown Button
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Center(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCourse,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  dropdownColor: Colors.blue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCourse = newValue!;
                      widget.controller?.updateSearchCategory(newValue);
                      widget.onChanged?.call();
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return ['Courses', 'Mentors'].map((String value) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _selectedCourse
                              as String, // Show currently selected value
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  items: ['Courses', 'Mentors'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                            color: Colors.white), // Dropdown items (black text)
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Search Bar
          Expanded(
            child: Container(
              height: 48, // Match container height
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: TextField(
                controller: widget.searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  suffixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
