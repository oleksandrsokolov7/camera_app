import 'dart:io';
import 'package:image_picker/image_picker.dart';

class OverlayService {
  File? overlayImage;

  Future<void> pickOverlayImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      overlayImage = File(pickedFile.path);
    }
  }
}
