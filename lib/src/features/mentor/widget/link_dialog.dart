import 'package:flutter/material.dart';
import 'package:voyager/src/widgets/custom_text_field.dart';

class LinkDialog extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController urlController;
  final double screenWidth;
  final double screenHeight;

  const LinkDialog({
    super.key,
    required this.titleController,
    required this.urlController,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: screenWidth * 0.9,
          maxWidth: screenWidth * 0.9,
          maxHeight: screenHeight * 0.5,
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add a new link",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              CustomTextField(
                controllerParam: titleController,
                hintText: 'Link Title',
                fieldWidth: screenWidth * 0.8,
                fontSize: screenWidth * 0.04,
              ),
              CustomTextField(
                controllerParam: urlController,
                hintText: 'Link URL',
                fieldWidth: screenWidth * 0.8,
                fontSize: screenWidth * 0.04,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (urlController.text.contains('http') == false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid URL'),
                          ),
                        );
                        return;
                      }

                      final uri = Uri.tryParse(urlController.text);
                      if (uri == null || !uri.hasScheme) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid URL'),
                          ),
                        );
                        return;
                      }
                      if (titleController.text.isNotEmpty &&
                          urlController.text.isNotEmpty) {
                        Navigator.of(context).pop(true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter both title and URL'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
