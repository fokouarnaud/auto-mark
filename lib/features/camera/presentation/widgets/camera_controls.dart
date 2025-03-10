import 'package:flutter/material.dart';
import 'package:correction_auto/core/theme/app_colors.dart';

class CameraControls extends StatelessWidget {
  final bool isFlashEnabled;
  final double zoomLevel;
  final double minZoom;
  final double maxZoom;
  final bool isDocumentDetectionEnabled;
  final VoidCallback onCapturePressed;
  final VoidCallback onFlashToggle;
  final ValueChanged<double> onZoomChanged;
  final VoidCallback onSwitchCamera;
  final VoidCallback onDocumentDetectionToggle;

  const CameraControls({
    super.key,
    required this.isFlashEnabled,
    required this.zoomLevel,
    required this.minZoom,
    required this.maxZoom,
    required this.isDocumentDetectionEnabled,
    required this.onCapturePressed,
    required this.onFlashToggle,
    required this.onZoomChanged,
    required this.onSwitchCamera,
    required this.onDocumentDetectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.zoom_out, color: Colors.white, size: 20),
                Expanded(
                  child: Slider(
                    value: zoomLevel,
                    min: minZoom,
                    max: maxZoom,
                    divisions: ((maxZoom - minZoom) * 10).toInt(),
                    label: zoomLevel.toStringAsFixed(1) + 'x',
                    onChanged: onZoomChanged,
                    activeColor: AppColors.primary,
                  ),
                ),
                const Icon(Icons.zoom_in, color: Colors.white, size: 20),
              ],
            ),
          ),
          
          // Camera controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Flash toggle
              IconButton(
                onPressed: onFlashToggle,
                icon: Icon(
                  isFlashEnabled ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              // Capture button
              GestureDetector(
                onTap: onCapturePressed,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Camera switch button
              IconButton(
                onPressed: onSwitchCamera,
                icon: const Icon(
                  Icons.cameraswitch,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          
          // Document detection toggle
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: onDocumentDetectionToggle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDocumentDetectionEnabled
                        ? Icons.crop_free
                        : Icons.crop_free_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDocumentDetectionEnabled
                        ? 'Détection auto activée'
                        : 'Détection auto désactivée',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
