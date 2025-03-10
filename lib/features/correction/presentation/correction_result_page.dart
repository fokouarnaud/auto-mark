import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/domain/entities/correction.dart';
import 'package:correction_auto/domain/entities/reference.dart';

class CorrectionResultPage extends StatelessWidget {
  final Correction correction;
  final Reference reference;

  const CorrectionResultPage({
    super.key,
    required this.correction,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    final int totalEarnedPoints = correction.answers.fold(
      0,
      (sum, answer) => sum + answer.earnedPoints,
    );
    final int totalPossiblePoints = correction.answers.fold(
      0,
      (sum, answer) => sum + answer.maxPoints,
    );
    final double percentageScore = totalPossiblePoints > 0
        ? (totalEarnedPoints / totalPossiblePoints) * 100
        : 0;
    
    // Find weakest and strongest answers
    AnswerEvaluation? weakestAnswer;
    AnswerEvaluation? strongestAnswer;
    
    if (correction.answers.isNotEmpty) {
      weakestAnswer = correction.answers.reduce((a, b) {
        final scoreA = a.earnedPoints / a.maxPoints;
        final scoreB = b.earnedPoints / b.maxPoints;
        return scoreA < scoreB ? a : b;
      });
      
      strongestAnswer = correction.answers.reduce((a, b) {
        final scoreA = a.earnedPoints / a.maxPoints;
        final scoreB = b.earnedPoints / b.maxPoints;
        return scoreA > scoreB ? a : b;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats de correction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareResults(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score card
            _buildScoreCard(
              context,
              percentageScore,
              totalEarnedPoints,
              totalPossiblePoints,
            ),
            
            // Student info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Élève',
                            correction.studentName,
                            Icons.person,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            'Sujet',
                            reference.title,
                            Icons.description,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            'Matière',
                            reference.subject,
                            Icons.category,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            'Date',
                            _formatDate(correction.correctionDate),
                            Icons.calendar_today,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Strengths and weaknesses
            if (weakestAnswer != null && strongestAnswer != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Points forts et points faibles',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStrengthWeaknessCard(
                            context,
                            true,
                            strongestAnswer,
                            reference.questions.firstWhere(
                              (q) => q.id == strongestAnswer?.questionId,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStrengthWeaknessCard(
                            context,
                            false,
                            weakestAnswer,
                            reference.questions.firstWhere(
                              (q) => q.id == weakestAnswer?.questionId,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Answers summary
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détail des réponses',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: correction.answers.length,
                    itemBuilder: (context, index) {
                      final answer = correction.answers[index];
                      final question = reference.questions.firstWhere(
                        (q) => q.id == answer.questionId,
                      );
                      return _buildAnswerSummaryCard(
                        context,
                        answer,
                        question,
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Comments
            if (correction.comments != null && correction.comments!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commentaires généraux',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(correction.comments!),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Bottom padding
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _exportToPdf(context);
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exporter en PDF'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Terminer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    double percentageScore,
    int earnedPoints,
    int totalPoints,
  ) {
    Color scoreColor;
    String scoreLabel;
    
    if (percentageScore >= 80) {
      scoreColor = Colors.green;
      scoreLabel = 'Très bien';
    } else if (percentageScore >= 70) {
      scoreColor = Colors.green.shade600;
      scoreLabel = 'Bien';
    } else if (percentageScore >= 60) {
      scoreColor = Colors.orange;
      scoreLabel = 'Assez bien';
    } else if (percentageScore >= 50) {
      scoreColor = Colors.orange.shade700;
      scoreLabel = 'Moyen';
    } else {
      scoreColor = Colors.red;
      scoreLabel = 'Insuffisant';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Note',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${percentageScore.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    scoreLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: scoreColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$earnedPoints',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 2,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          Text(
                            '$totalPoints',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthWeaknessCard(
    BuildContext context,
    bool isStrength,
    AnswerEvaluation answer,
    Question question,
  ) {
    return Card(
      color: isStrength
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isStrength ? Icons.thumb_up : Icons.thumb_down,
                  color: isStrength ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isStrength ? 'Point fort' : 'Point faible',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isStrength ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${question.number}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              question.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${answer.earnedPoints}/${answer.maxPoints}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isStrength ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'points',
                  style: TextStyle(
                    fontSize: 12,
                    color: isStrength ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSummaryCard(
    BuildContext context,
    AnswerEvaluation answer,
    Question question,
  ) {
    final double percentScore = answer.earnedPoints / answer.maxPoints;
    final Color scoreColor = percentScore >= 0.8
        ? Colors.green
        : percentScore >= 0.5
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${question.number}',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (answer.feedback != null && answer.feedback!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      answer.feedback!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                '${answer.earnedPoints}/${answer.maxPoints}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format: dd/mm/yyyy HH:MM
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _shareResults(BuildContext context) {
    // Build text summary
    final StringBuffer textSummary = StringBuffer();
    textSummary.writeln('Correction de ${correction.studentName}');
    textSummary.writeln('Sujet: ${reference.title}');
    textSummary.writeln('Matière: ${reference.subject}');
    textSummary.writeln('Date: ${_formatDate(correction.correctionDate)}');
    textSummary.writeln('');
    
    // Calculate score
    final int totalEarnedPoints = correction.answers.fold(
      0,
      (sum, answer) => sum + answer.earnedPoints,
    );
    final int totalPossiblePoints = correction.answers.fold(
      0,
      (sum, answer) => sum + answer.maxPoints,
    );
    final double percentageScore = totalPossiblePoints > 0
        ? (totalEarnedPoints / totalPossiblePoints) * 100
        : 0;
    
    textSummary.writeln('Score: ${percentageScore.toStringAsFixed(1)}%');
    textSummary.writeln('Points: $totalEarnedPoints/$totalPossiblePoints');
    textSummary.writeln('');
    
    textSummary.writeln('Détail des réponses:');
    for (final answer in correction.answers) {
      final question = reference.questions.firstWhere(
        (q) => q.id == answer.questionId,
      );
      textSummary.writeln('Question ${question.number}: ${answer.earnedPoints}/${answer.maxPoints} points');
      if (answer.feedback != null && answer.feedback!.isNotEmpty) {
        textSummary.writeln('  Commentaire: ${answer.feedback}');
      }
    }
    
    if (correction.comments != null && correction.comments!.isNotEmpty) {
      textSummary.writeln('');
      textSummary.writeln('Commentaires généraux:');
      textSummary.writeln(correction.comments);
    }
    
    Share.share(textSummary.toString());
  }

  void _exportToPdf(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export PDF en cours de développement'),
      ),
    );
  }
}
