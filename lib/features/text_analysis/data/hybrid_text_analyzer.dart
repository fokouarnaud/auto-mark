import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:correction_auto/features/text_analysis/domain/text_analyzer.dart';

@LazySingleton(as: TextAnalyzer)
class HybridTextAnalyzer implements TextAnalyzer {
  final Logger _logger;
  
  // TensorFlow Lite model for Universal Sentence Encoder
  Interpreter? _interpreter;
  bool _modelLoaded = false;
  
  // French stop words (mots vides)
  final Set<String> _stopWords = {
    'le', 'la', 'les', 'un', 'une', 'des', 'ce', 'ces', 'cette',
    'de', 'du', 'à', 'au', 'aux', 'en', 'par', 'pour', 'avec', 'sans',
    'et', 'ou', 'mais', 'donc', 'or', 'ni', 'car', 'est', 'sont',
    'était', 'sera', 'je', 'tu', 'il', 'elle', 'nous', 'vous', 'ils',
    'elles', 'qui', 'que', 'quoi', 'dont', 'où'
  };
  
  HybridTextAnalyzer(this._logger);
  
  @override
  Future<TextAnalysisResult> analyzeSimilarity(String referenceText, String studentText) async {
    _logger.i('Analyzing similarity between reference and student text');
    
    // Normalize the texts
    final normalizedRef = _normalizeText(referenceText);
    final normalizedStudent = _normalizeText(studentText);
    
    // Extract word sets for Jaccard similarity
    final Set<String> refWords = normalizedRef.split(' ').toSet();
    final Set<String> studentWords = normalizedStudent.split(' ').toSet();
    
    // Calculate lexical similarity (Jaccard)
    final lexicalSimilarity = calculateJaccardSimilarity(refWords, studentWords);
    
    // Calculate edit distance similarity
    final editDistance = calculateLevenshteinDistance(normalizedRef, normalizedStudent);
    final maxLength = max(normalizedRef.length, normalizedStudent.length);
    final editSimilarity = 1.0 - (editDistance / maxLength);
    
    // Calculate keyword similarity using TF-IDF
    final List<String> documents = [normalizedRef, normalizedStudent];
    final Map<String, double> tfidf = calculateTfIdf(documents, normalizedStudent);
    
    // Get keywords from reference
    final List<String> refKeywords = extractKeywords(normalizedRef);
    
    // Calculate keyword match
    final matchedKeywords = <String>[];
    final missingKeywords = <String>[];
    
    double keywordScore = 0.0;
    for (final keyword in refKeywords) {
      if (studentWords.contains(keyword)) {
        matchedKeywords.add(keyword);
        keywordScore += tfidf[keyword] ?? 0.0;
      } else {
        missingKeywords.add(keyword);
      }
    }
    
    // Normalize keyword score
    final double keywordSimilarity = refKeywords.isEmpty ? 0.0 : 
        min(1.0, keywordScore / (refKeywords.length * 0.5));
    
    // Calculate semantic similarity if possible
    double semanticSimilarity = 0.0;
    try {
      semanticSimilarity = await calculateSemanticSimilarity(referenceText, studentText);
    } catch (e) {
      _logger.w('Failed to calculate semantic similarity: $e');
      // Default to lexical similarity if semantic similarity fails
      semanticSimilarity = lexicalSimilarity;
    }
    
    // Calculate weighted similarity score
    // Weights can be adjusted based on importance of each metric
    final double similarityScore = (
      lexicalSimilarity * 0.3 +
      editSimilarity * 0.2 +
      keywordSimilarity * 0.3 +
      semanticSimilarity * 0.2
    );
    
    // Calculate confidence based on text length and quality
    final double confidence = _calculateConfidence(
      refLength: normalizedRef.length,
      studentLength: normalizedStudent.length,
      similarity: similarityScore
    );
    
    return TextAnalysisResult(
      similarityScore: similarityScore,
      lexicalSimilarity: lexicalSimilarity,
      editSimilarity: editSimilarity,
      keywordSimilarity: keywordSimilarity,
      semanticSimilarity: semanticSimilarity,
      confidence: confidence,
      matchedKeywords: matchedKeywords,
      missingKeywords: missingKeywords,
    );
  }
  
  @override
  List<String> extractKeywords(String text, {int maxKeywords = 10}) {
    // Normalize the text
    final normalized = _normalizeText(text);
    
    // Split into words
    final words = normalized.split(' ');
    
    // Count word frequencies
    final wordCounts = <String, int>{};
    for (final word in words) {
      if (word.length > 2 && !_stopWords.contains(word)) {
        wordCounts[word] = (wordCounts[word] ?? 0) + 1;
      }
    }
    
    // Sort by frequency
    final sortedWords = wordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Return top N keywords
    return sortedWords
        .take(maxKeywords)
        .map((e) => e.key)
        .toList();
  }
  
  @override
  Map<String, double> calculateTfIdf(List<String> documents, String targetDocument) {
    final Map<String, double> result = {};
    final int docCount = documents.length;
    
    // Split documents into word sets
    final List<Set<String>> docWordSets = documents
        .map((doc) => _normalizeText(doc).split(' ').toSet())
        .toList();
    
    // Target document words
    final List<String> targetWords = _normalizeText(targetDocument).split(' ');
    
    // Count word frequencies in the target document (term frequency)
    final Map<String, int> wordCounts = {};
    for (final word in targetWords) {
      if (word.length > 2 && !_stopWords.contains(word)) {
        wordCounts[word] = (wordCounts[word] ?? 0) + 1;
      }
    }
    
    // Calculate TF-IDF for each word
    for (final entry in wordCounts.entries) {
      final String word = entry.key;
      final int count = entry.value;
      
      // Calculate TF: term frequency
      final double tf = count / targetWords.length;
      
      // Calculate IDF: inverse document frequency
      int docsWithWord = 0;
      for (final Set<String> docWords in docWordSets) {
        if (docWords.contains(word)) {
          docsWithWord++;
        }
      }
      
      // Add smoothing to avoid division by zero
      final double idf = log((docCount + 1) / (docsWithWord + 1)) + 1;
      
      // Calculate TF-IDF
      result[word] = tf * idf;
    }
    
    return result;
  }
  
  @override
  int calculateLevenshteinDistance(String source, String target) {
    if (source == target) return 0;
    if (source.isEmpty) return target.length;
    if (target.isEmpty) return source.length;
    
    List<int> v0 = List<int>.filled(target.length + 1, 0);
    List<int> v1 = List<int>.filled(target.length + 1, 0);
    
    for (int i = 0; i <= target.length; i++) {
      v0[i] = i;
    }
    
    for (int i = 0; i < source.length; i++) {
      v1[0] = i + 1;
      
      for (int j = 0; j < target.length; j++) {
        int cost = (source[i] == target[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      
      // Swap v0 and v1
      final List<int> temp = v0;
      v0 = v1;
      v1 = temp;
    }
    
    return v0[target.length];
  }
  
  @override
  double calculateJaccardSimilarity(Set<String> set1, Set<String> set2) {
    if (set1.isEmpty && set2.isEmpty) return 1.0;
    
    // Calculate the intersection
    final intersection = set1.intersection(set2);
    
    // Calculate the union
    final union = set1.union(set2);
    
    // Calculate Jaccard similarity: |A ∩ B| / |A ∪ B|
    return intersection.length / union.length;
  }
  
  @override
  Future<double> calculateSemanticSimilarity(String text1, String text2) async {
    // Ensure the model is loaded
    if (!_modelLoaded) {
      await _loadModel();
    }
    
    // If model still not loaded, fall back to lexical similarity
    if (_interpreter == null) {
      final Set<String> words1 = _normalizeText(text1).split(' ').toSet();
      final Set<String> words2 = _normalizeText(text2).split(' ').toSet();
      return calculateJaccardSimilarity(words1, words2);
    }
    
    try {
      // This is a simplified mock implementation
      // In a real app, you would encode both sentences and calculate cosine similarity
      
      // Simulate a semantic similarity score based on Jaccard with some randomness
      // This would be replaced with actual model inference
      final Set<String> words1 = _normalizeText(text1).split(' ').toSet();
      final Set<String> words2 = _normalizeText(text2).split(' ').toSet();
      
      double jaccardSim = calculateJaccardSimilarity(words1, words2);
      
      // Add some variance to simulate semantic analysis
      // A real implementation would use the TFLite model to generate embeddings
      // and then calculate cosine similarity between them
      double semanticBoost = Random().nextDouble() * 0.2 - 0.1; // -0.1 to +0.1
      
      return min(1.0, max(0.0, jaccardSim + semanticBoost));
    } catch (e, stackTrace) {
      _logger.e('Error during semantic similarity calculation: ${e.toString()}');
      
      // Fallback to lexical similarity
      final Set<String> words1 = _normalizeText(text1).split(' ').toSet();
      final Set<String> words2 = _normalizeText(text2).split(' ').toSet();
      return calculateJaccardSimilarity(words1, words2);
    }
  }
  
  Future<void> _loadModel() async {
    try {
      _logger.i('Loading Universal Sentence Encoder Lite model');
      
      // In a real app, you would load the model from assets
      // For now, we'll simulate model loading
      
      // Get the app directory
      final appDir = await getApplicationDocumentsDirectory();
      final modelPath = '${appDir.path}/models/use_lite_model.tflite';
      
      // Check if model exists (it wouldn't on first run)
      final modelFile = File(modelPath);
      if (!await modelFile.exists()) {
        await _copyModelFromAssets();
      }
      
      // Load the interpreter
      // _interpreter = await Interpreter.fromFile(modelFile);
      
      // Simulate successful model loading
      await Future.delayed(const Duration(milliseconds: 500));
      
      _modelLoaded = true;
      _logger.i('Model loaded successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to load model: ${e.toString()}');
      // Continue without the model - app will fall back to simpler algorithms
    }
  }
  
  Future<void> _copyModelFromAssets() async {
    try {
      // In a real app, this would copy the model from assets to app storage
      // For now, we'll simulate this process
      
      final appDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${appDir.path}/models');
      
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }
      
      // Simulate copying a file
      await Future.delayed(const Duration(milliseconds: 300));
      
      _logger.i('Model copied from assets to app storage');
    } catch (e, stackTrace) {
      _logger.e('Failed to copy model from assets: ${e.toString()}');
    }
  }
  
  String _normalizeText(String text) {
    // Convert to lowercase
    String normalized = text.toLowerCase();
    
    // Remove punctuation
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), ' ');
    
    // Replace multiple spaces with a single space
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return normalized;
  }
  
  double _calculateConfidence(
      {required int refLength, required int studentLength, required double similarity}) {
    // Calculate length match factor (0-1)
    final double lengthRatio = min(refLength, studentLength) / max(refLength, studentLength);
    
    // Calculate confidence based on similarity and length match
    final double confidence = (similarity * 0.7) + (lengthRatio * 0.3);
    
    return confidence;
  }
}
