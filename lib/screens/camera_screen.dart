import 'dart:io';
import 'package:camera/camera.dart';
import 'package:camera_app/camera_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  static const platform = MethodChannel('com.example.camera_app/mediastore');
  final CameraService _cameraService = CameraService();
  File? _overlayImage;
  bool _isRecording = false;
  String? _lastCapturedPath;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await _cameraService.initCamera();
    setState(() {});
  }

  Future<void> _pickOverlayImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _overlayImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final pictureFile = await _cameraService.takePicture();
    if (pictureFile != null) {
      setState(() {
        _lastCapturedPath = pictureFile;
      });
      _showSaveDialog('photo');
    }
  }

  Future<void> _startVideoRecording() async {
    await _cameraService.startVideoRecording();
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopVideoRecording() async {
    final videoFile = await _cameraService.stopVideoRecording();
    if (videoFile != null) {
      setState(() {
        _lastCapturedPath = videoFile;
      });
      _showSaveDialog('video');
    }
  }

  Future<void> _showSaveDialog(String type) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(type == 'photo' ? 'Сохранить фото?' : 'Сохранить видео?'),
          content: Text(
            type == 'photo'
                ? 'Вы хотите сохранить это фото в галерею?'
                : 'Вы хотите сохранить это видео в галерею?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (result == true && _lastCapturedPath != null) {
      _saveToGallery(File(_lastCapturedPath!));
    }
  }

  Future<void> _saveToGallery(File file) async {
    try {
      final result = await platform.invokeMethod('saveImage', {
        'imagePath': file.path,
      });
      print(result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Файл сохранён в галерею')));
    } on PlatformException catch (e) {
      print("Ошибка при сохранении: '${e.message}'.");
    }
  }

  Future<void> _switchCamera() async {
    await _cameraService.switchCamera();
    setState(() {});
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopVideoRecording();
    } else {
      await _startVideoRecording();
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Камера на весь экран
          _cameraService.controller != null &&
                  _cameraService.controller!.value.isInitialized
              ? Positioned.fill(
                child: CameraPreview(_cameraService.controller!),
              )
              : Center(child: CircularProgressIndicator()),

          // Наложенное изображение с прозрачностью 80%
          if (_overlayImage != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.8,
                child: Image.file(_overlayImage!, fit: BoxFit.cover),
              ),
            ),

          // Кнопки управления (внизу)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      onPressed: _switchCamera,
                      heroTag: 'switch',
                      child: Icon(Icons.switch_camera),
                    ),
                    FloatingActionButton(
                      onPressed: _takePicture,
                      heroTag: 'photo',
                      child: Icon(Icons.camera),
                    ),
                    FloatingActionButton(
                      onPressed:
                          _isRecording
                              ? _stopVideoRecording
                              : _startVideoRecording,
                      backgroundColor: _isRecording ? Colors.red : Colors.blue,
                      heroTag: 'video',
                      child: Icon(_isRecording ? Icons.stop : Icons.videocam),
                    ),
                    FloatingActionButton(
                      onPressed: _pickOverlayImage,
                      heroTag: 'overlay',
                      child: Icon(Icons.image),
                    ),
                  ],
                ),
                SizedBox(height: 10), // Отступ перед текстом
                // Последняя фиксация (путь к файлу)
                if (_lastCapturedPath != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Последний файл: $_lastCapturedPath',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
