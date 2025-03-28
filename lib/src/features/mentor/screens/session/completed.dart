import 'package:flutter/material.dart';
import 'package:voyager/src/widgets/completed_sched_card.dart';

class CompletedSession extends StatelessWidget {
  const CompletedSession({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            CompletedSchedCard(),
            CompletedSchedCard(),
            CompletedSchedCard()
          ],
        ),
      ),
    );
  }
}
