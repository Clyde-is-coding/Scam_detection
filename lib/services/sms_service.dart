import 'dart:async';
import 'package:sms/sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ml_service.dart';
import '../models/message_model.dart';

class SMSService {
  static final SMSService instance = SMSService._internal();
  factory SMSService() => instance;
  SMSService._internal();

  SmsReceiver? _receiver;
  StreamSubscription? _subscription;
  Function(ScannedMessage)? onMessageReceived;

  Future<bool> checkPermission() async {
    final status = await Permission.sms.status;
    if (status.isGranted) {
      return true;
    }
    
    final result = await Permission.sms.request();
    return result.isGranted;
  }

  Future<void> startListening() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      throw Exception('SMS permission not granted');
    }

    _receiver = SmsReceiver();
    
    _subscription = _receiver!.onSmsReceived?.listen((SmsMessage message) async {
      // Detect scam
      final result = await MLService.instance.detectScam(message.body ?? '');
      
      // Create scanned message
      final scannedMessage = ScannedMessage(
        id: message.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        sender: message.sender ?? 'Unknown',
        body: message.body ?? '',
        date: message.date ?? DateTime.now(),
        isScam: result.isScam,
        confidence: result.confidence,
      );
      
      // Notify listener
      onMessageReceived?.call(scannedMessage);
    });
  }

  Future<List<ScannedMessage>> getRecentMessages({int limit = 50}) async {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      return [];
    }

    try {
      final query = SmsQuery();
      final messages = await query.querySms(
        kinds: [SmsQueryKind.Inbox],
        count: limit,
      );

      final scannedMessages = <ScannedMessage>[];
      
      for (var message in messages) {
        final result = await MLService.instance.detectScam(message.body ?? '');
        
        scannedMessages.add(ScannedMessage(
          id: message.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          sender: message.sender ?? 'Unknown',
          body: message.body ?? '',
          date: message.date ?? DateTime.now(),
          isScam: result.isScam,
          confidence: result.confidence,
        ));
      }
      
      return scannedMessages;
    } catch (e) {
      print('Error getting recent messages: $e');
      return [];
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _receiver = null;
  }

  void dispose() {
    stopListening();
  }
}

