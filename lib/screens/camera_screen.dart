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
  static const platform = MethodChannel(
    'com.example.camera_app/mediastore',
  ); // Канал для связи с платформой
  final CameraService _cameraService = CameraService();
  File? _overlayImage;
  bool _isRecording = false;
  String? _lastCapturedPath; // Храним путь к последнему снятому фото или видео

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
      _showSaveDialog('photo'); // Показываем диалог для сохранения фото
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
      _showSaveDialog('video'); // Показываем диалог для сохранения видео
    }
  }

  // Функция для отображения диалога с вопросом
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
                Navigator.of(context).pop(false); // Закрываем диалог с отказом
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Закрываем диалог с согласием
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );

    // Если пользователь подтвердил, сохраняем файл
    if (result == true && _lastCapturedPath != null) {
      _saveToGallery(File(_lastCapturedPath!));
    }
  }

  Future<void> _saveToGallery(File file) async {
    try {
      final result = await platform.invokeMethod('saveImage', {
        'imagePath': file.path,
      });
      print(result); // Сообщение от платформенного кода
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

          // Кнопки управления
          Positioned(
            bottom: 50,
            left: 20,
            child: FloatingActionButton(
              onPressed: _switchCamera,
              child: Icon(Icons.switch_camera),
            ),
          ),

          Positioned(
            bottom: 50,
            right: 20,
            child: FloatingActionButton(
              onPressed: _takePicture,
              child: Icon(Icons.camera),
            ),
          ),

          // Кнопка для начала записи видео
          Positioned(
            bottom: 120,
            right: 20,
            child: FloatingActionButton(
              onPressed: _startVideoRecording,
              backgroundColor: Colors.blue,
              child: Icon(Icons.videocam),
            ),
          ),

          // Кнопка для остановки записи видео
          Positioned(
            bottom: 120,
            right: 100,
            child: FloatingActionButton(
              onPressed: _stopVideoRecording,
              backgroundColor: Colors.red,
              child: Icon(Icons.stop),
            ),
          ),

          Positioned(
            bottom: 120,
            left: 20,
            child: FloatingActionButton(
              onPressed: _pickOverlayImage,
              child: Icon(Icons.image),
            ),
          ),
        ],
      ),
    );
  }
}
