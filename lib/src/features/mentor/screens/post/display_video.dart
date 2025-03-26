import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class DisplayVideo extends StatefulWidget {
  final File video;
  final VoidCallback onDelete;

  const DisplayVideo({
    super.key,
    required this.video,
    required this.onDelete,
  });

  @override
  State<DisplayVideo> createState() => _DisplayVideoState();
}

class _DisplayVideoState extends State<DisplayVideo> {
  late VideoPlayerController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.file(widget.video)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }).catchError((error) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        print("Error initializing video: $error");
      });
  }

  @override
  void didUpdateWidget(DisplayVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.path != widget.video.path) {
      _controller.dispose();
      _isLoading = true;
      _initializeController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Video File",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildVideoPlayer(),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final aspectRatio = _controller.value.aspectRatio;
        final maxHeight = constraints.maxWidth / aspectRatio;

        return SizedBox(
          width: constraints.maxWidth,
          height: maxHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Positioned.fill(
                  child: IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.remove_circle_outlined,
                        color: Colors.red),
                    onPressed: widget.onDelete,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
