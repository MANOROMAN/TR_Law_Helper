import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const HukukiAsistanApp());
}

class HukukiAsistanApp extends StatelessWidget {
  const HukukiAsistanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hukuki Asistan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D3E50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D3E50),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: HomeScreen(),
    );
  }
}
