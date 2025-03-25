import 'package:flutter/material.dart';
import 'package:voyager/src/widgets/upcoming_sched_card.dart';

class UpcomingSession extends StatelessWidget {
  const UpcomingSession({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            UpcomingSchedCard(),
            UpcomingSchedCard(),
            UpcomingSchedCard()
          ],
        ),
      ),
    );
  }
}
