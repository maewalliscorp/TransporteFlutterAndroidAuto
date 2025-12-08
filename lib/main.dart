import 'package:flutter/material.dart';
import 'Screens/Home_Screen.dart';
import 'Screens/Rutas_Screen.dart';
import 'Screens/LoginScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Auto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (_) => HomeScreen(codigo: ""),
        '/rutas': (_) => RutasScreen(codigo: ""),
      },
    );
  }
}
