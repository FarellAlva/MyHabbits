// app.dart

import 'package:flutter/material.dart';
import 'page/home_page.dart';
import 'page/thought_page.dart'; 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaHabits',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
   
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/thoughts': (context) => const ThoughtPage(), 
      },
    );
  }
}