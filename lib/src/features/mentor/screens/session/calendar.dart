// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:voyager/src/features/mentor/controller/schedule_conrtoller.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/features/mentor/widget/task.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_text_field.dart';
import 'package:voyager/src/widgets/time.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  FirestoreInstance firestore = Get.put(FirestoreInstance());
  ScheduleConrtoller scheduleConrtoller = Get.put(ScheduleConrtoller());
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now(); // Ensure it's a state variable
  bool _isLoading = false;
  late List<ScheduleModel> scheduleListToday = [];
  late MentorModel mentor;
  bool hasScheduleToday = false;
  bool _isPressed = false;

  Future<void> _loadScheduleForSelectedDay(DateTime day) async {
    setState(() => _isLoading = true);

    try {
      final formatDate =
          "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
      String dayOfTheWeek =
          await scheduleConrtoller.getDayOfTheWeek(selectedDay);
      final schedules = await scheduleConrtoller.getScheduleByDay(formatDate);
      final mentorData = await scheduleConrtoller.getMentorDetails();
      final hasSchedule;
      if (selectedDay.month > 5) {
        hasSchedule = false;
      } else {
        hasSchedule =
            await scheduleConrtoller.hasRegScheduleToday(dayOfTheWeek);
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          scheduleListToday = schedules;
          mentor = mentorData;
          hasScheduleToday = hasSchedule;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      // Optionally show error to user
    }
  }

  @override
  void dispose() {
    scheduleConrtoller.scheduleTitle.text = "";
    scheduleConrtoller.scheduleDescription.text = "";
    scheduleConrtoller.scheduleStartTime.text = "";
    scheduleConrtoller.scheduleEndTime.text = "";
    scheduleConrtoller.scheduleRoomName.text = "";
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduleForSelectedDay(DateTime.now());
    });
  }

  void clearController() {
    scheduleConrtoller.scheduleDate.text = '';
    scheduleConrtoller.scheduleDescription.text = '';
    scheduleConrtoller.scheduleEndTime.text = '';
    scheduleConrtoller.scheduleStartTime.text = '';
    scheduleConrtoller.scheduleRoomName.text = '';
    scheduleConrtoller.scheduleMenteeId.text = '';
    scheduleConrtoller.scheduleMentorId.text = '';
    scheduleConrtoller.scheduleTitle.text = '';
  }

  FirestoreInstance firestoreInstance = Get.put(FirestoreInstance());

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Future<void> showMyDialog() async {
      final formatDate =
          "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
      final sched = await scheduleConrtoller.getScheduleByDay(formatDate);
      if (mounted) {
        setState(() {
          scheduleListToday = sched;
          _isLoading = false; // Set loading to false after data is fetched
          scheduleConrtoller.scheduleDate.text = formatDate;
        });
      }
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          scheduleConrtoller.scheduleDate.text = formatDate;
          return AlertDialog(
            title: const Text('New Schedule'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    "Create a new schedule for $formatDate",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  CustomTextField(
                    controllerParam: scheduleConrtoller.scheduleTitle,
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
                          controller: scheduleConrtoller.scheduleStartTime,
                        ),

                        // Add spacing between the pickers
                        TimePicker(
                            titleLabel: "End Time",
                            controller: scheduleConrtoller.scheduleEndTime),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    padding: EdgeInsets.only(top: screenHeight * 0.015),
                    width: screenWidth * 0.4,
                    height: screenWidth * 0.20,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: 'Room',
                        labelStyle: TextStyle(
                          fontSize: screenWidth * 0.04,
                          height: 1,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: <String>[
                        'Library',
                        'DCST Room',
                        'TBA',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.normal,
                                fontStyle: FontStyle.normal,
                                color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        scheduleConrtoller.scheduleRoomName.text =
                            value.toString();
                      },
                    ),
                  ),
                  TextFormField(
                    controller: scheduleConrtoller.scheduleDescription,
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
                onPressed: () async {
                  if (scheduleConrtoller.scheduleTitle.text == '' ||
                      scheduleConrtoller.scheduleDescription.text == '' ||
                      scheduleConrtoller.scheduleStartTime.text.isEmpty ||
                      scheduleConrtoller.scheduleEndTime.text.isEmpty ||
                      scheduleConrtoller.scheduleRoomName.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please fill in all fields.',
                        ),
                      ),
                    );
                    return;
                  }
                  if (!firestoreInstance
                      .parseTimeString(
                          scheduleConrtoller.scheduleStartTime.text)
                      .isBefore(firestoreInstance.parseTimeString(
                          scheduleConrtoller.scheduleEndTime.text))) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Start time must be before end time.',
                        ),
                      ),
                    );
                    return;
                  }

                  await scheduleConrtoller.generateSchedule();
                  Navigator.of(context).pop();
                  clearController();
                },
              ),
            ],
          );
        },
      );
    }

    void onDaySelected(DateTime newSelectedDay, DateTime newFocusedDay) {
      if (!isSameDay(selectedDay, newSelectedDay)) {
        // First update the selected day synchronously
        setState(() {
          selectedDay = newSelectedDay;
          focusedDay = newFocusedDay;
          _isLoading = true;
        });

        // Then fetch data asynchronously
        _loadScheduleForSelectedDay(newSelectedDay);
      }
    }

    String getMonth(int num) {
      switch (num) {
        case 1:
          return "Jan";
        case 2:
          return "Feb";
        case 3:
          return "Mar";
        case 4:
          return "Apr";
        case 5:
          return "May";
        case 6:
          return "Jun";
        case 7:
          return "Jul";
        case 8:
          return "Aug";
        case 9:
          return "Sep";
        case 10:
          return "Oct";
        case 11:
          return "Nov";
        case 12:
          return "Dec";
      }
      return "";
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
      body: Stack(children: [
        Column(
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
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenHeight * 0.02,
                        vertical: screenWidth * 0.06,
                      ),
                      child: Text(
                        selectedDay.day == DateTime.now().day &&
                                selectedDay.month == DateTime.now().month &&
                                selectedDay.year == DateTime.now().year
                            ? "Today"
                            : "${getMonth(selectedDay.month)} ${selectedDay.day}, ${selectedDay.year}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                            SizedBox(height: screenHeight * 0.07),
                            Column(
                              children: [
                                if (_isLoading && scheduleListToday.isEmpty)
                                  SizedBox(
                                    height: screenHeight * 0.2,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else if (scheduleListToday.isEmpty &&
                                    hasScheduleToday == false)
                                  SizedBox(
                                    height: screenHeight * 0.2,
                                    child: Center(
                                      child: Text(
                                        "No schedule for this day",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: scheduleListToday.map((schedule) {
                                      if (schedule.scheduleDate
                                          .isBefore(DateTime.now())) {
                                        return Task(
                                          taskName: schedule.scheduleTitle,
                                          taskDescription:
                                              "${schedule.scheduleStartTime} - ${schedule.scheduleEndTime}",
                                          icon: CupertinoIcons
                                              .check_mark_circled_solid,
                                          iconColor: Colors.green,
                                        );
                                      } else {
                                        return Task(
                                          taskName: schedule.scheduleTitle,
                                          taskDescription:
                                              "${schedule.scheduleStartTime} - ${schedule.scheduleEndTime}",
                                          icon: CupertinoIcons.clock_solid,
                                          iconColor: Colors.orange,
                                        );
                                      }
                                    }).toList(),
                                  ),
                                SizedBox(height: screenHeight * 0.02),
                                hasScheduleToday == true
                                    ? Task(
                                        taskName: 'Regular Mentorship Session',
                                        taskDescription:
                                            "${mentor.mentorRegStartTime.hour % 12}:${mentor.mentorRegStartTime.minute.toString().padLeft(2, '0')} ${mentor.mentorRegStartTime.hour < 12 ? 'AM' : 'PM'} - "
                                            "${mentor.mentorRegEndTime.hour % 12}:${mentor.mentorRegEndTime.minute.toString().padLeft(2, '0')} ${mentor.mentorRegEndTime.hour < 12 ? 'AM' : 'PM'}",
                                        icon: CupertinoIcons
                                            .check_mark_circled_solid,
                                        iconColor: Colors.blue,
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () {
                if (selectedDay.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You cannot create a schedule for a past date.',
                      ),
                    ),
                  );
                  return;
                }
                showMyDialog();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 100),
                transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
                padding: EdgeInsets.symmetric(
                  horizontal: screenHeight * 0.025,
                  vertical: screenHeight * 0.007,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  color: Color(0xFF1877F2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: _isPressed ? 20 : 30,
                      spreadRadius: _isPressed ? 0 : 1,
                    )
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
            )),
      ]),
    );
  }
}
