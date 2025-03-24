import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: NotificationContentCard(),
        ),
      ),
    );
  }
}

class NotificationContentCard extends StatelessWidget {
  const NotificationContentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bigger Icon on the Left
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center, // Centers the icon
              child: const Icon(
                Icons.campaign,
                size: 40, // Bigger icon
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 12),

            // Text Content on the Right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CSci 13 - Fundamentals of Programming\nMentorship Session Later, January 12, 2024 at 3:00 PM at DCST Room 202",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "15 mins ago",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
