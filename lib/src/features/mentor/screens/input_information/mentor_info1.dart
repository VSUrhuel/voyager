import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/about_controller.dart';
import 'package:voyager/src/features/mentor/controller/mentor_controller.dart';
import 'package:voyager/src/features/mentor/screens/input_information/mentor_info2.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_button.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MentorInfo1 extends StatelessWidget {
  MentorInfo1({super.key});

  final AboutController aboutController = AboutController();
  Future<UserModel?> getUserModel(String email) async {
    try {
      return await FirestoreInstance().getUserThroughEmail(email);
    } catch (e) {
      return null;
    }
  }

  String getName(String? name) {
    List names = name!.split(' ');
    return names.sublist(0, names.length - 1).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MentorController());
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        actionsIconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Padding(
          padding: EdgeInsets.only(
              left: screenWidth * 0.05, right: screenWidth * 0.05),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Input information',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kindly provide the needed information',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  child: Text(
                    'General Information',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  width: screenWidth * 0.4,
                  height: screenWidth * 0.20,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Year level',
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
                      '1st Year',
                      '2nd Year',
                      '3rd Year',
                      '4th Year',
                      '5th Year',
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
                      controller.mentorYearLvl.text = value.toString();
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5),
                  width: screenWidth,
                  height: screenWidth * 0.40,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      TextFormField(
                        controller: MentorController.instance.mentorAbout,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                        maxLength: 100,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'About information',
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
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  child: TextFormField(
                    controller: MentorController.instance.mentorUserName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                    decoration: InputDecoration(
                      icon: Icon(Icons.person_2_rounded,
                          size: screenWidth * 0.08),
                      labelText: 'Username',
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
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  child: TextFormField(
                    controller:
                        MentorController.instance.mentorSessionCompleted,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                    decoration: InputDecoration(
                      icon: FaIcon(
                        FontAwesomeIcons.clock,
                        size: screenWidth * 0.08,
                      ),
                      labelText: 'Number of mentorship sessions completed',
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
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  child: TextFormField(
                    controller: MentorController.instance.mentorMotto,
                    maxLength: 30,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Motto or Quote',
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
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: DefaultButton(
                    buttonText: 'Proceed',
                    bgColor: Color(0xFF1877F2),
                    textColor: Colors.white,
                    isLoading: false,
                    borderColor: Colors.transparent,
                    onPressed: () async {
                      Navigator.push(
                          context,
                          CustomPageRoute(
                              page: MentorInfo2(),
                              direction: AxisDirection.left));
                    },
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
              ]),
        ),
      )),
    );
  }
}
