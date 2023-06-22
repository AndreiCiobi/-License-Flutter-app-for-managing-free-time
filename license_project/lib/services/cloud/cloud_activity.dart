import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:license_project/services/cloud/cloud_storage_constants.dart';
import 'package:license_project/utilities/generics/decode.dart';

@immutable
class CloudActivity {
  final String id;
  final String parentId;
  final String imageUrl;
  final String title;
  final DateTime timestamp;

  const CloudActivity({
    required this.id,
    required this.parentId,
    required this.imageUrl,
    required this.title,
    required this.timestamp,
  });

  CloudActivity.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        parentId = snapshot.data()[placeId],
        imageUrl = decode(snapshot.data()[activityImageUrl]),
        title = snapshot.data()[activityTitle],
        timestamp =
            (snapshot.data()[activityTimestamp] ?? Timestamp.now()).toDate();
}
