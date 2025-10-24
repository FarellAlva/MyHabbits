// main.dart

// ignore_for_file: depend_on_referenced_packages, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_mobile_dev/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

Future<void> main() async {
  final widgetBinding = WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
 
    print("Error loading .env file: $e"); 
  }

  FlutterNativeSplash.preserve(widgetsBinding: widgetBinding);
  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();
  
  runApp(const ProviderScope(child: MyApp()));
}