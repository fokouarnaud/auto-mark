import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/features/camera/presentation/widgets/camera_controls.dart';
import 'package:correction_auto/features/camera/presentation/widgets/document_overlay.dart';
import 'package:correction_auto/features/camera/presentation/image_preview_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  bool _isCapturing = false;
  bool _isFrontCamera = false;
  bool _isFlashEnabled = false;
  double _zoomLevel = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  Timer? _autoFocusTimer;

  // Document detection state
  bool _isDocumentDetectionEnabled = true;
  List<Offset>? _documentCorners;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoFocusTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize the camera
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(cameraController.description);
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.request();
    setState(() {
      _isPermissionGranted = status.isGranted;
    });
    
    if (_isPermissionGranted) {
      _initializeCameraLookup();
    }
  }

  Future<void> _initializeCameraLookup() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final camera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );
        _initializeCamera(camera);
      }
    } on CameraException catch (e) {
      _showCameraError('Error: ${e.code}\n${e.description}');
    }
  }

  Future<void> _initializeCamera(CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = cameraController;

    try {
      await cameraController.initialize();
      
      // Set up camera features
      if (cameraController.value.isInitialized) {
        _minZoom = await cameraController.getMinZoomLevel();
        _maxZoom = await cameraController.getMaxZoomLevel();
        _startPeriodicAutoFocus();
      }
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = cameraController.value.isInitialized;
        });
      }
    } on CameraException catch (e) {
      _showCameraError('Error: ${e.code}\n${e.description}');
    }
  }

  void _startPeriodicAutoFocus() {
    _autoFocusTimer?.cancel();
    _autoFocusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.setFocusMode(FocusMode.auto);
      }
    });
  }

  Future<void> _toggleCameraDirection() async {
    if (_cameras == null || _cameras!.length < 2) return;
    
    // Cancel the old timer before switching camera
    _autoFocusTimer?.cancel();
    
    _isFrontCamera = !_isFrontCamera;
    final CameraDescription newCamera = _cameras!.firstWhere(
      (camera) => _isFrontCamera 
          ? camera.lensDirection == CameraLensDirection.front
          : camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras!.first,
    );
    
    await _initializeCamera(newCamera);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    _isFlashEnabled = !_isFlashEnabled;
    await _controller!.setFlashMode(
      _isFlashEnabled ? FlashMode.torch : FlashMode.off,
    );
    
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    // Ensure zoom is within bounds
    zoom = zoom.clamp(_minZoom, _maxZoom);
    
    await _controller!.setZoomLevel(zoom);
    
    if (mounted) {
      setState(() {
        _zoomLevel = zoom;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;
    
    setState(() {
      _isCapturing = true;
    });
    
    try {
      // Capture the image
      final XFile rawImage = await _controller!.takePicture();
      
      // Process the image (crop, enhance, etc.)
      final File processedImage = await _processImage(File(rawImage.path));
      
      if (mounted) {
        // Navigate to preview screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreviewPage(
              imageFile: processedImage,
              onRetake: () => Navigator.of(context).pop(),
              onConfirm: (File imageFile) {
                // Return to previous screen with the processed image
                Navigator.of(context).pop(imageFile);
              },
            ),
          ),
        );
      }
    } on CameraException catch (e) {
      _showCameraError('Error: ${e.code}\n${e.description}');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<File> _processImage(File imageFile) async {
    // Load the image
    final List<int> imageBytes = await imageFile.readAsBytes();
    final Uint8List uint8list = Uint8List.fromList(imageBytes);
    final img.Image? originalImage = img.decodeImage(uint8list);
    
    if (originalImage == null) return imageFile;
    
    // Apply processing steps
    img.Image processedImage = originalImage;
    
    // 1. Auto-crop if document corners are detected
    if (_documentCorners != null && _isDocumentDetectionEnabled) {
      // Convert the corner points to image coordinates
      final List<img.Point> corners = _documentCorners!.map((offset) {
        return img.Point(
          (offset.dx * originalImage.width).round(),
          (offset.dy * originalImage.height).round(),
        );
      }).toList();
      
      // Apply perspective correction
      processedImage = img.copyCrop(
        originalImage,
        x: corners[0].x.toInt(),
        y: corners[0].y.toInt(),
        width: (corners[1].x - corners[0].x).toInt(),
        height: (corners[2].y - corners[0].y).toInt(),
      );
    }
    
    // 2. Apply contrast enhancement
    processedImage = img.adjustColor(
      processedImage,
      contrast: 1.2,
      brightness: 0.0,
      saturation: 0.0,
      exposure: 0.1,
    );
    
    // 3. Optional: Apply adaptive binarization for better OCR
    // processedImage = img.binarize(processedImage, threshold: 128);
    
    // Save the processed image
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = '${tempDir.path}/processed_image.jpg';
    final File processedFile = File(tempPath);
    await processedFile.writeAsBytes(img.encodeJpg(processedImage, quality: 90));
    
    return processedFile;
  }

  void _toggleDocumentDetection() {
    setState(() {
      _isDocumentDetectionEnabled = !_isDocumentDetectionEnabled;
    });
  }

  void _updateDocumentCorners(List<Offset>? corners) {
    if (!mounted) return;
    setState(() {
      _documentCorners = corners;
    });
  }

  void _showCameraError(String errorText) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText)),
      );
    }
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Camera preview
        CameraPreview(_controller!),
        
        // Document detection overlay
        if (_isDocumentDetectionEnabled)
          DocumentOverlay(
            corners: _documentCorners,
            onCornersDetected: _updateDocumentCorners,
          ),
        
        // Camera controls
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: CameraControls(
            isFlashEnabled: _isFlashEnabled,
            zoomLevel: _zoomLevel,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            isDocumentDetectionEnabled: _isDocumentDetectionEnabled,
            onCapturePressed: _captureImage,
            onFlashToggle: _toggleFlash,
            onZoomChanged: _setZoomLevel,
            onSwitchCamera: _toggleCameraDirection,
            onDocumentDetectionToggle: _toggleDocumentDetection,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.no_photography_outlined,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Accès à la caméra refusé',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nous avons besoin d\'accéder à votre caméra pour numériser des documents.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _checkPermissions(),
            child: const Text('Autoriser l\'accès'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un document'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isPermissionGranted ? _buildCameraPreview() : _buildPermissionDenied(),
    );
  }
}
