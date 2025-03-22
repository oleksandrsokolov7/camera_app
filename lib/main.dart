import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera_app/screens/camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Запрос разрешений
  await _requestPermissions();

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  // Запрашиваем разрешения для камеры, микрофона, хранилища и фотографии
  final cameraStatus = await Permission.camera.request();
  final microphoneStatus = await Permission.microphone.request();
  final storageStatus = await Permission.storage.request();
  final photosStatus = await Permission.photos.request();

  if (cameraStatus.isDenied ||
      microphoneStatus.isDenied ||
      storageStatus.isDenied ||
      photosStatus.isDenied) {
    // Можно добавить обработку отказа в разрешении
    print(
      "Необходимо предоставить разрешения для камеры, микрофона, хранилища и фотографий",
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: CameraScreen(),
    );
  }
}
