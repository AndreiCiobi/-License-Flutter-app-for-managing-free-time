import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:license_project/services/cloud/cloud_storage_constants.dart';
import 'package:license_project/utilities/generics/decode.dart';

@immutable
class CloudDomain {
  final String id;
  final String label;
  final String imageUrl;
  final String domainPath;
  final bool hasEvents;

  const CloudDomain({
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.domainPath,
    required this.hasEvents,
  });

  CloudDomain.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        label = snapshot.data()[domainLabel],
        imageUrl = decode(snapshot.data()[domainImageUrl]),
        domainPath = snapshot.data()[path],
        hasEvents = snapshot.data()[domainHasEvents] ?? false;
}
