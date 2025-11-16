import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/message_model.dart';

// Conditional import for SMS - only on mobile platforms
import 'sms_service_stub.dart' if (dart.library.io) 'sms_service_mobile.dart' as sms_impl;

class SMSService {
  static final SMSService instance = SMSService._internal();
  factory SMSService() => instance;
  SMSService._internal();

  // Delegate to platform-specific implementation
  final sms_impl.SMSServiceMobile _impl = sms_impl.SMSServiceMobile();

  Function(ScannedMessage)? get onMessageReceived => _impl.onMessageReceived;
  set onMessageReceived(Function(ScannedMessage)? callback) {
    _impl.onMessageReceived = callback;
  }

  Future<bool> checkPermission() => _impl.checkPermission();
  Future<void> startListening() => _impl.startListening();
  Future<List<ScannedMessage>> getRecentMessages({int limit = 50}) => 
      _impl.getRecentMessages(limit: limit);
  void stopListening() => _impl.stopListening();
  void dispose() => _impl.dispose();
}


