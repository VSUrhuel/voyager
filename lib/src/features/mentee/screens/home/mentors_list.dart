import 'package:voyager/src/features/mentee/widgets/mentor_card.dart';
import 'package:voyager/src/features/mentee/widgets/normal_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class MentorsList extends StatefulWidget {
  const MentorsList({super.key});

  @override
  State<MentorsList> createState() => _MentorsListState();
}

class _MentorsListState extends State<MentorsList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _isSearching = _searchText.isNotEmpty;
      });
    });
  }

  Future<List<MentorCard>> fetchMentorsWithDetails() async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
    try {
      // Fetching list of users (mentors)
      List<UserModel> users = await firestoreInstance.getMentors();

      // Fetch mentor details for each user
      List<MentorModel> mentorDetails = await Future.wait(users.map((user) =>
          firestoreInstance.getMentorThroughAccId(user.accountApiID)));

      // Return list of MentorCard widgets with fetched data
      List<MentorCard> mentors = List.generate(users.length, (index) {
        return MentorCard(
          mentorModel: mentorDetails[index],
          user: users[index],
          isSmallCard: true,
        );
      });

      if (_isSearching) {
        mentors = mentors.where((mentor) {
          return mentor.user.accountApiName
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()) ||
              mentor.user.accountApiName
                  .toLowerCase()
                  .contains(_searchText.toLowerCase());
        }).toList();
      }
      return mentors;
    } catch (e) {
      print("Error fetching mentors: $e");
      return []; // Return an empty list in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Mentors List',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          NormalSearchbar(searchController: _searchController),
          Expanded(
            child: FutureBuilder<List<MentorCard>>(
              future: fetchMentorsWithDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(child: Text("No mentors available"));
                }

                List<Widget> rows = [];
                int itemCount = snapshot.data!.length;

                // Build the rows of mentor cards
                for (int i = 0; i < itemCount; i += 2) {
                  var mentorCard = snapshot.data![i];

                  if (i + 1 < itemCount) {
                    var mentorCard2 = snapshot.data![i + 1];

                    rows.add(
                      Row(
                        children: [
                          Expanded(child: mentorCard),
                          SizedBox(width: 8.0),
                          Expanded(child: mentorCard2),
                        ],
                      ),
                    );
                  } else {
                    rows.add(
                      Row(
                        children: [
                          Expanded(child: mentorCard),
                        ],
                      ),
                    );
                  }
                  rows.add(SizedBox(height: 8.0));
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(children: rows),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
