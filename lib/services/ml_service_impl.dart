// Mobile implementation of ML service using tflite_plus
// This file is used when compiling for mobile platforms (not web)

import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_plus/tflite_plus.dart';

/// Mobile implementation of TFLite operations using tflite_plus package
class TFLiteImpl {
  static Interpreter? _interpreter;

  /// Load a TensorFlow Lite model
  static Future<String?> loadModel({
    required String model,
    String? labels,
    int numThreads = 1,
    bool isAsset = true,
    bool useGpuDelegate = false,
    bool useNnApi = false,
  }) async {
    try {
      // Close existing interpreter if any
      if (_interpreter != null) {
        _interpreter!.close();
        _interpreter = null;
      }

      // Create interpreter options if needed
      InterpreterOptions? options;
      if (numThreads > 1 || useGpuDelegate || useNnApi) {
        options = InterpreterOptions();
        if (numThreads > 1) {
          options.threads = numThreads;
        }
        // Note: GPU and NNAPI delegates would need additional setup
        // For now, we'll use basic options
      }

      // Load the model
      if (isAsset) {
        _interpreter = await Interpreter.fromAsset(model, options: options);
      } else {
        final modelFile = File(model);
        if (!await modelFile.exists()) {
          return 'Model file not found: $model';
        }
        _interpreter = Interpreter.fromFile(modelFile, options: options);
      }

      return 'Model loaded successfully';
    } catch (e) {
      return 'Failed to load model: $e';
    }
  }

  /// Run model inference on binary data
  /// 
  /// The binary parameter should be a Uint8List containing Float32 data
  /// representing the flattened input tensor
  static Future<List<dynamic>?> runModelOnBinary({
    required dynamic binary,
    int numResults = 2,
    double threshold = 0.1,
  }) async {
    if (_interpreter == null) {
      return null;
    }

    try {
      // Get input and output tensors
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();

      if (inputTensors.isEmpty || outputTensors.isEmpty) {
        return null;
      }

      // Convert binary (Uint8List) back to Float32List
      // The binary contains Float32 data as bytes
      Float32List inputFloat32List;
      if (binary is Uint8List) {
        // Convert bytes to Float32List
        inputFloat32List = binary.buffer.asFloat32List();
      } else {
        print('Unexpected binary type: ${binary.runtimeType}');
        return null;
      }

      // Get the expected input shape from the model
      final inputShape = inputTensors[0].shape;
      final inputSize = inputShape.fold<int>(1, (a, b) => a * b);

      // Reshape the input to match the model's expected shape
      // For text classification, this is typically [1, sequence_length] or [1, sequence_length, vocab_size]
      Object input;
      if (inputShape.length == 1) {
        // 1D input: [sequence_length]
        final endIndex = inputSize < inputFloat32List.length ? inputSize : inputFloat32List.length;
        input = inputFloat32List.sublist(0, endIndex).toList();
      } else if (inputShape.length == 2) {
        // 2D input: [batch_size, sequence_length]
        final batchSize = inputShape[0];
        final seqLength = inputShape[1];
        final reshaped = <List<double>>[];
        for (int i = 0; i < batchSize; i++) {
          final start = i * seqLength;
          final end = start + seqLength < inputFloat32List.length ? start + seqLength : inputFloat32List.length;
          reshaped.add(inputFloat32List.sublist(start, end).map((e) => e.toDouble()).toList());
        }
        input = reshaped;
      } else {
        // For other shapes, try to use the flat list directly
        final endIndex = inputSize < inputFloat32List.length ? inputSize : inputFloat32List.length;
        input = inputFloat32List.sublist(0, endIndex).toList();
      }

      // Prepare output buffer based on output tensor shape
      final outputShape = outputTensors[0].shape;
      final outputSize = outputShape.fold<int>(1, (a, b) => a * b);
      final output = List.filled(outputSize, 0.0);

      // Run inference
      _interpreter!.run(input, output);

      // Return output as list of lists (matching expected format)
      // The output is typically [batch_size, num_classes]
      if (outputShape.length == 2 && outputShape[0] == 1) {
        // Reshape to match expected format: [[class1_prob, class2_prob, ...]]
        return [output];
      } else {
        return [output];
      }
    } catch (e) {
      print('Error running model: $e');
      return null;
    }
  }

  /// Close the model and release resources
  static Future<void> close() async {
    if (_interpreter != null) {
      _interpreter!.close();
      _interpreter = null;
    }
  }
}
