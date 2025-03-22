import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../camera_service.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraService cameraService;

  const CameraPreviewWidget({super.key, required this.cameraService});

  @override
  Widget build(BuildContext context) {
    if (cameraService.controller == null ||
        !cameraService.controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(cameraService.controller!);
  }
}
