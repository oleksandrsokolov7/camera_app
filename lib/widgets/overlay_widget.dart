import 'package:flutter/material.dart';
import '../overlay_service.dart';

class OverlayWidget extends StatelessWidget {
  final OverlayService overlayService;

  const OverlayWidget({super.key, required this.overlayService});

  @override
  Widget build(BuildContext context) {
    return overlayService.overlayImage != null
        ? Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child:
                  Image.file(overlayService.overlayImage!, fit: BoxFit.cover),
            ),
          )
        : const SizedBox.shrink();
  }
}
