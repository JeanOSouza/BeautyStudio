import 'package:flutter/material.dart';
import 'screens/tela_adcao_servico.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());

  WidgetsFlutterBinding.ensureInitialized();

  // Roda o aplicativo Flutter.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App com Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:
          const ServiceFormScreen(), // A tela inicial continua sendo a LoginScreen
    );
  }
}
