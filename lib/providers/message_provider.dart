import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../services/sms_service.dart';

class MessageProvider extends ChangeNotifier {
  final List<ScannedMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;

  List<ScannedMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;

  int get scamCount => _messages.where((m) => m.isScam).length;
  int get legitimateCount => _messages.where((m) => !m.isScam).length;

  MessageProvider() {
    _setupSMSListener();
  }

  void _setupSMSListener() {
    SMSService.instance.onMessageReceived = (ScannedMessage message) {
      _addMessage(message);
    };
  }

  Future<void> loadRecentMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final messages = await SMSService.instance.getRecentMessages();
      _messages.clear();
      _messages.addAll(messages);
      _messages.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    try {
      await SMSService.instance.startListening();
      _isListening = true;
      notifyListeners();
    } catch (e) {
      print('Error starting SMS listener: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  void stopListening() {
    SMSService.instance.stopListening();
    _isListening = false;
    notifyListeners();
  }

  void _addMessage(ScannedMessage message) {
    // Check if message already exists
    if (!_messages.any((m) => m.id == message.id)) {
      _messages.insert(0, message);
      notifyListeners();
    }
  }

  List<ScannedMessage> getScamMessages() {
    return _messages.where((m) => m.isScam).toList();
  }

  List<ScannedMessage> getLegitimateMessages() {
    return _messages.where((m) => !m.isScam).toList();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

