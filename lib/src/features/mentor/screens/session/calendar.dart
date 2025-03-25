import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:voyager/src/features/mentor/controller/mentor_controller.dart';
import 'package:voyager/src/features/mentor/widget/task.dart';
import 'package:voyager/src/widgets/custom_text_field.dart';
import 'package:voyager/src/widgets/time.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now(); // Ensure it's a state variable

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Future<void> showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('New Schedule'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    "Create a new schedule for 03/12/12",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  CustomTextField(
                    hintText: 'Schedule Title',
                    fieldWidth: screenWidth * 0.8,
                    fontSize: screenWidth * 0.04,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.0),
                    child: Text(
                      'Time of the Day',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TimePicker(
                          titleLabel: "Start Time",
                          controller: TextEditingController(),
                        ),

                        // Add spacing between the pickers
                        TimePicker(
                            titleLabel: "End Time",
                            controller: TextEditingController()),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                    maxLength: 100,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Schedule description',
                      labelStyle: TextStyle(
                        fontSize: screenWidth * 0.04,
                        height: 1,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      counterStyle: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Text(
                      'This schedule will be posted to your mentees. Please review it before saving.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void onDaySelected(DateTime newSelectedDay, DateTime newFocusedDay) {
      if (!isSameDay(selectedDay, newSelectedDay)) {
        setState(() {
          selectedDay = newSelectedDay;
          focusedDay = newFocusedDay; // Ensure focusedDay updates too
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: screenHeight * 0.04,
        elevation: 0, // No shadow
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.0),
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            calendarFormat: CalendarFormat.month,
            onDaySelected: onDaySelected,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.grey[700],
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
              weekendStyle: TextStyle(
                color: Colors.grey[700],
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue[200],
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            // This will make the container take all remaining space
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    // Allows scrolling when content overflows
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenHeight * 0.02,
                        vertical: screenWidth * 0.03,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.02),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(right: screenHeight * 0.02),
                                child: Text(
                                  'Today',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Column(
                            children: [
                              Task(
                                taskName: 'Task 1',
                                taskDescription:
                                    'Session with student at 10:00 AM',
                                icon: CupertinoIcons.check_mark_circled_solid,
                                iconColor: Colors.green,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Task(
                                taskName: 'Task 2',
                                taskDescription:
                                    'Sessddddddddion with student at 11:00 AM',
                                icon: CupertinoIcons.clock_fill,
                                iconColor: Colors.orange,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Task(
                                taskName: 'Task 2',
                                taskDescription:
                                    'Session with student at 11:00 AM',
                                icon: CupertinoIcons.clock_fill,
                                iconColor: Colors.orange,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Task(
                                taskName: 'Task 2',
                                taskDescription:
                                    'Session with student at 11:00 AM',
                                icon: CupertinoIcons.clock_fill,
                                iconColor: Colors.orange,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Task(
                                taskName: 'Task 2',
                                taskDescription:
                                    'Session with student at 11:00 AM',
                                icon: CupertinoIcons.clock_fill,
                                iconColor: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    height: 100,
                    width: screenWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Color(0xff30384c).withOpacity(0),
                            Color(0xff30384c),
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        showMyDialog();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenHeight * 0.025,
                          vertical: screenHeight * 0.007,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          color: Color(0xFF1877F2),
                          boxShadow: [
                            BoxShadow(color: Colors.black38, blurRadius: 30)
                          ],
                        ),
                        child: Text(
                          "+",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenHeight * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
