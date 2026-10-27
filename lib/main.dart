import 'package:flutter/material.dart';
import 'package:fintrack/app.dart';
import 'package:fintrack/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await configureDependencies();
  } catch (error) {
    runApp(StartupErrorApp(message: error.toString()));
    return;
  }
  runApp(const FinTrackApp( ));
}
