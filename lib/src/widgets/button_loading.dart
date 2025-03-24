import 'package:flutter/material.dart';

class ButtonLoading extends StatelessWidget {
  const ButtonLoading({super.key, this.bgColor, this.textColor = Colors.black});

  final Color? bgColor, textColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(textColor!),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Loading...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
