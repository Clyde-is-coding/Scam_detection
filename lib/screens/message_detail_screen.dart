import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageDetailScreen extends StatelessWidget {
  final ScannedMessage message;

  const MessageDetailScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: message.isScam ? Colors.red.shade50 : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      message.isScam ? Icons.warning : Icons.check_circle,
                      color: message.isScam ? Colors.red : Colors.green,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.isScam ? 'SCAM DETECTED' : 'LEGITIMATE MESSAGE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: message.isScam ? Colors.red : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confidence: ${(message.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sender Info
            _buildInfoSection(
              'From',
              message.sender,
              Icons.person,
            ),

            const SizedBox(height: 16),

            // Date Info
            _buildInfoSection(
              'Date',
              '${message.date.day}/${message.date.month}/${message.date.year} ${message.date.hour}:${message.date.minute.toString().padLeft(2, '0')}',
              Icons.calendar_today,
            ),

            const SizedBox(height: 24),

            // Message Content
            Text(
              'Message',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  message.body,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Analysis Section
            Text(
              'Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnalysisRow('Scam Score', message.confidence),
                    const SizedBox(height: 8),
                    _buildAnalysisRow('Risk Level', message.isScam ? 'High' : 'Low'),
                    const SizedBox(height: 8),
                    _buildAnalysisRow('Status', message.isScam ? 'Suspicious' : 'Safe'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


