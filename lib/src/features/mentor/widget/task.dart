import 'package:flutter/material.dart';

class Task extends StatelessWidget {
  const Task(
      {super.key,
      required this.taskName,
      required this.taskDescription,
      required this.icon,
      required this.iconColor});

  final String taskName;
  final String taskDescription;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.01),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: screenWidth * 0.08,
              ),
              Padding(
                  padding: EdgeInsets.only(
                      left: screenHeight * 0.01, right: screenHeight * 0.01),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                          width: screenWidth * 0.62,
                          child: Text(
                            taskDescription,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                            ),
                            maxLines: 2, // Or whatever number you prefer
                            overflow: TextOverflow
                                .ellipsis, // Only kicks in after maxLines is exceeded
                          ))
                    ],
                  )),
            ],
          )),
    );
  }
}
