// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DisplayLinks extends StatelessWidget {
  final List<Map<String, String>> links;
  const DisplayLinks({super.key, required this.links});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenHeight * 0.01,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                ),
                child: Text(
                  'Links',
                  style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: screenHeight * 0.019,
                  ),
                ),
              ),
              for (final link in links)
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  child: InkWell(
                    onTap: () async {
                      final uri = Uri.tryParse(link['url'] ?? '');

                      if (uri != null) {
                        if (!await launchUrl(uri)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to open $uri'),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      link['title'] ?? '',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                        fontSize: screenHeight * 0.019,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}
