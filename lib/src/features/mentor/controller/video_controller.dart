import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlaybackController extends GetxController {
  static VideoPlaybackController get instance => Get.find();
  late VideoPlayerController videoController =
      VideoPlayerController.network('');

  void initialize(String url) {
    videoController = VideoPlayerController.network(url)..initialize();
  }

  void pauseVideo() {
    if (videoController.value.isPlaying) {
      videoController.pause();
    }
  }

  @override
  void onClose() {
    videoController.dispose();
    super.onClose();
  }
}
