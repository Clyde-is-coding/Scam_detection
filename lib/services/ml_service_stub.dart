import 'dart:typed_data';

// Stub for TFLiteImpl to be used on the web.
// It provides empty implementations for the static methods.
class TFLiteImpl {
  static Future<String?> loadModel({
    required String model,
    String? labels,
    int numThreads = 1,
    bool isAsset = true,
    bool useGpuDelegate = false,
    bool useNnApi = false,
  }) async {
    print('TflitePlus stub: loadModel called');
    return null;
  }

  static Future<List<dynamic>?> runModelOnBinary({
    required dynamic binary,
    int numResults = 2,
    double threshold = 0.1,
  }) async {
    print('TflitePlus stub: runModelOnBinary called');
    return null;
  }

  static Future<void> close() async {
    print('TflitePlus stub: close called');
  }
}