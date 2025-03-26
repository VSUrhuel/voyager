import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewSection extends StatelessWidget {
  final List<File> images;
  final double screenHeight;
  final double screenWidth;
  final VoidCallback onAddImage;
  final Function(File) onRemoveImage;

  const ImagePreviewSection({
    super.key,
    required this.images,
    required this.screenHeight,
    required this.screenWidth,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: screenHeight * 0.26,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Image Files",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_a_photo_rounded,
                  color: Colors.black,
                ),
                onPressed: onAddImage,
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var image in images)
                  Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: screenHeight * 0.01),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            image,
                            width: screenHeight * 0.18,
                            height: screenHeight * 0.18,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 2,
                        child: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outlined,
                            color: Colors.red,
                          ),
                          onPressed: () => onRemoveImage(image),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
