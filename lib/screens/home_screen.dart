import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../widgets/message_card.dart';
import '../widgets/stats_card.dart';
import 'message_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MessageProvider>(context, listen: false);
      provider.loadRecentMessages();
      provider.startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scam SMS Detector'),
        elevation: 0,
        actions: [
          Consumer<MessageProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isListening ? Icons.notifications_active : Icons.notifications_off,
                ),
                onPressed: () {
                  if (provider.isListening) {
                    provider.stopListening();
                  } else {
                    provider.startListening();
                  }
                },
                tooltip: provider.isListening ? 'Stop listening' : 'Start listening',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<MessageProvider>(context, listen: false).loadRecentMessages();
            },
            tooltip: 'Refresh messages',
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Stats Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Total Messages',
                        value: provider.messages.length.toString(),
                        icon: Icons.message,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'Scam Detected',
                        value: provider.scamCount.toString(),
                        icon: Icons.warning,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'Legitimate',
                        value: provider.legitimateCount.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: FilterChip(
                        label: const Text('All'),
                        selected: true,
                        onSelected: (_) {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChip(
                        label: const Text('Scam'),
                        selected: false,
                        onSelected: (_) {
                          // Filter to show only scam messages
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChip(
                        label: const Text('Safe'),
                        selected: false,
                        onSelected: (_) {
                          // Filter to show only safe messages
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Messages List
              Expanded(
                child: provider.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Messages will appear here',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];
                          return MessageCard(
                            message: message,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageDetailScreen(message: message),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}



