import 'dart:io';
import 'package:video_player/video_player.dart';

class VideoService {
  VideoPlayerController? _controller;

  VideoPlayerController? get controller => _controller;

  Future<void> initializeVideo(String filePath) async {
    _controller = VideoPlayerController.file(File(filePath));
    await _controller?.initialize();
  }

  Future<void> playVideo() async {
    await _controller?.play();
  }

  Future<void> pauseVideo() async {
    await _controller?.pause();
  }
}
