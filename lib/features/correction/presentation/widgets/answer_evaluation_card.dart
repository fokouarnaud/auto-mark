import 'package:flutter/material.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/domain/entities/correction.dart';
import 'package:correction_auto/domain/entities/reference.dart';

class AnswerEvaluationCard extends StatefulWidget {
  final AnswerEvaluation answer;
  final Question question;
  final Function(String answerId, int points) onPointsChanged;
  final Function(String answerId, String feedback) onFeedbackChanged;

  const AnswerEvaluationCard({
    super.key,
    required this.answer,
    required this.question,
    required this.onPointsChanged,
    required this.onFeedbackChanged,
  });

  @override
  State<AnswerEvaluationCard> createState() => _AnswerEvaluationCardState();
}

class _AnswerEvaluationCardState extends State<AnswerEvaluationCard> {
  late int _currentPoints;
  late String _currentFeedback;
  bool _isExpanded = false;
  late TextEditingController _feedbackController;

  @override
  void initState() {
    super.initState();
    _currentPoints = widget.answer.earnedPoints;
    _currentFeedback = widget.answer.feedback ?? '';
    _feedbackController = TextEditingController(text: _currentFeedback);
  }

  @override
  void didUpdateWidget(AnswerEvaluationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.answer.earnedPoints != widget.answer.earnedPoints) {
      _currentPoints = widget.answer.earnedPoints;
    }
    if (oldWidget.answer.feedback != widget.answer.feedback) {
      _currentFeedback = widget.answer.feedback ?? '';
      _feedbackController.text = _currentFeedback;
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double percentScore = widget.answer.earnedPoints / widget.answer.maxPoints;
    Color scoreColor;
    
    if (percentScore >= 0.8) {
      scoreColor = Colors.green;
    } else if (percentScore >= 0.5) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with question number and points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Question ${widget.question.number}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.answer.earnedPoints}/${widget.answer.maxPoints} pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  widget.answer.confidence >= 0.7
                      ? Icons.check_circle
                      : widget.answer.confidence >= 0.4
                          ? Icons.help_outline
                          : Icons.error_outline,
                  size: 20,
                  color: widget.answer.confidence >= 0.7
                      ? Colors.green
                      : widget.answer.confidence >= 0.4
                          ? Colors.orange
                          : Colors.red,
                ),
              ],
            ),
          ),
          
          // Question text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(widget.question.text),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Réponse attendue:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(widget.question.expectedAnswer),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Réponse de l\'élève:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.answer.studentAnswer.isEmpty
                      ? 'Aucune réponse'
                      : widget.answer.studentAnswer,
                  style: TextStyle(
                    fontStyle: widget.answer.studentAnswer.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: widget.answer.studentAnswer.isEmpty
                        ? Colors.grey
                        : null,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          const Divider(height: 1),
          
          // Evaluation controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Points:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Slider(
                        value: _currentPoints.toDouble(),
                        min: 0,
                        max: widget.question.points.toDouble(),
                        divisions: widget.question.points,
                        label: '$_currentPoints',
                        onChanged: (value) {
                          setState(() {
                            _currentPoints = value.round();
                          });
                        },
                        onChangeEnd: (value) {
                          widget.onPointsChanged(
                            widget.answer.id,
                            value.round(),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$_currentPoints',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Confidence indicator
                Row(
                  children: [
                    const Text(
                      'Confiance:',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: widget.answer.confidence,
                        backgroundColor: Colors.grey[300],
                        color: widget.answer.confidence >= 0.7
                            ? Colors.green
                            : widget.answer.confidence >= 0.4
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(widget.answer.confidence * 100).round()}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                
                // Expandable section for feedback
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Row(
                    children: [
                      const Text(
                        'Commentaire',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    onChanged: (value) {
                      _currentFeedback = value;
                    },
                    onEditingComplete: () {
                      widget.onFeedbackChanged(
                        widget.answer.id,
                        _currentFeedback,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        widget.onFeedbackChanged(
                          widget.answer.id,
                          _feedbackController.text,
                        );
                        FocusScope.of(context).unfocus();
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
