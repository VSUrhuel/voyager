import 'package:flutter/material.dart';

class MenteeUserAgreement extends StatelessWidget {
  const MenteeUserAgreement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Agreement'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CS3 Mentorship Program',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Last Updated: ${DateTime.now().toString().substring(0, 10)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(15),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'By using eduvate, you agree to the following terms:',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 15),
                  _AgreementItem(
                    title: '1. Appropriate Conduct',
                    content:
                        'All users must maintain professional and respectful communication. Harassment or inappropriate behavior will not be tolerated.',
                  ),
                  _AgreementItem(
                    title: '2. Data Privacy',
                    content:
                        'Your personal information will be protected and only used for mentorship purposes in accordance with our privacy policy.',
                  ),
                  _AgreementItem(
                    title: '3. Commitment',
                    content:
                        'Mentors and mentees are expected to honor their scheduled meetings and communicate promptly about any changes.',
                  ),
                  _AgreementItem(
                    title: '4. Content Responsibility',
                    content:
                        'Users are responsible for the content they share. The university is not liable for user-generated content.',
                  ),
                  _AgreementItem(
                    title: '5. Termination',
                    content:
                        'The program administrators reserve the right to remove users who violate these terms.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _AgreementItem extends StatelessWidget {
  final String title;
  final String content;

  const _AgreementItem({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
