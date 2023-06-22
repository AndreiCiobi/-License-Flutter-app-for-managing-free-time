import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:license_project/services/cloud/cloud_point_of_interest.dart';
import 'package:license_project/services/cloud/cloud_storage_constants.dart';
import 'package:license_project/utilities/generics/decode.dart';

@immutable
class CloudPlace implements CloudPointOfInterest {
  final String id;
  final String name;
  final String imageUrl;
  final String parentId;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? schedule;
  final String? address;
  final String? description;
  final List<String>? contacts;

  const CloudPlace({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.parentId,
    required this.latitude,
    required this.longitude,
    required this.schedule,
    required this.address,
    required this.description,
    required this.contacts,
  });

  CloudPlace.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        name = snapshot.data()[placeName],
        imageUrl = decode(snapshot.data()[placeImageUrl]),
        parentId = snapshot.data()[domainId],
        latitude = snapshot.data()[placeLatitude],
        longitude = snapshot.data()[placeLongitude],
        schedule = snapshot.data()[placeSchedule] ?? {},
        address = snapshot.data()[placeAddress] ?? '',
        description = snapshot.data()[placeDescription],
        contacts = List<String>.from(snapshot.data()[placeContacts] ?? []);
}
