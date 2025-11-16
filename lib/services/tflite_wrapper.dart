// Wrapper for TFLite that handles conditional imports
// On mobile: imports ml_service_impl.dart (which uses tflite_plus)
// On web: imports ml_service_stub.dart (stub implementation)
import 'ml_service_stub.dart'
if (dart.library.io) 'ml_service_impl.dart';

/// Wrapper class that provides a unified interface for TFLite operations
class TFLiteWrapper {
  /// Load a TensorFlow Lite model
  static Future<String?> loadModel({
    required String model,
    String? labels,
    int numThreads = 1,
    bool isAsset = true,
    bool useGpuDelegate = false,
    bool useNnApi = false,
  }) async {
    // The conditional import ensures the correct implementation is used
    // On mobile: TFLiteImpl from ml_service_impl.dart
    // On web: TFLiteImpl from ml_service_stub.dart
    return await TFLiteImpl.loadModel(
      model: model,
      labels: labels,
      numThreads: numThreads,
      isAsset: isAsset,
      useGpuDelegate: useGpuDelegate,
      useNnApi: useNnApi,
    );
  }

  /// Run model inference on binary data
  static Future<List<dynamic>?> runModelOnBinary({
    required dynamic binary,
    int numResults = 2,
    double threshold = 0.1,
  }) async {
    return await TFLiteImpl.runModelOnBinary(
      binary: binary,
      numResults: numResults,
      threshold: threshold,
    );
  }

  /// Close the model and release resources
  static Future<void> close() async {
    await TFLiteImpl.close();
  }
}

