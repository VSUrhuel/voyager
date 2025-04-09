import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:voyager/src/features/admin/screens/admin_dashboard.dart';
import 'package:voyager/src/features/admin/widgets/profile_picker.dart';
import 'package:voyager/src/features/mentor/controller/mentor_controller.dart';
import 'package:voyager/src/widgets/custom_button.dart';

// import 'package:voyager/src/features/admin/widgets/regular_sched_picker.dart';

class AddMentor extends StatelessWidget {
  const AddMentor({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final MentorController controller = Get.put(MentorController());

    return SafeArea(
    child: Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Mentor',
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.08,
          right: screenWidth * 0.08,
        ),
        child: Container(
          padding: EdgeInsets.only(
            bottom: screenHeight * 0.04,
          ),
          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start, 
                  children: [
                    Text('Add Mentor\'s Information',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    ),

                    Text('Kindly provide the needed information',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w500,
                    )),

                    Container(
                      padding: EdgeInsets.only(top: screenHeight * 0.02),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.016, bottom: screenHeight * 0.016),
                          labelText: 'Course to Mentor',
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
                          'Object-Oriented Programming',
                          'Discrete Mathematics',
                          'Data Structures and Algorithms',
                          'Graphics and Visual Computing',
                          'Web Systems and Technologies',
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
                        //controller later
                        },
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.only(top: screenHeight * 0.02),
                      child: TextFormField(
                        // controller later
                    
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.016, bottom: screenHeight * 0.016),
                          labelText: 'Enter mentor\'s student ID ',
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
                      padding: EdgeInsets.only(top: screenHeight * 0.02),
                      child: TextFormField(
                        // controller later
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.016, bottom: screenHeight * 0.016),
                          labelText: 'Enter mentor\'s name ',
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
                      padding: EdgeInsets.only(top: screenHeight * 0.02),
                      child: TextFormField(
                        // controller later
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.016, bottom: screenHeight * 0.016),
                          labelText: 'Enter mentor\'s email ',
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
                      padding: EdgeInsets.only(top: screenHeight * 0.02),
                      child: TextFormField(
                        // controller later
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.016, bottom: screenHeight * 0.016),
                          labelText: 'Enter mentor\'s default password ',
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
                    //profile pic
                    Container(
              
                      // color: Colors.black,
                    
                     
                      padding: EdgeInsets.only(top: screenHeight * 0.02),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade600,
                            // width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: screenHeight * 0.06,
                        width: screenWidth * 0.9,
                        child: ProfilePicker(),
                      ),
                    ),

                    Spacer(),

                  SizedBox(height: screenHeight * 0.02),
                    DefaultButton(
                    buttonText: 'Proceed',
                    bgColor: Color(0xFF1877F2),
                    textColor: Colors.white,
                    isLoading: false,
                    borderColor: Colors.transparent,
                    onPressed: () async {
                      // create new default mentor
                      // await controller.generateMentor();
                      // await controller.updateUsername();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminDashboard(),
                        ),
                      );
                      controller.dispose();
                    },
                  ),
                  ]
                ),
        )
      )
    )
    );
  }
}