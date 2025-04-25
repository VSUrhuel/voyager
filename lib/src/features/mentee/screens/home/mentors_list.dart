import 'package:lottie/lottie.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
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
                      return Column(
                    children: [
                      SizedBox(
                          height: 24.0), // space between searchbar and loader
                      Center(
                        child: Lottie.asset(
                          'assets/images/loading.json',
                          fit: BoxFit.cover,
                          width: screenHeight * 0.08,
                          height: screenWidth * 0.04,
                          repeat: true,
                        ),
                      ),
                    ],
                  );
                    }
    
                if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 100.0,
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05,
                          ),
                          child: Center(
                            child: Text(
                              "No mentors available",
                              style:
                                  TextStyle(fontSize: 16.0, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }

                List<Widget> rows = [];
                int itemCount = snapshot.data!.length;

                for (int i = 0; i < itemCount; i += 2) {
                  rows.add(
                    Row(
                      children: [
                        Expanded(child: snapshot.data![i]),
                        if (i + 1 < itemCount)
                          Expanded(child: snapshot.data![i + 1]),
                        if (i + 1 >= itemCount) Expanded(child: Container()),
                      ],
                    ),
                  );
                  rows.add(SizedBox(height: 8.0));
                }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        child: Column(children: rows),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
