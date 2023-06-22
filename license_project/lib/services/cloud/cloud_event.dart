import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:license_project/services/cloud/cloud_point_of_interest.dart';
import 'package:license_project/services/cloud/cloud_storage_constants.dart';
import 'package:license_project/utilities/generics/decode.dart';

@immutable
class CloudEvent implements CloudPointOfInterest {
  final String id;
  final String parentId;
  final String imageUrl;
  final String name;
  final DateTime timestamp;
  final String address;
  final String contact;
  final double latitude;
  final double longitude;
  final String description;

  const CloudEvent({
    required this.id,
    required this.parentId,
    required this.imageUrl,
    required this.name,
    required this.timestamp,
    required this.address,
    required this.contact,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  CloudEvent.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        parentId = snapshot.data()[domainId],
        imageUrl = decode(snapshot.data()[eventImageUrl]),
        name = snapshot.data()[eventName],
        timestamp =
            (snapshot.data()[eventTimestamp] ?? DateTime.now() as Timestamp)
                .toDate(),
        address = snapshot.data()[placeAddress],
        contact = snapshot.data()[eventTickets],
        latitude = snapshot.data()[placeLatitude],
        longitude = snapshot.data()[placeLongitude],
        description = snapshot.data()[eventDescription] ?? '';
}
