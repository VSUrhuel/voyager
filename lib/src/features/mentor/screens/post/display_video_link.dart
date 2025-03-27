import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart'; // For better controls

class DisplayVideoLink extends StatefulWidget {
  final String videoLink;

  const DisplayVideoLink({
    super.key,
    required this.videoLink,
  });

  @override
  State<DisplayVideoLink> createState() => _DisplayVideoLinkState();
}

class _DisplayVideoLinkState extends State<DisplayVideoLink> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      // Use network constructor for internet URLs
      _controller = VideoPlayerController.network(widget.videoLink)
        ..addListener(() {
          if (mounted) setState(() {});
        });

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: false,
            looping: false,
            allowFullScreen: true,
            allowMuting: true,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.blue,
              handleColor: Colors.blueAccent,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.grey[300]!,
            ),
          );
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      debugPrint("Error initializing video: $error");
    }
  }

  @override
  void didUpdateWidget(DisplayVideoLink oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoLink != widget.videoLink) {
      _controller.dispose();
      _chewieController?.dispose();
      _isLoading = true;
      _hasError = false;
      _initializeController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildVideoContent(),
      ],
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 8),
            Text("Failed to load video"),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final aspectRatio = _controller.value.aspectRatio;
        final maxHeight = constraints.maxWidth / aspectRatio;

        return SizedBox(
          width: constraints.maxWidth,
          height: maxHeight.clamp(100, 400), // Set reasonable min/max heights
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Chewie(controller: _chewieController!),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
