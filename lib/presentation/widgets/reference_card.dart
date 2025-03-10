import 'package:flutter/material.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ReferenceCard extends StatelessWidget {
  final String title;
  final String subject;
  final int questionsCount;
  final DateTime lastUpdate;
  final VoidCallback onTap;

  const ReferenceCard({
    super.key,
    required this.title,
    required this.subject,
    required this.questionsCount,
    required this.lastUpdate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon based on subject
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForSubject(subject),
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subject,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Menu button
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                    onSelected: (value) {
                      // Handle menu actions
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.content_copy_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Dupliquer'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Additional information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.question_answer_outlined,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$questionsCount question${questionsCount > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Màj. ${dateFormatter.format(lastUpdate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathématiques':
      case 'maths':
        return Icons.functions;
      case 'science':
      case 'sciences':
      case 'physique':
      case 'chimie':
        return Icons.science;
      case 'histoire':
      case 'géographie':
        return Icons.public;
      case 'français':
      case 'littérature':
        return Icons.menu_book;
      case 'anglais':
      case 'espagnol':
      case 'allemand':
      case 'italien':
        return Icons.translate;
      case 'art':
      case 'musique':
        return Icons.palette;
      case 'sport':
      case 'eps':
        return Icons.sports;
      default:
        return Icons.school;
    }
  }
}
