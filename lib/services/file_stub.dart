// Stub File class for web builds
class File {
  final String path;
  File(this.path);
  
  Future<void> writeAsBytes(List<int> bytes) async {
    throw UnsupportedError('File operations not supported on web');
  }
}


