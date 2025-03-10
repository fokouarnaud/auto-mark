import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DocumentOverlay extends StatefulWidget {
  final List<Offset>? corners;
  final Function(List<Offset>? corners) onCornersDetected;

  const DocumentOverlay({
    super.key,
    this.corners,
    required this.onCornersDetected,
  });

  @override
  State<DocumentOverlay> createState() => _DocumentOverlayState();
}

class _DocumentOverlayState extends State<DocumentOverlay> {
  Timer? _detectionTimer;
  List<Offset>? _lastDetectedCorners;
  
  // Mock detection - In a real app, this would use ML Kit or OpenCV
  void _simulateDocumentDetection(Size size) {
    // Cancel any existing timer to avoid multiple detections
    _detectionTimer?.cancel();
    
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // In a real implementation, this would analyze the camera feed
      // and detect document corners using computer vision
      
      // For now, let's simulate by generating random corners that look like a document
      if (_lastDetectedCorners == null || _shouldUpdateCorners()) {
        final double width = size.width;
        final double height = size.height;
        
        // Create a slightly tilted rectangle as a document
        final double tiltFactor = 0.05 * (DateTime.now().microsecond % 10 - 5);
        
        final corners = [
          Offset(0.15 * width, 0.25 * height + tiltFactor * height),  // Top left
          Offset(0.85 * width, 0.25 * height - tiltFactor * height),  // Top right
          Offset(0.85 * width, 0.75 * height + tiltFactor * height),  // Bottom right
          Offset(0.15 * width, 0.75 * height - tiltFactor * height),  // Bottom left
        ];
        
        _lastDetectedCorners = corners;
        widget.onCornersDetected(corners);
      }
    });
  }
  
  bool _shouldUpdateCorners() {
    // In a real app, this would determine if the detected corners have changed significantly
    return DateTime.now().second % 3 == 0;  // Randomly update occasionally
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size size = MediaQuery.of(context).size;
      _simulateDocumentDetection(size);
    });
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: DocumentBoundaryPainter(corners: widget.corners),
    );
  }
}

class DocumentBoundaryPainter extends CustomPainter {
  final List<Offset>? corners;
  
  DocumentBoundaryPainter({this.corners});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (corners == null || corners!.length != 4) {
      _drawDefaultBoundary(canvas, size);
      return;
    }
    
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    // Draw the boundary connecting the corners
    final path = Path()
      ..moveTo(corners![0].dx, corners![0].dy)
      ..lineTo(corners![1].dx, corners![1].dy)
      ..lineTo(corners![2].dx, corners![2].dy)
      ..lineTo(corners![3].dx, corners![3].dy)
      ..close();
    
    canvas.drawPath(path, paint);
    
    // Draw corner handles
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    for (final corner in corners!) {
      canvas.drawCircle(corner, 10, handlePaint);
      canvas.drawCircle(corner, 10, paint..strokeWidth = 2.0);
    }
  }
  
  void _drawDefaultBoundary(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    
    final double aspectRatio = 210 / 297;  // A4 paper aspect ratio
    double rectHeight = height * 0.7;
    double rectWidth = rectHeight * aspectRatio;
    
    if (rectWidth > width * 0.8) {
      rectWidth = width * 0.8;
      rectHeight = rectWidth / aspectRatio;
    }
    
    final double left = (width - rectWidth) / 2;
    final double top = (height - rectHeight) / 2;
    
    final Rect rect = Rect.fromLTWH(left, top, rectWidth, rectHeight);
    
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    // Draw dashed lines for the boundary
    final dashLength = 10.0;
    final dashSpace = 5.0;
    final dashPath = Path();
    
    double startX = rect.left;
    while (startX < rect.right) {
      dashPath.moveTo(startX, rect.top);
      dashPath.lineTo(startX + dashLength, rect.top);
      startX += dashLength + dashSpace;
    }
    
    double startY = rect.top;
    while (startY < rect.bottom) {
      dashPath.moveTo(rect.right, startY);
      dashPath.lineTo(rect.right, startY + dashLength);
      startY += dashLength + dashSpace;
    }
    
    startX = rect.right;
    while (startX > rect.left) {
      dashPath.moveTo(startX, rect.bottom);
      dashPath.lineTo(startX - dashLength, rect.bottom);
      startX -= dashLength + dashSpace;
    }
    
    startY = rect.bottom;
    while (startY > rect.top) {
      dashPath.moveTo(rect.left, startY);
      dashPath.lineTo(rect.left, startY - dashLength);
      startY -= dashLength + dashSpace;
    }
    
    canvas.drawPath(dashPath, paint);
    
    // Draw text prompting user to position document
    final textStyle = ui.TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      shadows: [
        ui.Shadow(color: Colors.black, blurRadius: 4),
      ],
    );
    
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.center,
    );
    
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText('Positionnez le document dans le cadre');
    
    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: width * 0.8));
    
    canvas.drawParagraph(
      paragraph,
      Offset((width - paragraph.maxIntrinsicWidth) / 2, rect.bottom + 20),
    );
  }
  
  @override
  bool shouldRepaint(DocumentBoundaryPainter oldDelegate) {
    return oldDelegate.corners != corners;
  }
}
