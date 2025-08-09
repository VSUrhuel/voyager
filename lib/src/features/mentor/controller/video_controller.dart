import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlaybackController extends GetxController {
  static VideoPlaybackController get instance => Get.find();
  late VideoPlayerController videoController =
      // ignore: deprecated_member_use
      VideoPlayerController.network('');

  void initialize(String url) {
    // ignore: deprecated_member_use
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
