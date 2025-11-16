// Stub file for web builds where SMS functionality is not available
// This file is used when compiling for web

import 'dart:async';
import '../models/message_model.dart';

class SMSServiceMobile {
  SMSServiceMobile._internal();
  factory SMSServiceMobile() => _instance;
  static final SMSServiceMobile _instance = SMSServiceMobile._internal();

  Function(ScannedMessage)? onMessageReceived;

  Future<bool> checkPermission() async {
    return false; // SMS not available on web
  }

  Future<void> startListening() async {
    throw UnsupportedError('SMS functionality is not available on web');
  }

  Future<List<ScannedMessage>> getRecentMessages({int limit = 50}) async {
    return []; // Return empty list on web
  }

  void stopListening() {}

  void dispose() {}
}

