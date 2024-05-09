import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_metadata_changes/app/widget/app_root.dart';
import 'package:firebase_metadata_changes/environment/firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AppRoot());
}
