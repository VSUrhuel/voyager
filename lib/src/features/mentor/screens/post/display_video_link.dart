import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:voyager/src/features/mentor/controller/post_controller.dart'; // For better controls

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
  bool _isDownloading = false;
  double _downloadProgress = 0;
  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  PostController postController = Get.put(PostController());
  Future<void> _downloadVideo() async {
    // Implement video download logic here
    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0;
      });

      if (!await postController.requestStoragePermission()) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
        return;
      }

      final downloadPath = await postController.getPublicDownloadsPath();
      final fileName = widget.videoLink.split('/').last;
      final savePath = '$downloadPath/$fileName';

      await Dio().download(
        widget.videoLink,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video saved to Downloads/$fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0;
        });
      }
    }
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
        widget.videoLink == ''
            ? SizedBox(
                height: 0,
              )
            : _buildVideoContent(),
        if (_isDownloading) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _downloadProgress),
          const SizedBox(height: 4),
          Text(
            'Downloading: ${(_downloadProgress * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 12),
          ),
        ],
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
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            const Text("Failed to load video"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _downloadVideo,
              child: const Text('Try Download Video'),
            ),
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
          height: maxHeight.clamp(100, 400),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Chewie(controller: _chewieController!),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  onPressed: _isDownloading ? null : _downloadVideo,
                  child: _isDownloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download, color: Colors.blue),
                ),
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
