import 'package:flutter/material.dart';
import '../camera_service.dart';
import '../overlay_service.dart';
import '../video_service.dart';

class ControlButtons extends StatefulWidget {
  final CameraService cameraService;
  final OverlayService overlayService;
  final VideoService videoService;

  const ControlButtons({
    super.key,
    required this.cameraService,
    required this.overlayService,
    required this.videoService,
  });

  @override
  _ControlButtonsState createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => widget.cameraService.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () => widget.overlayService.pickOverlayImage(),
          ),
          // Кнопка для начала записи
          if (!_isRecording)
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: () async {
                setState(() {
                  _isRecording = true;
                });
                await widget.cameraService.startVideoRecording();
              },
            ),
          // Кнопка для остановки записи
          if (_isRecording)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () async {
                setState(() {
                  _isRecording = false;
                });
                await widget.cameraService.stopVideoRecording();
              },
            ),
          IconButton(
            icon: const Icon(Icons.camera),
            onPressed: () => widget.cameraService.takePicture(),
          ),
        ],
      ),
    );
  }
}
