import 'package:flutter/material.dart';

class AdminMentorCard extends StatelessWidget {
  final String mentor;
  final String email;
  final String studentId;
  final String schedule;
  final List<String> course;

  const AdminMentorCard({
    super.key,
    required this.mentor,
    required this.email,
    required this.studentId,
    required this.schedule,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () {},
      child: Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            side: BorderSide(
              color: Color(0xFF9494A0),
              width: 0.5,
            ),
          ),
          child: SizedBox(
              height: screenHeight * 0.09,
              width: screenWidth * 0.9,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  width: screenWidth * 0.2,
                  child: Icon(
                    Icons.person,
                    size: screenWidth * 0.1,
                  ),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mentor,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          )),
                      Row(children: [
                        Builder(
                          builder: (context) {
                            email;
                            double baseFontSize = screenWidth * 0.027;
                            double dynamicFontSize = email.length > 22
                                ? baseFontSize * (22 / email.length)
                                : baseFontSize;

                            return Text(
                              email,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: dynamicFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        Text(' · '),
                        Text(studentId,
                            style: TextStyle(
                              wordSpacing: 0,
                              color: Colors.black,
                              fontSize: screenWidth * 0.027,
                              fontWeight: FontWeight.normal,
                            )),
                      ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(schedule,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.028,
                                  fontWeight: FontWeight.normal,
                                  height: 1.0,
                                )),
                            SizedBox(width: screenWidth * 0.02),
                            IntrinsicWidth(
                              child: Container(
                                padding: EdgeInsets.only(left: 7, right: 7),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Builder(
                                  builder: (context) {
                                    course[0]; //will make this array later
                                    String dynamicText = '';
                                    if (course[0].length > 17) {
                                      for (var element
                                          in course[0].split(' ')) {
                                        if (element.isNotEmpty &&
                                            element[0].toUpperCase() ==
                                                element[0]) {
                                          String sub = element.substring(0, 3);
                                          dynamicText += sub;
                                        }
                                      }
                                      course[0] = dynamicText;
                                    }

                                    return Text(course[0],
                                        style: TextStyle(
                                          color: Colors.blue[800],
                                          fontSize: screenWidth * 0.025,
                                          fontWeight: FontWeight.w600,
                                        ));
                                  },
                                ),
                              ),
                            ),
                          ]),
                    ]),
                Spacer(),
                IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
              ]))),
    );
  }
}
