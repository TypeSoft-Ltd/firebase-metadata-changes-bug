import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const _COLLECTION_NAME = 'collection';
const _DOC_NAME = 'doc1';

class TestMetadataChangesPage extends StatefulWidget {
  final bool useDocumentReference;
  const TestMetadataChangesPage({super.key, required this.useDocumentReference});

  @override
  State<TestMetadataChangesPage> createState() => _TestMetadataChangesPageState();
}

class _TestMetadataChangesPageState extends State<TestMetadataChangesPage> {
  final collectionReference = FirebaseFirestore.instance.collection(_COLLECTION_NAME);

  @override
  void initState() {
    super.initState();

    // DocumentReference and CollectionReference do not have a common super class
    final dynamic snapshotReference =
        widget.useDocumentReference ? collectionReference.doc(_DOC_NAME) : collectionReference;
    snapshotReference
        .snapshots(includeMetadataChanges: true)
        .listen((event) => print('FromCache: ${event.metadata.isFromCache}'));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          final update = {'ts': DateTime.now().toIso8601String()};
          collectionReference.doc(_DOC_NAME).update(update);
        },
        child: const Text('Send TimeStamp modification'),
      ),
    );
  }
}
