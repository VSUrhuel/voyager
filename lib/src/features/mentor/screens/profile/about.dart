import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('About the App'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo/Icon placeholder
                Image.asset(
                  'assets/images/application_images/eduvate_logo.png', // Replace with your actual asset
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'eduvate',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Development Team Section
                Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'Development Team',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )),

                const SizedBox(height: 20),

                // Team Member Cards
                _buildTeamMemberCard(
                  name: 'John Rhuel laurente', // Replace with your name
                  role: 'Project Manager',
                  description:
                      'Project coordination and full-stack development',
                  imagePath:
                      'assets/images/application_images/rhuel.png', // Replace with your image
                ),
                const SizedBox(height: 15),
                _buildTeamMemberCard(
                  name: 'Francis Mark Baguion',
                  role: 'Lead Developer',
                  description: 'Full-stack development & database management',
                  imagePath: 'assets/images/application_images/francis-pic.png',
                ),
                const SizedBox(height: 15),
                _buildTeamMemberCard(
                  name: 'Jade Jaballa',
                  role: 'Test Engineer',
                  description:
                      'Testing, quality assurance, and database integration',
                  imagePath: 'assets/images/application_images/jade-pic.png',
                ),
                const SizedBox(height: 30),

                // Project Info
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About the Project',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This mentorship application was developed as part of the Software Engineering course at Visayas State University - Computer Science Department. '
                        'The app connects mentors and mentees within the Computer Science Students Society.',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.justify,
                      ),
                      // Add this to your project info section
                      const SizedBox(height: 10),
                      const Text(
                        'Key Features:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text('• Mentor-mentee matching'),
                      const Text('• Progress tracking'),
                      const Text('• Resource sharing'),
                      const Text('• Community forums'),

// Add contact section
                      const SizedBox(height: 20),
                      const Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.email, size: 16),
                          SizedBox(width: 5),
                          Text('johnrhuell@gmailcom'),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Row(
                        children: [
                          Icon(Icons.public, size: 16),
                          SizedBox(width: 5),
                          Text('github.com/VSUrhuel'),
                        ],
                      ),

// Add legal section
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('This will be defined soon!'),
                                ),
                              );
                            }, // Add navigation to privacy policy
                            child: const Text('Privacy Policy'),
                          ),
                          Text(
                            '|',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('This will be defined soon!'),
                                ),
                              );
                            }, // Add navigation to terms
                            child: Text('Terms of Service'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        '© 2025 CS3. All rights reserved.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String description,
    required String imagePath,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            // CircleAvatar(
            //   radius: 30,
            //   backgroundImage: Image.asset(imagePath).image,
            // ),
            Image.asset(
              imagePath,
              height: 100,
              width: 100,
            ),
            const SizedBox(width: 15),
            // Member Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
