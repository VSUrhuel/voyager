import 'package:flutter/material.dart';

class MultiSelectChips extends StatefulWidget {
  final List<String> items;
  final String label;
  final Function(List<String>) onSelectionChanged;
  final List<String> initialSelection;

  const MultiSelectChips({
    super.key,
    required this.items,
    required this.label,
    required this.onSelectionChanged,
    this.initialSelection = const [],
  });

  @override
  State<MultiSelectChips> createState() => _MultiSelectChipsState();
}

class _MultiSelectChipsState extends State<MultiSelectChips> {
  late List<String> selectedItems;

  @override
  void initState() {
    super.initState();
    selectedItems = List.from(widget.initialSelection);
  }

  void _toggleSelection(String item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
      widget.onSelectionChanged(selectedItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Wrap(
          spacing: 8.0,
          children: widget.items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) => _toggleSelection(item),
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
// import 'package:voyager/src/features/mentor/controller/mentor_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:multiselect/multiselect.dart';

// class Multiselect extends StatefulWidget {
//   const Multiselect(
//       {super.key,
//       this.items = const [],
//       this.label = '',
//       required this.controller});

//   final List<String> items;
//   final String label;
//   final MentorController controller;

//   @override
//   State<Multiselect> createState() => _MultiselectState();
// }

// class _MultiselectState extends State<Multiselect> {
//   late final List<String> items;
//   late final String label;

//   List<String> selectedItems = [];
//   late final MentorController controller;

//   @override
//   void initState() {
//     super.initState();
//     items = widget.items;
//     label = widget.label;
//     controller = widget.controller;

//     if (label == "Select Days") {
//       selectedItems = controller.selectedDays;
//     } else if (label == "Language Known") {
//       selectedItems = controller.selectedLanguages;
//     } else if (label == "Skills") {
//       selectedItems = controller.selectedSkills;
//     }
//   }

//   void _updateSelection(List<String> selectedX) {
//     // Only update if changed
//     setState(() {
//       selectedItems = List.from(selectedX);
//       if (label == "Select Days") {
//         controller.selectedDays.value = selectedItems;
//         controller.updateSelectedDays(selectedItems);
//       } else if (label == "Language Known") {
//         controller.selectedLanguages.value = selectedItems;
//         controller.updateselectedLanguages(selectedItems);
//       } else if (label == "Skills") {
//         controller.selectedSkills.value = selectedItems;
//         controller.updateSelectedSkills(selectedItems);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Container(
//       width: screenWidth * 0.9,
//       padding: EdgeInsets.only(top: screenWidth * 0.01),
//       child: Center(
//         child: DropDownMultiSelect(
//           hint: selectedItems.isEmpty ? null : Text(selectedItems.join(', ')),
//           hintStyle: TextStyle(
//             fontSize: screenWidth * 0.04,
//             fontWeight: FontWeight.w500, // Slightly bold
//             color: Colors.grey[600],
//           ),
//           onChanged: _updateSelection,
//           options: items,
//           selectedValues: selectedItems,
//           whenEmpty: label,

//           // 🖌 Customizing the displayed selected text
//           childBuilder: (selected) {
//             final color = selected.isEmpty ? Colors.grey[600] : Colors.black;
//             return Padding(
//               padding: EdgeInsets.only(left: screenWidth * 0.05),
//               child: Text(
//                 selected.isEmpty ? label : selectedItems.join(', '),
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.04,
//                   fontWeight: FontWeight.w500, // Slightly bold
//                   color: color,
//                 ),
//               ),
//             );
//           },

//           // ✅ Fixed: Use a single String parameter
//           menuItembuilder: (String item) {
//             final isSelected = selectedItems.contains(item);
//             return Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: screenWidth * 0.03,
//                 vertical: screenWidth * 0.02,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Checkbox(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       splashRadius: 10,
//                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       value: isSelected,
//                       onChanged: (bool? value) {
//                         setState(
//                           () {
//                             final updatedSelection =
//                                 List<String>.from(selectedItems);
//                             if (value == true) {
//                               updatedSelection.add(item);
//                               selectedItems = updatedSelection;
//                             } else {
//                               updatedSelection.remove(item);
//                               selectedItems = updatedSelection;
//                             }
//                             _updateSelection(updatedSelection);
//                           },
//                         );
//                       }),
//                   Text(
//                     item,
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.04,
//                       fontWeight: FontWeight.w500,
//                       // Slightly bold
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
