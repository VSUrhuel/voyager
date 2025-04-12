import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:voyager/src/features/admin/controllers/course_controller.dart';
import 'package:voyager/src/features/admin/screens/admin_dashboard.dart';
import 'package:voyager/src/features/admin/screens/courses/course_list.dart';
import 'package:voyager/src/features/admin/widgets/cover_photo_picker.dart';
import 'package:voyager/src/widgets/custom_button.dart';

class AddCourse extends StatefulWidget {
  const AddCourse({super.key});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  final TextEditingController _textController = TextEditingController();
  final CourseController _courseController = Get.put(CourseController());
  // final List<String> _deliverables = [];
  final FocusNode _focusNode = FocusNode();
  double height = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _textController.text.isNotEmpty) {
        _addItem();
      }
    });
  }

  void _addItem() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _courseController.courseDeliverables.add(_textController.text);
      height = height + 0.07;
      _textController.clear();
    });
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final GlobalKey<CoverPhotoPickerState> _pickerKey =
        GlobalKey();

    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Add Course',
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
                child: Column(
                  children: [
                    Expanded(
                      
                      // height: screenHeight * 0.70,
                      // padding: EdgeInsets.only(
                      //   bottom: screenHeight * 0.04,
                      // ),
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Add Course\'s Information',
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
                                padding:
                                    EdgeInsets.only(top: screenHeight * 0.02),
                                child: TextFormField(
                                  controller: _courseController.courseCode,

                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        left: screenWidth * 0.05,
                                        top: screenHeight * 0.016,
                                        bottom: screenHeight * 0.016),
                                    labelText: 'Enter Course Code ',
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
                                padding:
                                    EdgeInsets.only(top: screenHeight * 0.02),
                                child: TextFormField(
                                  controller: _courseController.courseName,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        left: screenWidth * 0.05,
                                        top: screenHeight * 0.016,
                                        bottom: screenHeight * 0.016),
                                    labelText: 'Enter Course Name ',
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
                                padding:
                                    EdgeInsets.only(top: screenHeight * 0.02),
                                child: TextFormField(
                                  controller: _courseController.courseDescription,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        left: screenWidth * 0.05,
                                        top: screenHeight * 0.016,
                                        bottom: screenHeight * 0.016),
                                    labelText: 'Enter Course Description ',
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
                                padding:
                                    EdgeInsets.only(top: screenHeight * 0.02),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _textController,
                                        focusNode: _focusNode,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(
                                              left: screenWidth * 0.05,
                                              top: screenHeight * 0.016,
                                              bottom: screenHeight * 0.016),
                                          labelText:
                                              'Enter Course\'s Deliverables',
                                          labelStyle: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            height: 1,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _addItem(),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: _addItem,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * height,
                                child: Expanded(
                                  child: ListView.builder(
                                      itemCount: _courseController.courseDeliverables.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          child: ListTile(
                                            title: Text(_courseController.courseDeliverables[index]),
                                            trailing: IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  _courseController.courseDeliverables.removeAt(index);
                                                  height = height - 0.07;
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding:
                                    EdgeInsets.only(bottom: screenHeight * 0.05),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade600,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: screenHeight * 0.2,
                                  width: screenWidth * 0.5,
                                  child: CoverPhotoPicker(
                                    key: _pickerKey,
                                    onImagePicked: (image){
                                      _courseController.courseImage = image;
                                    },
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ),
                    // Spacer(),
                    SizedBox(
                      height: screenHeight * 0.00001,
                    ),
                    DefaultButton(
                      buttonText: 'Proceed',
                      bgColor: Color(0xFF1877F2),
                      textColor: Colors.white,
                      isLoading: false,
                      borderColor: Colors.transparent,
                      onPressed: () async {
                        final currentContext = context;
                        final messenger = ScaffoldMessenger.of(currentContext);
                        // final navigator = Navigator.of(currentContext);
                        try{
                           showDialog(
                              context: currentContext,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );
                          await _courseController.createCourse();
                          _courseController.courseCode.clear();
                          _courseController.courseName.clear();
                          _courseController.courseDescription.clear();
                          _courseController.courseDeliverables.clear();
                        _pickerKey.currentState?.resetImage();
                        
                        if (currentContext.mounted) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Course added successfully')),
                        );
                        Navigator.of(currentContext).pop();
                        // Navigator.push(context,
                        // MaterialPageRoute(builder: (context) => CourseList()));
                      }

                        }catch(e){
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } 
                        
                      },
                    ),
                  ],
                ))));
  }
}
