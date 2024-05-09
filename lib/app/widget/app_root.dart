import 'package:firebase_metadata_changes/metadata_changes/widget/test_metadata_changes_page.dart';
import 'package:flutter/material.dart';

const _TITLE = 'Firebase - Metadata Behavior';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _TITLE,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(_TITLE),
        ),
        body: const TestMetadataChangesPage(useDocumentReference: false),
      ),
    );
  }
}
