// Stub for path_provider on web
class Directory {
  final String path;
  Directory(this.path);
}

Future<Directory> getApplicationDocumentsDirectory() async {
  return Directory('/'); // Placeholder for web
}


