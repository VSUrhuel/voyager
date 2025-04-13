import 'package:flutter/material.dart';
import 'dart:ui' as ui show TextDirection;

import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class TimePicker extends StatefulWidget {
  final String titleLabel;
  const TimePicker(
      {super.key, this.titleLabel = 'Select Time', required this.controller});

  final TextEditingController controller;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TimeOfDay? selectedTime;
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    if (controller.text.isNotEmpty) {
      selectedTime = FirestoreInstance().parseTimeString(controller.text);
      //selectedTime = TimeOfDay.fromDateTime(DateTime.parse(controller.text));
    } else {
      selectedTime = null;
    }
  }

  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  Orientation? orientation;
  ui.TextDirection textDirection = ui.TextDirection.ltr;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  bool use24HourTime = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: ElevatedButton(
              child: Text(widget.titleLabel),
              onPressed: () async {
                final TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                  initialEntryMode: entryMode,
                  orientation: orientation,
                  builder: (BuildContext context, Widget? child) {
                    // We just wrap these environmental changes around the
                    // child in this builder so that we can apply the
                    // options selected above. In regular usage, this is
                    // rarely necessary, because the default values are
                    // usually used as-is.
                    return Theme(
                      data: Theme.of(context).copyWith(
                        materialTapTargetSize: tapTargetSize,
                      ),
                      child: Directionality(
                        textDirection: textDirection,
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat: use24HourTime,
                          ),
                          child: child!,
                        ),
                      ),
                    );
                  },
                );
                setState(() {
                  selectedTime = time;
                  controller.text = selectedTime!.format(context);
                });
              },
            ),
          ),
          if (selectedTime != null)
            Text(selectedTime!.format(context),
                style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
