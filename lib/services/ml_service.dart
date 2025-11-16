import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/text_preprocessor.dart';

// Import TFLite wrapper that handles conditional imports
import 'tflite_wrapper.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:path_provider/path_provider.dart'
if (dart.library.html) 'path_provider_stub.dart' as path_provider;

/// Result type for ML operations
sealed class MLResult<T> {
  const MLResult();
}

final class MLSuccess<T> extends MLResult<T> {
  final T value;
  const MLSuccess(this.value);
}

final class MLFailure<T> extends MLResult<T> {
  final String message;
  const MLFailure(this.message);
}

/// ML Service for scam detection using TensorFlow Lite
class MLService {
  static final MLService instance = MLService._internal();
  factory MLService() => instance;
  MLService._internal();

  List<String> _labels = [];
  bool _isInitialized = false;
  bool _modelLoaded = false;

  bool get isInitialized => _isInitialized;
  bool get modelLoaded => _modelLoaded;

  /// Initialize the ML service
  Future<MLResult<void>> initialize() async {
    try {
      if (kIsWeb) {
        _isInitialized = true;
        return const MLSuccess(null);
      }

      final modelResult = await _loadModel();
      modelResult.when(
        success: (_) => _modelLoaded = true,
        failure: (_) => _modelLoaded = false,
      );

      await _loadLabels();
      _isInitialized = true;
      
      return const MLSuccess(null);
    } catch (e) {
      _isInitialized = true; // Allow fallback
      return MLFailure('Error initializing ML Service: $e');
    }
  }

  /// Load the TensorFlow Lite model
  Future<MLResult<void>> _loadModel() async {
    if (kIsWeb) {
      return const MLFailure('ML models not supported on web');
    }

    return await _withErrorHandling(() async {
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      final modelPath = '${appDir.path}/scam_model.tflite';
      final modelFile = io.File(modelPath);

      // Copy model from assets if it doesn't exist
      if (!await modelFile.exists()) {
        final byteData = await rootBundle.load('assets/models/scam_model.tflite');
        await modelFile.writeAsBytes(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
        );
      }

      // Load the model using TFLiteWrapper
      final result = await TFLiteWrapper.loadModel(
        model: modelPath,
        labels: 'assets/labels.txt',
        isAsset: false,
        numThreads: 2,
      );

      if (result == null) {
        return const MLFailure('Failed to load model: null response');
      }

      return const MLSuccess(null);
    }, 'Failed to load ML model');
  }

  /// Load labels from assets
  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .map((l) => l.trim())
          .toList();
    } catch (e) {
      _labels = ['Legitimate', 'Scam'];
    }
  }

  /// Detect if a message is a scam
  Future<ScamDetectionResult> detectScam(String message) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (kIsWeb || !_modelLoaded) {
      return _fallbackDetection(message);
    }

    final result = await _detectWithModel(message);
    return result.fold(
      onFailure: (failure) {
        print('ML detection failed: ${failure.message}');
        return _fallbackDetection(message);
      },
      onSuccess: (success) => success.value,
    );
  }

  /// Detect scam using the ML model
  Future<MLResult<ScamDetectionResult>> _detectWithModel(String message) async {
    return await _withErrorHandling(() async {
      // Preprocess the message
      final preprocessed = TextPreprocessor.preprocess(message);
      final input = TextPreprocessor.textToTensor(preprocessed);

      // Convert to flat list and then to bytes
      final flatList = input.expand((x) => x).toList();
      final float32List = Float32List.fromList(flatList);
      final inputBytes = float32List.buffer.asUint8List();

      // Run inference
      final output = await TFLiteWrapper.runModelOnBinary(
        binary: inputBytes,
        numResults: 2,
        threshold: 0.1,
      );

      // Validate output
      if (output == null || output.isEmpty) {
        return const MLFailure('Model returned null or empty output');
      }

      if (output[0] is! List) {
        return const MLFailure('Invalid output format from model');
      }

      final List<dynamic> probabilities = output[0] as List<dynamic>;

      if (probabilities.length < 2) {
        return const MLFailure('Insufficient output probabilities');
      }

      // Extract scam confidence
      final scamConfidence = (probabilities[1] as num).toDouble();
      final isScam = scamConfidence > 0.5;

      return MLSuccess(
        ScamDetectionResult(
          isScam: isScam,
          confidence: scamConfidence.clamp(0.0, 1.0),
          message: message,
        ),
      );
    }, 'Error in ML detection');
  }

  /// Fallback detection using rule-based approach
  ScamDetectionResult _fallbackDetection(String message) {
    final lowerMessage = message.toLowerCase();

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
      RegExp(r'http[s]?://[\S]+'),
      RegExp(r'\d{4,}'),
      RegExp(r'[A-Z]{3,}'),
    ];

    // Calculate scam score
    final keywordMatches = scamKeywords
        .where((keyword) => lowerMessage.contains(keyword))
        .length;
    
    final patternMatches = suspiciousPatterns
        .where((pattern) => pattern.hasMatch(message))
        .length;

    final scamScore = (keywordMatches * 2) + patternMatches;
    final confidence = (scamScore / 10).clamp(0.0, 1.0);
    final isScam = confidence > 0.3;

    return ScamDetectionResult(
      isScam: isScam,
      confidence: confidence,
      message: message,
    );
  }

  /// Helper method for error handling
  Future<MLResult<T>> _withErrorHandling<T>(
    Future<MLResult<T>> Function() operation,
    String errorMessage,
  ) async {
    try {
      return await operation();
    } catch (e) {
      return MLFailure('$errorMessage: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (!kIsWeb && _modelLoaded) {
      try {
        await TFLiteWrapper.close();
      } catch (e) {
        print('Error disposing ML service: $e');
      }
    }
  }
}

/// Extension to add fold method to MLResult
extension MLResultExtension<T> on MLResult<T> {
  R fold<R>({
    required R Function(MLFailure<T>) onFailure,
    required R Function(MLSuccess<T>) onSuccess,
  }) {
    return switch (this) {
      MLSuccess<T>(:final value) => onSuccess(MLSuccess(value)),
      MLFailure<T>(:final message) => onFailure(MLFailure(message)),
    };
  }

  void when({
    required void Function(MLSuccess<T>) success,
    required void Function(MLFailure<T>) failure,
  }) {
    switch (this) {
      case MLSuccess<T>(:final value):
        success(MLSuccess(value));
      case MLFailure<T>(:final message):
        failure(MLFailure(message));
    }
  }
}

/// Result of scam detection
class ScamDetectionResult {
  final bool isScam;
  final double confidence;
  final String message;

  ScamDetectionResult({
    required this.isScam,
    required this.confidence,
    required this.message,
  });

  @override
  String toString() {
    return 'ScamDetectionResult(isScam: $isScam, confidence: $confidence, message: $message)';
  }
}
