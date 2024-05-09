# Firebase Metadata Changes BUG

## Description

On an iOS device, using `includeMetadataChanges` does not work correctly for single document snapshots (which works correctly for collection snapshots which was fixed in this week's commit https://github.com/firebase/flutterfire/pull/12739) for both:
- First query execution
- Regaining/Losing connection to the database

The following examples were tested on an iOS Simulator, but the same problem exists on real devices as well.
These examples compare the behavior of Collection snapshots (which work as expected) and Document snapshots (that behave unexpectedly).

### Example: Collection Snapshot (works as expected)
```dart
final collectionRef = FirebaseFirestore.instance.collection('col');
colectionRef
  .snapshots(includeMetadataChanges: true)
  .listen((event) => print('FromCache: ${event.metadata.isFromCache}'));
```

**Launching the app**

When we launch the app, first we receive data from the cache and then we receive data from the database (as expected):
```
flutter: FromCache: true
flutter: FromCache: false
```

**Regaining connection to DB**

Process: After disconnecting the simulator from an internet connection, I will send a modification to the database. Then I will enable the internet connection.
```dart
final update = {'ts': DateTime.now().toIso8601String()};
collectionRef.doc(_DOC_NAME).update(update);
```
Received events (as expected):
```
flutter: FromCache: true // This event was received by disconnecting the internet connection
flutter: FromCache: true // Received by sending a modification
flutter: FromCache: false // Received when connected to the internet
flutter: FromCache: false // Received after all modifications have been written to DB
```

### Example: Document Snapshot (incorrect behavior)
```dart
final documentRef = FirebaseFirestore.instance.collection('col').doc('doc');
documentRef
  .snapshots(includeMetadataChanges: true)
  .listen((event) => print('FromCache: ${event.metadata.isFromCache}'));
```

**Launching the app** (for the second time - the first time we don't have any data cached so we will receive the event `fromCache: false`)

When we launch the app, we receive data from the cache, but we do not receive the event from the server (which would be expected).
```
flutter: FromCache: true
```

The `FromCache: false` event is not received when the query is first executed, but it will be received only after data is updated in the database (or we send a modification from the app).

**Regaining connection to DB**
Process: After disconnecting the simulator from an internet connection, I will send a modification to the database. Then I will enable the internet connection.
```dart
final update = {'ts': DateTime.now().toIso8601String()};
collectionRef.doc(_DOC_NAME).update(update);
```
Received events:
```
flutter: FromCache: true // Event received after sending the modification
```

**As opposed to Collection Reference, we did not receive the event `fromCache: true` after we lost the database connection. We also do not receive `fromCache: false` events after the connection is regained nor after all modifications are written.**

We will receive the `fromCache: false` event only after the data in the database is updated which is not expected behavior.

## Expected behavior:
Both single document snapshots and collection snapshots should behave consistently.

The correct behavior is of the collection snapshots.

### Appendix:

This issue has already been reported once for collection snapshots: https://github.com/firebase/flutterfire/issues/12722.
The conclusion was a new ticket to ios sdk (https://github.com/firebase/firebase-ios-sdk/issues/12869), where the solution was to change `addSnapshotListenerWithOptions:options` to `addSnapshotListenerWithOptions:optionsWithSourceAndMetadata`.
Thus a bug fix was pushed to **flutterfire**.

However going into the fix (https://github.com/firebase/flutterfire/pull/12739), I noticed that only file `FLTQuerySnapshotStreamHandler.m` was updated with this change, but file `FLTDocumentSnapshotStreamHandler.m` does not have these changes applied.

## Reproducing the issue

Create a new Flutter app and connect it to Firebase. In this app, create a new listener that will observe document snapshots with metadata changes.
```dart
final documentRef = FirebaseFirestore.instance.collection('col').doc('doc');
documentsRef
  .snapshots(includeMetadataChanges: true)
  .listen((event) => print('FromCache: ${event.metadata.isFromCache}'));
```
Test both of these scenarios:
- First query execution
- Regaining/Losing connection to the database

An app I used for testing is available at:

https://github.com/TypeSoft-Ltd/firebase-metadata-changes-bug

To test different behavior between collection and document snapshots, change the `useDocumentReference` bool property to *`true`* and *`false`* on widget **`TestMetadataChangesPage`** in the **`app/widget/app_root.dart`**
