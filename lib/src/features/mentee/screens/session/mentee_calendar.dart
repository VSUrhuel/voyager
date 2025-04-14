// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:voyager/src/features/mentee/controller/mentee_schedule_controller.dart';
import 'package:voyager/src/features/mentor/model/schedule_model.dart';
import 'package:voyager/src/features/mentor/widget/task.dart';

class MenteeCalendarView extends StatefulWidget {
  const MenteeCalendarView({super.key});

  @override
  State<MenteeCalendarView> createState() => _MenteeCalendarViewState();
}

class _MenteeCalendarViewState extends State<MenteeCalendarView> {
  MenteeScheduleController menteeScheduleController =
      Get.put(MenteeScheduleController());
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  bool _isLoading = false;
  late List<ScheduleModel> scheduleListToday = [];

  Future<void> _loadScheduleForSelectedDay(DateTime day) async {
    setState(() => _isLoading = true);

    try {
      final schedules =
          await menteeScheduleController.getUpcomingScheduleForMentee(
              menteeScheduleController.currentUserEmail);
      final filteredSchedules = schedules.where((schedule) {
        return schedule.scheduleDate.year == day.year &&
            schedule.scheduleDate.month == day.month &&
            schedule.scheduleDate.day == day.day;
      }).toList();

      if (mounted) {
        setState(() {
          _isLoading = false;
          scheduleListToday = filteredSchedules;
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduleForSelectedDay(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    void onDaySelected(DateTime newSelectedDay, DateTime newFocusedDay) {
      if (!isSameDay(selectedDay, newSelectedDay)) {
        setState(() {
          selectedDay = newSelectedDay;
          focusedDay = newFocusedDay;
          _isLoading = true;
        });

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
        elevation: 0,
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
                              else if (scheduleListToday.isEmpty)
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
    );
  }
}
