import 'package:voyager/src/features/mentor/widget/toggle_button_icons.dart';
import 'package:flutter/material.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  List<bool> isSelected = [false, false];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.only(right: screenHeight * 0.02),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                ),
                child: Text('Post'),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01,
                    horizontal: screenHeight * 0.03),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Post Content",
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        height: screenHeight * 0.55,
                        decoration: BoxDecoration(
                          color: Color(0x60eaeaec),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                            padding: EdgeInsets.only(
                                top: screenHeight * 0.013,
                                left: screenHeight * 0.01),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: screenHeight *
                                          0.027, // Adjust radius as needed
                                      child: Image.asset(
                                          'assets/images/application_images/profile.png'), // Replace with your image URL
                                    ),
                                    SizedBox(width: 16),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'John Rhuel Laurente',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: screenHeight *
                                                  0.02, // Adjust font size as needed
                                              fontWeight:
                                                  FontWeight.w500, // Semi-bold
                                            ),
                                          ),
                                          Text(
                                            'johnrhuell@gmail.com',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: screenHeight *
                                                  0.015, // Adjust font size as needed
                                            ),
                                          ),
                                        ]),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  height: screenHeight * 0.4,
                                  margin: EdgeInsets.only(
                                      top: screenHeight * 0.02,
                                      left: screenHeight * 0.01,
                                      right: screenHeight * 0.02),
                                  child: TextField(
                                    maxLines: 10,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: 'Write something...',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.image),
                                      onPressed: () {},
                                      constraints: BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.video_call),
                                      onPressed: () {},
                                      constraints: BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.insert_link),
                                      onPressed: () {},
                                      constraints: BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.mic),
                                      onPressed: () {},
                                      constraints: BoxConstraints(),
                                    ),
                                  ],
                                )
                              ],
                            )),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text("Category",
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: screenHeight * 0.01),
                      ToggleButtonIcons(),
                    ]))));
  }
}
