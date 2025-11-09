import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../utils/text_preprocessor.dart';

class MLService {
  static final MLService instance = MLService._internal();
  factory MLService() => instance;
  MLService._internal();

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      // Load model
      final modelPath = await _loadModel();
      if (modelPath.isNotEmpty) {
        _interpreter = Interpreter.fromFile(File(modelPath));
        print('ML Model loaded successfully');
      } else {
        print('No ML model found, using rule-based fallback');
      }
      
      // Load labels
      await _loadLabels();
      
      _isInitialized = true;
      print('ML Service initialized successfully');
    } catch (e) {
      print('Error initializing ML Service: $e');
      // For demo purposes, we'll use a rule-based fallback
      _isInitialized = true;
    }
  }

  Future<String> _loadModel() async {
    try {
      // Try to load from assets
      final byteData = await rootBundle.load('assets/models/scam_model.tflite');
      final bytes = byteData.buffer.asUint8List();
      
      final appDir = await getApplicationDocumentsDirectory();
      final modelFile = File('${appDir.path}/scam_model.tflite');
      await modelFile.writeAsBytes(bytes);
      
      return modelFile.path;
    } catch (e) {
      print('Model file not found, using fallback detection');
      // Return empty path - will use fallback
      return '';
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n').where((l) => l.isNotEmpty).toList();
    } catch (e) {
      print('Labels file not found, using default labels');
      _labels = ['Legitimate', 'Scam'];
    }
  }

  Future<ScamDetectionResult> detectScam(String message) async {
    if (!_isInitialized) {
      await initialize();
    }

    // If model is not available, use rule-based fallback
    if (_interpreter == null) {
      return _fallbackDetection(message);
    }

    try {
      // Preprocess text
      final preprocessed = TextPreprocessor.preprocess(message);
      
      // Convert to tensor (simplified - actual implementation depends on model)
      // This is a placeholder - you'll need to adapt based on your model's input format
      final input = TextPreprocessor.textToTensor(preprocessed);
      
      // Run inference
      final output = List.filled(2, 0.0).reshape([1, 2]);
      _interpreter!.run(input, output);
      
      // Get prediction
      final confidence = output[0][1]; // Assuming index 1 is scam
      final isScam = confidence > 0.5;
      
      return ScamDetectionResult(
        isScam: isScam,
        confidence: confidence,
        message: message,
      );
    } catch (e) {
      print('Error in ML detection: $e');
      return _fallbackDetection(message);
    }
  }

  ScamDetectionResult _fallbackDetection(String message) {
    // Rule-based fallback detection
    final lowerMessage = message.toLowerCase();
    
    // Common scam indicators
    final scamKeywords = [
      'urgent',
      'click here',
      'verify account',
      'suspended',
      'expired',
      'prize winner',
      'congratulations',
      'claim now',
      'limited time',
      'act now',
      'click link',
      'update payment',
      'verify identity',
      'account locked',
      'unusual activity',
      'immediate action',
      'free money',
      'lottery winner',
    ];
    
    final suspiciousPatterns = [
      RegExp(r'http[s]?://[^\s]+'),
      RegExp(r'\d{4,}'),
      RegExp(r'[A-Z]{3,}'),
    ];
    
    int scamScore = 0;
    
    // Check keywords
    for (var keyword in scamKeywords) {
      if (lowerMessage.contains(keyword)) {
        scamScore += 2;
      }
    }
    
    // Check patterns
    for (var pattern in suspiciousPatterns) {
      if (pattern.hasMatch(message)) {
        scamScore += 1;
      }
    }
    
    // Calculate confidence
    final confidence = (scamScore / 10).clamp(0.0, 1.0);
    final isScam = confidence > 0.3;
    
    return ScamDetectionResult(
      isScam: isScam,
      confidence: confidence,
      message: message,
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

class ScamDetectionResult {
  final bool isScam;
  final double confidence;
  final String message;

  ScamDetectionResult({
    required this.isScam,
    required this.confidence,
    required this.message,
  });
}

