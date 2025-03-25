import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';
import 'package:voyager/src/widgets/vertical_widget_slider.dart';

class AcceptedList extends StatefulWidget {
  AcceptedList({super.key});

  @override
  State<AcceptedList> createState() => _AcceptedListState();
}

class _AcceptedListState extends State<AcceptedList> {
  FirestoreInstance firestore = FirestoreInstance();

  Future<List<UserModel>> getApprovedMentees() async {
    List<UserModel> users = await firestore.getMentees("approved");
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            FutureBuilder<List<UserModel>>(
              future: getApprovedMentees(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No pending mentees'));
                } else {
                  return VerticalWidgetSlider(
                    widgets: snapshot.data!
                        .map((mentee) => UserCard(user: mentee))
                        .toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
