import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudentOrganizerApp());
}

class StudentOrganizerApp extends StatelessWidget {
  const StudentOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7986CB),
          brightness: Brightness.dark,        // ← add this
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),  // ← add this
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
