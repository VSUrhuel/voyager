// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksSection extends StatelessWidget {
  final List<Map<String, String>> links;
  final Function(int) onRemoveLink;

  const LinksSection({
    super.key,
    required this.links,
    required this.onRemoveLink,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (links.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attached Links',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: links.length,
          itemBuilder: (context, index) {
            final link = links[index];
            return ListTile(
              title: InkWell(
                onTap: () async {
                  final uri = Uri.tryParse(link['url'] ?? '');

                  if (uri != null) {
                    if (!await launchUrl(uri)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to open $uri! Please check the URL.'),
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
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => onRemoveLink(index),
              ),
            );
          },
        ),
      ],
    );
  }
}
