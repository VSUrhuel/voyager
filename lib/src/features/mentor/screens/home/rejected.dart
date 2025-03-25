import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';
import 'package:voyager/src/widgets/vertical_widget_slider.dart';

class RejectedList extends StatefulWidget {
  const RejectedList({super.key});

  @override
  State<RejectedList> createState() => _RejectedListState();
}

class _RejectedListState extends State<RejectedList> {
  FirestoreInstance firestore = FirestoreInstance();
  Future<List<UserModel>> getRejectedMentees() async {
    List<UserModel> users = await firestore.getMentees("rejected");
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            FutureBuilder<List<UserModel>>(
              future: getRejectedMentees(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No rejected mentees');
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
