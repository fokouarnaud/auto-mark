import 'package:injectable/injectable.dart';

/// Interface pour le service d'analyse textuelle
abstract class TextAnalyzer {
  /// Calcule la similarité entre deux textes en utilisant une approche hybride
  /// Retourne une valeur entre 0 et 1, où 1 est une correspondance parfaite
  Future<TextAnalysisResult> analyzeSimilarity(String referenceText, String studentText);
  
  /// Extrait les mots-clés importants d'un texte
  List<String> extractKeywords(String text, {int maxKeywords = 10});
  
  /// Calcule les métriques TF-IDF pour un ensemble de textes
  Map<String, double> calculateTfIdf(List<String> documents, String targetDocument);
  
  /// Calcule la distance de Levenshtein entre deux chaînes
  int calculateLevenshteinDistance(String source, String target);
  
  /// Calcule l'indice de similarité de Jaccard entre deux ensembles de mots
  double calculateJaccardSimilarity(Set<String> set1, Set<String> set2);
  
  /// Calcule un score de similarité sémantique à l'aide du modèle Universal Sentence Encoder Lite
  /// Cette méthode peut être plus lente car elle utilise un modèle d'apprentissage profond
  Future<double> calculateSemanticSimilarity(String text1, String text2);
}

/// Résultat d'une analyse de texte
class TextAnalysisResult {
  /// Score de similarité global (0-1)
  final double similarityScore;
  
  /// Score de similarité lexicale (Jaccard) (0-1)
  final double lexicalSimilarity;
  
  /// Score de similarité d'édition (1 - distance de Levenshtein normalisée) (0-1)
  final double editSimilarity;
  
  /// Score de similarité sémantique (0-1)
  final double semanticSimilarity;
  
  /// Score de similarité basé sur TF-IDF (0-1)
  final double keywordSimilarity;
  
  /// Niveau de confiance dans le résultat (0-1)
  final double confidence;
  
  /// Mots-clés trouvés dans les deux textes
  final List<String> matchedKeywords;
  
  /// Mots-clés manquants (présents dans la référence mais absents dans la réponse)
  final List<String> missingKeywords;

  TextAnalysisResult({
    required this.similarityScore,
    required this.lexicalSimilarity,
    required this.editSimilarity,
    required this.semanticSimilarity,
    required this.keywordSimilarity,
    required this.confidence,
    required this.matchedKeywords,
    required this.missingKeywords,
  });
}
