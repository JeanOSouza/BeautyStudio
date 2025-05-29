import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // FireBase autentication
import 'screens/login.dart'; // Importe a tela

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(); // inicializa o Firebase
    runApp(const MyApp());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App com Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(), // Tela inicial = Login
    );
  }
}
