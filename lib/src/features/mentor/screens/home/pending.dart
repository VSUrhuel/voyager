import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';
import 'package:voyager/src/widgets/vertical_widget_slider.dart';

class PendingList extends StatelessWidget {
  PendingList({super.key});
  FirestoreInstance firestore = FirestoreInstance();
  Future<List<UserModel>> getPendingMentees() async {
    List<UserModel> mentee = await firestore.getMentees("pending");
    return mentee;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            FutureBuilder<List<UserModel>>(
              future: getPendingMentees(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No approved mentees');
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
