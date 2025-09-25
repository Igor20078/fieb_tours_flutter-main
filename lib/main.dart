import 'package:fieb_tours_educativo_flutter/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(PasseiosApp());
}

class PasseiosApp extends StatelessWidget {
  const PasseiosApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Passeios Escolares',
      theme: ThemeData(
        primaryColor: Color(0xFF4C89AC),
        scaffoldBackgroundColor: Color(0xFFEDEDED),
        fontFamily: 'Arial',
      ),
      home: HomeScreen(),
    );
  }
}