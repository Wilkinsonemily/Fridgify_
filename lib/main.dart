import 'package:flutter/material.dart';
import 'package:fridgify/screens/home_screen.dart';
import 'package:fridgify/screens/login_screen.dart';
import 'package:fridgify/screens/register_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => RegisterPage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
