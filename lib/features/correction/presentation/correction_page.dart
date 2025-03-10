import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:correction_auto/core/di/injection.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/domain/entities/reference.dart';
import 'package:correction_auto/domain/entities/correction.dart';
import 'package:correction_auto/features/camera/presentation/camera_page.dart';
import 'package:correction_auto/features/correction/presentation/bloc/correction_bloc.dart';
import 'package:correction_auto/features/ocr/presentation/ocr_verification_page.dart';
import 'package:correction_auto/features/correction/presentation/widgets/answer_evaluation_card.dart';
import 'package:correction_auto/features/correction/presentation/correction_result_page.dart';
import 'package:correction_auto/presentation/widgets/empty_state_widget.dart';

class CorrectionPage extends StatefulWidget {
  final Reference? selectedReference;

  const CorrectionPage({
    super.key,
    this.selectedReference,
  });

  @override
  State<CorrectionPage> createState() => _CorrectionPageState();
}

class _CorrectionPageState extends State<CorrectionPage> {
  Reference? _selectedReference;
  final TextEditingController _studentNameController = TextEditingController();
  
  // Mock data for references - in a real app, this would come from a repository
  final List<Reference> _mockReferences = [
    Reference.create(
      title: 'Évaluation Science - Chapitre 3',
      subject: 'Science',
      description: 'Évaluation sur les écosystèmes',
      questions: [
        Question.create(
          number: 1,
          text: 'Définissez ce qu\'est un écosystème.',
          expectedAnswer: 'Un écosystème est un ensemble formé par une communauté d\'êtres vivants en interaction avec son environnement.',
          points: 3,
          keywords: ['ensemble', 'communauté', 'êtres vivants', 'interaction', 'environnement'],
        ),
        Question.create(
          number: 2,
          text: 'Citez trois exemples d\'écosystèmes.',
          expectedAnswer: 'Forêt, océan, désert, lac, prairie, mangrove, récif corallien, toundra.',
          points: 3,
          keywords: ['forêt', 'océan', 'désert', 'lac', 'prairie', 'mangrove', 'récif', 'toundra'],
        ),
      ],
    ),
    Reference.create(
      title: 'Contrôle Math - Algèbre',
      subject: 'Mathématiques',
      description: 'Évaluation sur les équations du second degré',
      questions: [
        Question.create(
          number: 1,
          text: 'Résolvez l\'équation x² - 4x + 3 = 0',
          expectedAnswer: 'Pour résoudre x² - 4x + 3 = 0, on calcule le discriminant : Δ = b² - 4ac = 16 - 12 = 4. Les solutions sont x₁ = (4 + 2) / 2 = 3 et x₂ = (4 - 2) / 2 = 1. L\'équation a donc deux solutions : x₁ = 3 et x₂ = 1.',
          points: 4,
          keywords: ['discriminant', 'solutions', 'équation'],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedReference = widget.selectedReference;
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CorrectionBloc>(),
      child: BlocConsumer<CorrectionBloc, CorrectionState>(
        listener: (context, state) {
          if (state is CorrectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is CorrectionSaved) {
            // Navigate to result page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CorrectionResultPage(
                  correction: state.correction,
                  reference: state.reference,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Nouvelle correction'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CorrectionState state) {
    if (state is CorrectionInitial) {
      return _buildReferencePicker(context);
    } else if (state is CorrectionInProgress) {
      return _buildCaptureStep(context, state);
    } else if (state is CorrectionAnalyzing) {
      return _buildAnalyzingState();
    } else if (state is CorrectionAnalyzed) {
      return _buildCorrectionReview(context, state);
    } else {
      return const EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'État inattendu',
        message: 'Une erreur est survenue lors du processus de correction.',
      );
    }
  }

  Widget _buildReferencePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          color: AppColors.primary.withOpacity(0.1),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Étape 1 : Choisissez un sujet de référence',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sélectionnez le sujet d\'évaluation qui servira de référence pour la correction automatique.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        
        // References list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: _mockReferences.map((reference) {
              final isSelected = _selectedReference?.id == reference.id;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: isSelected
                      ? BorderSide(color: AppColors.primary, width: 2)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedReference = reference;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reference.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected
                                          ? AppColors.primary
                                          : null,
                                    ),
                                  ),
                                  Text(
                                    reference.subject,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reference.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${reference.questions.length} question${reference.questions.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.grade_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${reference.totalPoints} points',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        // Bottom controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _studentNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'élève',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _selectedReference != null &&
                        _studentNameController.text.isNotEmpty
                    ? () {
                        context.read<CorrectionBloc>().add(
                              StartCorrection(
                                reference: _selectedReference!,
                                studentName: _studentNameController.text,
                              ),
                            );
                      }
                    : null,
                icon: const Icon(Icons.navigate_next),
                label: const Text('Continuer'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureStep(BuildContext context, CorrectionInProgress state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          color: AppColors.primary.withOpacity(0.1),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Étape 2 : Capturez la copie de l\'élève',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prenez une photo de la copie de ${state.studentName} pour la correction.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        
        // Capture image button
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                Text(
                  'Aucune image capturée',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Utilisez l\'appareil photo pour scanner la copie',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<File>(
                      MaterialPageRoute(
                        builder: (_) => const CameraPage(),
                      ),
                    );
                    
                    if (result != null && mounted) {
                      final segments = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OCRVerificationPage(
                            imageFile: result,
                            onConfirm: (segments) {
                              Navigator.of(context).pop(segments);
                            },
                          ),
                        ),
                      );
                      
                      if (mounted) {
                        context.read<CorrectionBloc>().add(
                              AnalyzeStudentPaper(result),
                            );
                      }
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Prendre une photo'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            'Analyse en cours...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nous analysons les réponses de l\'élève.\nCela peut prendre quelques instants.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionReview(BuildContext context, CorrectionAnalyzed state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          color: AppColors.primary.withOpacity(0.1),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Étape 3 : Vérifiez la correction',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vérifiez et ajustez si nécessaire la correction automatique.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        
        // Summary
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.correction.studentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    state.reference.title,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(state.correction.score),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${state.correction.score.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Correction list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.correction.answers.length,
            itemBuilder: (context, index) {
              final answer = state.correction.answers[index];
              final question = state.reference.questions.firstWhereOrNull(
                (q) => q.id == answer.questionId,
              );
              
              if (question == null) {
                return const SizedBox();
              }
              
              return AnswerEvaluationCard(
                answer: answer,
                question: question,
                onPointsChanged: (answerId, points) {
                  context.read<CorrectionBloc>().add(
                        UpdateAnswerEvaluation(
                          answerId: answerId,
                          earnedPoints: points,
                        ),
                      );
                },
                onFeedbackChanged: (answerId, feedback) {
                  context.read<CorrectionBloc>().add(
                        UpdateAnswerEvaluation(
                          answerId: answerId,
                          earnedPoints: answer.earnedPoints,
                          feedback: feedback,
                        ),
                      );
                },
              );
            },
          ),
        ),
        
        // Bottom actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<CorrectionBloc>().add(SaveCorrection());
            },
            icon: const Icon(Icons.save),
            label: const Text('Enregistrer la correction'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
