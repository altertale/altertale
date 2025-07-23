import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'utils/auth_wrapper.dart';

/// Authentication Demo Uygulaması
/// Firebase Authentication modülünü test etmek için
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat (gerçek projede firebase_options.dart import edilmeli)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const AuthDemoApp());
}

class AuthDemoApp extends StatelessWidget {
  const AuthDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Altertale Auth Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.light,
          ),
          fontFamily: 'Inter',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Inter',
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
