import 'dart:io';
import 'package:flutter/material.dart';
import 'package:correction_auto/core/theme/app_colors.dart';

class ImagePreviewPage extends StatefulWidget {
  final File imageFile;
  final VoidCallback onRetake;
  final Function(File imageFile) onConfirm;

  const ImagePreviewPage({
    super.key,
    required this.imageFile,
    required this.onRetake,
    required this.onConfirm,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  bool _isProcessing = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu de l\'image'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onRetake,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.file(
                  widget.imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }
  
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: widget.onRetake,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Reprendre'),
          ),
          ElevatedButton.icon(
            onPressed: _isProcessing 
                ? null
                : () {
                    setState(() {
                      _isProcessing = true;
                    });
                    
                    // Here you can add additional post-processing if needed
                    // before calling the onConfirm callback
                    
                    Future.delayed(const Duration(milliseconds: 500), () {
                      widget.onConfirm(widget.imageFile);
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check),
            label: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
