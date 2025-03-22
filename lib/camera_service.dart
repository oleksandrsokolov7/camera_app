import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CameraService {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool _isRecording = false;

  CameraController? get controller => _controller;
  bool get isRecording => _isRecording;

  Future<void> initCamera() async {
    _cameras = await availableCameras();

    if (_cameras.isEmpty) {
      throw Exception("Камеры не найдены");
    }

    _controller = CameraController(_cameras.first, ResolutionPreset.high);

    try {
      await _controller?.initialize();
    } catch (e) {
      print("Ошибка инициализации камеры: $e");
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2 || _controller == null) return;

    final currentIndex = _cameras.indexOf(_controller!.description);
    final newIndex = (currentIndex + 1) % _cameras.length;

    await _controller?.dispose();
    _controller = CameraController(_cameras[newIndex], ResolutionPreset.high);

    try {
      await _controller?.initialize();
    } catch (e) {
      print("Ошибка переключения камеры: $e");
    }
  }

  Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;

    try {
      final image = await _controller!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await image.saveTo(imagePath);

      return imagePath;
    } catch (e) {
      print("Ошибка съемки фото: $e");
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording) {
      return;
    }

    try {
      _isRecording = true;
      await _controller!.startVideoRecording();
    } catch (e) {
      print("Ошибка начала записи видео: $e");
      _isRecording = false;
    }
  }

  Future<String?> stopVideoRecording() async {
    if (!_isRecording || _controller == null) return null;

    try {
      _isRecording = false;
      final file = await _controller!.stopVideoRecording();
      return file.path;
    } catch (e) {
      print("Ошибка остановки записи видео: $e");
      return null;
    }
  }
}
