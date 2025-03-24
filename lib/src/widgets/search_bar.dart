import 'package:flutter/material.dart';

class SearchBarWithDropdown extends StatefulWidget {
  const SearchBarWithDropdown({super.key});

  @override
  State<SearchBarWithDropdown> createState() => _SearchBarWithDropdownState();
}

class _SearchBarWithDropdownState extends State<SearchBarWithDropdown> {
  String? _selectedCourse = 'Courses';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      alignment: Alignment.centerLeft,
      // Align children to the left
      children: [
        // Use a Row for horizontal layout

        // Dropdown Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
              color: Colors.blue),
          child: DropdownButton<String>(
            value: _selectedCourse,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            iconSize: 24,
            dropdownColor: Colors.blue,
            elevation: 16,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCourse = newValue;
              });
            },
            items: <String>['Courses', 'Option 2', 'Option 3']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),

        const SizedBox(width: 8),

        // Search Bar
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: screenWidth * 0.3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
