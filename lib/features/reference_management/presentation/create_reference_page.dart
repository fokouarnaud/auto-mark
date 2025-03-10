import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/domain/entities/reference.dart';
import 'package:correction_auto/features/camera/presentation/camera_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateReferencePage extends StatefulWidget {
  const CreateReferencePage({super.key});

  @override
  State<CreateReferencePage> createState() => _CreateReferencePageState();
}

class _CreateReferencePageState extends State<CreateReferencePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  File? _referenceImage;
  
  // Liste des questions
  final List<QuestionFormItem> _questions = [];
  
  // Étape actuelle dans le processus de création
  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
    // Ajouter une question vide par défaut
    _addQuestion();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    
    // Disposer tous les contrôleurs des questions
    for (final question in _questions) {
      question.dispose();
    }
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une référence'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            // Valider l'étape actuelle avant de continuer
            if (_currentStep == 0 && !_validateInfoStep()) {
              return;
            }
            
            if (_currentStep == 1 && !_validateQuestionsStep()) {
              return;
            }
            
            setState(() {
              _currentStep++;
            });
          } else {
            // Dernière étape, créer la référence
            _saveReference();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          } else {
            _confirmExit(context);
          }
        },
        onStepTapped: (step) {
          // Valider l'étape actuelle avant de permettre de naviguer
          if (_currentStep == 0 && step > 0 && !_validateInfoStep()) {
            return;
          }
          
          if (_currentStep == 1 && step > 1 && !_validateQuestionsStep()) {
            return;
          }
          
          setState(() {
            _currentStep = step;
          });
        },
        steps: [
          Step(
            title: const Text('Informations'),
            content: _buildInfoStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Questions'),
            content: _buildQuestionsStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Aperçu'),
            content: _buildPreviewStep(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titre',
              hintText: 'Ex: Évaluation Sciences - Chapitre 3',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un titre';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Matière',
              hintText: 'Ex: Sciences, Mathématiques, Français...',
              prefixIcon: Icon(Icons.subject),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une matière';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Description du sujet d\'évaluation',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Document de référence (optionnel)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickReferenceImage(),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _referenceImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _referenceImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Cliquez pour ajouter une image',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
          if (_referenceImage != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _referenceImage = null;
                });
              },
              icon: const Icon(Icons.delete),
              label: const Text('Supprimer l\'image'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildQuestionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Liste des questions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._questions.map((question) => _buildQuestionItem(question)).toList(),
        if (_questions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Aucune question ajoutée',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildQuestionItem(QuestionFormItem question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Question ${question.numberController.text.isEmpty ? "?" : question.numberController.text}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeQuestion(question),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                // Number input
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: question.numberController,
                    decoration: const InputDecoration(
                      labelText: 'N°',
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Points input
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: question.pointsController,
                    decoration: const InputDecoration(
                      labelText: 'Points',
                      suffixText: 'pts',
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: question.textController,
              decoration: const InputDecoration(
                labelText: 'Texte de la question',
                hintText: 'Saisissez la question...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: question.expectedAnswerController,
              decoration: const InputDecoration(
                labelText: 'Réponse attendue',
                hintText: 'Saisissez la réponse attendue...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Mots-clés importants (séparés par des virgules)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: question.keywordsController,
              decoration: const InputDecoration(
                hintText: 'Ex: mot1, mot2, mot3...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreviewStep() {
    final int totalPoints = _questions.fold(
      0,
      (sum, q) => sum + (int.tryParse(q.pointsController.text) ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleController.text.isEmpty ? 'Sans titre' : _titleController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _subjectController.text.isEmpty ? 'Sans matière' : _subjectController.text,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                if (_descriptionController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_descriptionController.text),
                ],
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
                      '${_questions.length} question${_questions.length > 1 ? 's' : ''}',
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
                      '$totalPoints points',
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
        const SizedBox(height: 16),
        Text(
          'Questions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ..._questions.map((question) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  question.numberController.text.isEmpty
                      ? '?'
                      : question.numberController.text,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                question.textController.text.isEmpty
                    ? 'Question sans texte'
                    : question.textController.text,
              ),
              subtitle: Text(
                'Réponse: ${question.expectedAnswerController.text.isEmpty ? 'Non définie' : question.expectedAnswerController.text.length > 30 ? '${question.expectedAnswerController.text.substring(0, 30)}...' : question.expectedAnswerController.text}',
              ),
              trailing: Text(
                '${question.pointsController.text.isEmpty ? '0' : question.pointsController.text} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        if (_referenceImage != null) ...[
          Text(
            'Image de référence',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _referenceImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
  
  void _addQuestion() {
    setState(() {
      // Numéroter automatiquement la question
      final newNumber = _questions.length + 1;
      final question = QuestionFormItem(
        numberController: TextEditingController(text: newNumber.toString()),
        textController: TextEditingController(),
        expectedAnswerController: TextEditingController(),
        pointsController: TextEditingController(text: '1'),
        keywordsController: TextEditingController(),
      );
      _questions.add(question);
    });
  }
  
  void _removeQuestion(QuestionFormItem question) {
    setState(() {
      _questions.remove(question);
      
      // Mettre à jour les numéros des questions restantes
      for (int i = 0; i < _questions.length; i++) {
        _questions[i].numberController.text = (i + 1).toString();
      }
    });
  }
  
  Future<void> _pickReferenceImage() async {
    // Afficher une boîte de dialogue pour choisir entre caméra et galerie
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une image'),
        content: const Text('Choisissez la source de l\'image'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('camera'),
            child: const Text('Appareil photo'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('gallery'),
            child: const Text('Galerie'),
          ),
        ],
      ),
    );
    
    if (choice == null) return;
    
    try {
      if (choice == 'camera') {
        // Utiliser la page de caméra personnalisée
        final result = await Navigator.of(context).push<File>(
          MaterialPageRoute(
            builder: (_) => const CameraPage(),
          ),
        );
        
        if (result != null && mounted) {
          setState(() {
            _referenceImage = result;
          });
        }
      } else {
        // Utiliser la galerie
        final imagePicker = ImagePicker();
        final pickedFile = await imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        
        if (pickedFile != null) {
          setState(() {
            _referenceImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
  
  bool _validateInfoStep() {
    return _formKey.currentState?.validate() ?? false;
  }
  
  bool _validateQuestionsStep() {
    // Vérifier que toutes les questions ont au moins un numéro, un texte et une réponse attendue
    bool isValid = true;
    
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une question')),
      );
      return false;
    }
    
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      
      if (question.numberController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Numéro manquant pour la question ${i + 1}')),
        );
        isValid = false;
        break;
      }
      
      if (question.textController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Texte manquant pour la question ${i + 1}')),
        );
        isValid = false;
        break;
      }
      
      if (question.expectedAnswerController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Réponse attendue manquante pour la question ${i + 1}')),
        );
        isValid = false;
        break;
      }
      
      if (question.pointsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Points manquants pour la question ${i + 1}')),
        );
        isValid = false;
        break;
      }
    }
    
    return isValid;
  }
  
  void _saveReference() {
    // Créer les objets Question à partir des formulaires
    final List<Question> questions = _questions.map((questionForm) {
      // Extraire les mots-clés (séparés par des virgules)
      final keywordsText = questionForm.keywordsController.text;
      final List<String> keywords = keywordsText.isEmpty
          ? []
          : keywordsText.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
      
      return Question.create(
        number: int.parse(questionForm.numberController.text),
        text: questionForm.textController.text,
        expectedAnswer: questionForm.expectedAnswerController.text,
        points: int.parse(questionForm.pointsController.text),
        keywords: keywords,
      );
    }).toList();
    
    // Créer la référence
    final reference = Reference.create(
      title: _titleController.text,
      subject: _subjectController.text,
      description: _descriptionController.text,
      questions: questions,
      imagePath: _referenceImage?.path,
    );
    
    // Dans une vraie application, on sauvegarderait la référence dans un repository
    
    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Référence créée avec succès')),
    );
    
    // Retourner à l'écran précédent
    Navigator.of(context).pop();
  }
  
  Future<void> _confirmExit(BuildContext context) async {
    // Demander confirmation avant de quitter si des données ont été saisies
    bool hasData = _titleController.text.isNotEmpty ||
        _subjectController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _referenceImage != null ||
        _questions.any((q) => 
            q.textController.text.isNotEmpty || 
            q.expectedAnswerController.text.isNotEmpty || 
            q.keywordsController.text.isNotEmpty);
    
    if (!hasData) {
      Navigator.of(context).pop();
      return;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter sans enregistrer ?'),
        content: const Text(
          'Vous avez des modifications non enregistrées. Êtes-vous sûr de vouloir quitter ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      Navigator.of(context).pop();
    }
  }
  
  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide - Création de référence'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Qu\'est-ce qu\'une référence ?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Une référence est un modèle de correction qui définit les questions et les réponses attendues pour un sujet d\'évaluation. Elle servira de base pour la correction automatique des copies des élèves.',
              ),
              SizedBox(height: 16),
              Text(
                'Étape 1 : Informations',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Renseignez le titre, la matière et une description du sujet. Vous pouvez également ajouter une image du sujet original.',
              ),
              SizedBox(height: 16),
              Text(
                'Étape 2 : Questions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Ajoutez chaque question du sujet en précisant son numéro, son texte, la réponse attendue et le nombre de points. Vous pouvez également ajouter des mots-clés importants qui doivent apparaître dans la réponse de l\'élève.',
              ),
              SizedBox(height: 16),
              Text(
                'Étape 3 : Aperçu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Vérifiez que toutes les informations sont correctes avant de créer la référence. Vous pourrez ensuite utiliser cette référence pour corriger automatiquement les copies des élèves.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

/// Classe utilitaire pour gérer les contrôleurs de formulaire d'une question
class QuestionFormItem {
  final TextEditingController numberController;
  final TextEditingController textController;
  final TextEditingController expectedAnswerController;
  final TextEditingController pointsController;
  final TextEditingController keywordsController;
  
  QuestionFormItem({
    required this.numberController,
    required this.textController,
    required this.expectedAnswerController,
    required this.pointsController,
    required this.keywordsController,
  });
  
  void dispose() {
    numberController.dispose();
    textController.dispose();
    expectedAnswerController.dispose();
    pointsController.dispose();
    keywordsController.dispose();
  }
}
