import 'package:flutter/material.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';

class ProfileMentor extends StatelessWidget {
  const ProfileMentor({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuthenticationRepository();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, // Assuming a white background
          elevation: 1.0, // Optional: Add a subtle shadow
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back, color: Colors.black), // Black arrow back
            onPressed: () {
              Navigator.pop(context); // Go back when pressed
            },
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              color: Colors.black, // Black text
              fontWeight: FontWeight.normal, // Normal font weight
              fontSize: 18.0, // Adjust font size as needed
            ),
          ),
          centerTitle: true, // Align title to the left
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
              ),
              Text(
                'John Doe',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Mentor',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () async {
                  await auth.logout();
                },
                child: const Text('Go to Login'),
              )
            ],
          ),
        ));
  }
}
