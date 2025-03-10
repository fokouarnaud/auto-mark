import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:correction_auto/core/di/injection.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/features/ocr/domain/ocr_service.dart';
import 'package:correction_auto/features/ocr/presentation/bloc/ocr_bloc.dart';

class OCRVerificationPage extends StatelessWidget {
  final File imageFile;
  final Function(List<DocumentSegment> segments) onConfirm;

  const OCRVerificationPage({
    super.key,
    required this.imageFile,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OCRBloc>()..add(ProcessImageOCR(imageFile)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vérification OCR'),
        ),
        body: BlocConsumer<OCRBloc, OCRState>(
          listener: (context, state) {
            if (state is OCRError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is OCRLoading) {
              return _buildLoadingState();
            } else if (state is OCRLoaded) {
              return _buildLoadedState(context, state);
            } else if (state is OCRError) {
              return _buildErrorState(context, state);
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analyse du document en cours...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, OCRLoaded state) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: 16),
                  Text(
                    'Texte détecté',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  _buildSegmentsList(context, state.segments),
                ],
              ),
            ),
          ),
        ),
        _buildActionButtons(context, state),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSegmentsList(BuildContext context, List<DocumentSegment> segments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final segment = segments[index];
        return _buildSegmentItem(context, segment, index);
      },
    );
  }

  Widget _buildSegmentItem(BuildContext context, DocumentSegment segment, int index) {
    Color textColor;
    String typeLabel;
    IconData icon;

    switch (segment.type) {
      case SegmentType.questionNumber:
        textColor = AppColors.primary;
        typeLabel = 'Numéro de question';
        icon = Icons.tag;
        break;
      case SegmentType.questionText:
        textColor = AppColors.secondary;
        typeLabel = 'Question';
        icon = Icons.help_outline;
        break;
      case SegmentType.answerText:
        textColor = Colors.green;
        typeLabel = 'Réponse';
        icon = Icons.question_answer_outlined;
        break;
      case SegmentType.unknown:
      default:
        textColor = Colors.grey;
        typeLabel = 'Inconnu';
        icon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: Icon(icon, color: textColor),
        title: Text(
          segment.text.length > 50 
              ? '${segment.text.substring(0, 50)}...' 
              : segment.text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          'Type: $typeLabel${segment.questionNumber != null ? ' | Question ${segment.questionNumber}' : ''}',
          style: TextStyle(fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Texte complet:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  initialValue: segment.text,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(8),
                  ),
                  onChanged: (value) {
                    context.read<OCRBloc>().add(UpdateSegmentText(index, value));
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<SegmentType>(
                        value: segment.type,
                        decoration: InputDecoration(
                          labelText: 'Type de segment',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: SegmentType.values.map((type) {
                          String label;
                          switch (type) {
                            case SegmentType.questionNumber:
                              label = 'Numéro de question';
                              break;
                            case SegmentType.questionText:
                              label = 'Question';
                              break;
                            case SegmentType.answerText:
                              label = 'Réponse';
                              break;
                            case SegmentType.unknown:
                            default:
                              label = 'Inconnu';
                          }
                          return DropdownMenuItem(
                            value: type,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<OCRBloc>().add(UpdateSegmentType(index, value));
                          }
                        },
                      ),
                    ),
                    if (segment.type == SegmentType.questionNumber || 
                        segment.type == SegmentType.questionText ||
                        segment.type == SegmentType.answerText) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: segment.questionNumber?.toString() ?? '',
                          decoration: InputDecoration(
                            labelText: 'N°',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final int? questionNumber = int.tryParse(value);
                            context.read<OCRBloc>().add(UpdateSegmentQuestionNumber(index, questionNumber));
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OCRLoaded state) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Retour'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              onConfirm(state.segments);
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirmer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, OCRError state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de reconnaissance',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<OCRBloc>().add(ProcessImageOCR(imageFile));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retour à la caméra'),
          ),
        ],
      ),
    );
  }
}
