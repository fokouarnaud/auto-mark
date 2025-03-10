import 'package:flutter/material.dart';
import 'package:correction_auto/core/theme/app_colors.dart';

class QuestionModel {
  final int id;
  final String text;
  final int points;
  final String expectedAnswer;

  QuestionModel({
    required this.id,
    required this.text,
    required this.points,
    required this.expectedAnswer,
  });

  QuestionModel copyWith({
    int? id,
    String? text,
    int? points,
    String? expectedAnswer,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      points: points ?? this.points,
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
    );
  }
}

class CreateReferencePage extends StatefulWidget {
  const CreateReferencePage({super.key});

  @override
  State<CreateReferencePage> createState() => _CreateReferencePageState();
}

class _CreateReferencePageState extends State<CreateReferencePage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form fields
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  String _selectedSubject = '';
  final List<QuestionModel> _questions = [];

  final List<String> _subjects = [
    'Mathématiques',
    'Français',
    'Sciences',
    'Histoire-Géographie',
    'Anglais',
    'Physique-Chimie',
    'SVT',
    'Philosophie',
    'Autre',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep < 2) {
      // Validate current step before proceeding
      if (_currentStep == 0 && !_validateBasicInfo()) {
        return;
      }
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateBasicInfo() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un titre'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    
    if (_selectedSubject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une matière'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    
    return true;
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionModel(
        id: _questions.length + 1,
        text: '',
        points: 1,
        expectedAnswer: '',
      ));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      // Renumber questions
      for (int i = 0; i < _questions.length; i++) {
        _questions[i] = _questions[i].copyWith(id: i + 1);
      }
    });
  }

  void _saveReference() {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins une question'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Save reference (would use a BLoC or UseCase in real app)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Référence créée avec succès'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une référence'),
      ),
      body: Column(
        children: [
          // Stepper
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _StepIndicator(
                  step: 1,
                  title: 'Informations',
                  isActive: _currentStep >= 0,
                  isCompleted: _currentStep > 0,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 0
                        ? AppColors.primary
                        : AppColors.outlineLight,
                  ),
                ),
                _StepIndicator(
                  step: 2,
                  title: 'Questions',
                  isActive: _currentStep >= 1,
                  isCompleted: _currentStep > 1,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 1
                        ? AppColors.primary
                        : AppColors.outlineLight,
                  ),
                ),
                _StepIndicator(
                  step: 3,
                  title: 'Finaliser',
                  isActive: _currentStep >= 2,
                  isCompleted: false,
                ),
              ],
            ),
          ),
          // Page content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 1: Basic information
                  _BasicInformationStep(
                    titleController: _titleController,
                    subjects: _subjects,
                    selectedSubject: _selectedSubject,
                    onSubjectChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                    },
                  ),
                  
                  // Step 2: Questions
                  _QuestionsStep(
                    questions: _questions,
                    onAddQuestion: _addQuestion,
                    onRemoveQuestion: _removeQuestion,
                  ),
                  
                  // Step 3: Preview and confirmation
                  _PreviewStep(
                    title: _titleController.text,
                    subject: _selectedSubject,
                    questions: _questions,
                  ),
                ],
              ),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: _goToPreviousStep,
                    child: const Text('Précédent'),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _currentStep < 2 ? _goToNextStep : _saveReference,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_currentStep < 2 ? 'Suivant' : 'Créer la référence'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final String title;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.step,
    required this.title,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.outlineLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? Theme.of(context).textTheme.bodyMedium?.color
                : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _BasicInformationStep extends StatelessWidget {
  final TextEditingController titleController;
  final List<String> subjects;
  final String selectedSubject;
  final Function(String) onSubjectChanged;

  const _BasicInformationStep({
    required this.titleController,
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Text(
            'Informations de base',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ces informations aideront à organiser vos références.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          
          // Title field
          Text(
            'Titre de l\'évaluation',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Ex: Contrôle de mathématiques - Chapitre 3',
              prefixIcon: const Icon(Icons.title),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez saisir un titre';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Subject field
          Text(
            'Matière',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSubject.isEmpty ? null : selectedSubject,
                hint: const Text('Sélectionnez une matière'),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                items: subjects.map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    onSubjectChanged(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Tips card
          Card(
            color: AppColors.infoContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conseil',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Donnez un titre descriptif à votre référence pour la retrouver facilement.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
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

class _QuestionsStep extends StatelessWidget {
  final List<QuestionModel> questions;
  final VoidCallback onAddQuestion;
  final Function(int) onRemoveQuestion;

  const _QuestionsStep({
    required this.questions,
    required this.onAddQuestion,
    required this.onRemoveQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Questions et réponses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajoutez les questions et les réponses attendues.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
        
        // Question list
        Expanded(
          child: questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.question_answer_outlined,
                        size: 64,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune question ajoutée',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez des questions pour continuer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: onAddQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une question'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length + 1, // +1 for the add button
                  itemBuilder: (context, index) {
                    if (index == questions.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: onAddQuestion,
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter une question'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return _QuestionCard(
                      question: questions[index],
                      onRemove: () => onRemoveQuestion(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final VoidCallback onRemove;

  const _QuestionCard({
    required this.question,
    required this.onRemove,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late int _points;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.text);
    _answerController = TextEditingController(text: widget.question.expectedAnswer);
    _points = widget.question.points;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.question.id.toString(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Question ${widget.question.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Text(
                'Énoncé de la question',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  hintText: 'Saisissez la question...',
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 16),
              Text(
                'Réponse attendue',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _answerController,
                decoration: InputDecoration(
                  hintText: 'Saisissez la réponse attendue...',
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 5,
                minLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Points :',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _points > 1
                              ? () {
                                  setState(() {
                                    _points--;
                                  });
                                }
                              : null,
                        ),
                        Text(
                          _points.toString(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _points++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewStep extends StatelessWidget {
  final String title;
  final String subject;
  final List<QuestionModel> questions;

  const _PreviewStep({
    required this.title,
    required this.subject,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total points
    int totalPoints = questions.fold(0, (sum, q) => sum + q.points);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vérification finale',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vérifiez les informations avant de créer la référence.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          
          // Summary card
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Récapitulatif',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Titre', value: title),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Matière', value: subject),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Questions', 
                    value: '${questions.length} question${questions.length > 1 ? 's' : ''}',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Points totaux', 
                    value: '$totalPoints point${totalPoints > 1 ? 's' : ''}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Questions preview
          Text(
            'Questions et réponses',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (questions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Aucune question ajoutée. Retournez à l\'étape précédente pour ajouter des questions.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  question.id.toString(),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
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
                                    question.text.isEmpty
                                        ? 'Question ${question.id} (sans énoncé)'
                                        : question.text,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Réponse attendue:',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    question.expectedAnswer.isEmpty
                                        ? '(Aucune réponse renseignée)'
                                        : question.expectedAnswer,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text('${question.points} pt${question.points > 1 ? 's' : ''}'),
                              backgroundColor: AppColors.primaryContainer,
                              labelStyle: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
