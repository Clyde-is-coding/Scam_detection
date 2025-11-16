import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/sms_service.dart';
import 'services/ml_service.dart';
import 'screens/home_screen.dart';
import 'providers/message_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request SMS permission on app start (only on mobile)
  if (!kIsWeb) {
    await Permission.sms.request();
  }
  
  // Initialize ML service
  await MLService.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: MaterialApp(
        title: 'Scam SMS Detector',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


