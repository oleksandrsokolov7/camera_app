import 'package:camera_app/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions(); // Запрашиваем только нужные разрешения

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  final cameraStatus = await Permission.camera.request();
  final microphoneStatus = await Permission.microphone.request();

  if (cameraStatus.isDenied || microphoneStatus.isDenied) {
    print("Необходимо предоставить разрешения для камеры и микрофона");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CameraScreen(),
    );
  }
}
