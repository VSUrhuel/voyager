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
                child: Text(link['title'] ?? ''),
                onTap: () async {
                  final url = Uri.parse(link['url'] ?? '');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not launch URL'),
                      ),
                    );
                  }
                },
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
