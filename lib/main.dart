import 'package:flutter/material.dart';
import 'package:flutter_mobile_dev/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future <void> main() async {
final widgetBinding= WidgetsFlutterBinding.ensureInitialized();   
FlutterNativeSplash.preserve(widgetsBinding: widgetBinding) ;
await Future.delayed(const Duration(seconds: 1));
FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: MyApp()));
}


