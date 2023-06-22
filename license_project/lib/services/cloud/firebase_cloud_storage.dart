import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:license_project/services/cloud/cloud_activity.dart';
import 'package:license_project/services/cloud/cloud_domain.dart';
import 'package:license_project/services/cloud/cloud_event.dart';
import 'package:license_project/services/cloud/cloud_place.dart';
import 'package:license_project/services/cloud/cloud_point_of_interest.dart';
import 'package:license_project/services/cloud/cloud_storage_exceptions.dart';
import 'package:license_project/services/cloud/cloud_storage_constants.dart';

import 'dart:developer' as dev;

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final domains = FirebaseFirestore.instance.collection('domains');

  final places = FirebaseFirestore.instance.collection('places');

  final userFavourites =
      FirebaseFirestore.instance.collection('userFavourites');

  final events = FirebaseFirestore.instance.collection('events');

  final activities = FirebaseFirestore.instance.collection('activities');

  Stream<Iterable<CloudDomain>> getAllActivities() {
    return domains.snapshots().map(
          (event) => event.docs.map(
            (doc) => CloudDomain.fromSnapshot(doc),
          ),
        );
  }

  Future<Iterable<CloudPlace>> getPlacesList(
      {required String givenDomainId}) async {
    try {
      return await places.where(domainId, isEqualTo: givenDomainId).get().then(
          (value) => value.docs.map((doc) => CloudPlace.fromSnapshot(doc)));
    } catch (e) {
      throw CloudGetException();
    }
  }

  Stream<Iterable<Iterable<CloudPointOfInterest>>> getFavouritesByUser({
    required String userId,
    required DocumentSnapshot<Map<String, dynamic>> docSnapshot,
  }) {
    return StreamZip([
      getFavouritePlacesByUser(userId: userId, docSnapshot: docSnapshot),
      getFavouriteEventsByUser(userId: userId, docSnapshot: docSnapshot),
    ]);
  }

  Stream<Iterable<CloudPlace>> getFavouritePlacesByUser({
    required String userId,
    required DocumentSnapshot<Map<String, dynamic>> docSnapshot,
  }) {
    if (docSnapshot.data() == null) {
      return const Stream<Iterable<CloudPlace>>.empty();
    }
    if (docSnapshot.data()!.isEmpty) {
      return const Stream<Iterable<CloudPlace>>.empty();
    }

    final keys = docSnapshot.data()!.keys;
    try {
      return places.where(FieldPath.documentId, whereIn: keys).snapshots().map(
          (event) => event.docs.map((doc) => CloudPlace.fromSnapshot(doc)));
    } catch (e) {
      throw CloudGetException();
    }
  }

  Stream<Iterable<CloudEvent>> getFavouriteEventsByUser({
    required String userId,
    required DocumentSnapshot<Map<String, dynamic>> docSnapshot,
  }) {
    if (docSnapshot.data() == null) {
      return const Stream<Iterable<CloudEvent>>.empty();
    }
    if (docSnapshot.data()!.isEmpty) {
      return const Stream<Iterable<CloudEvent>>.empty();
    }

    final keys = docSnapshot.data()!.keys;
    try {
      return events.where(FieldPath.documentId, whereIn: keys).snapshots().map(
          (event) => event.docs.map((doc) => CloudEvent.fromSnapshot(doc)));
    } catch (e) {
      throw CloudGetException();
    }
  }

  Stream<Iterable<CloudPlace>> getPlaces({required String givenDomainId}) {
    return places.snapshots().map((event) => event.docs
        .where((element) => element.data()[domainId] == givenDomainId)
        .map((e) => CloudPlace.fromSnapshot(e)));
  }

  Future<void> addToFavourites(
      {required String documentId, required String userId}) async {
    final docSnaspshot = await userFavourites.doc(userId).get();
    if (docSnaspshot.exists) {
      try {
        await userFavourites.doc(userId).update({documentId: true});
      } catch (e) {
        throw CloudNotUpdateFavouritesException();
      }
    } else {
      await userFavourites.doc(userId).set({documentId: true});
    }
  }

  Future<void> removeFromFavourites(
      {required String userId, required documentId}) async {
    try {
      await userFavourites
          .doc(userId)
          .update({documentId: FieldValue.delete()});
    } catch (e) {
      throw CloudNotDeleteFavouriteException();
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserFavouritesList(
      {required String userId}) async {
    final x = await userFavourites.doc(userId).get();
    return x;
  }

  bool getFavouriteStatus({
    required DocumentSnapshot<Map<String, dynamic>> docSnapshot,
    required String fieldName,
  }) {
    if (docSnapshot.data() == null) {
      return false;
    }
    if (docSnapshot.data()!.isEmpty) {
      return false;
    }
    return docSnapshot.data()![fieldName] ?? false;
  }

  Stream<Iterable<CloudEvent>> getEvents({required String givenDomainId}) {
    return events.snapshots().map((event) => event.docs
        .where((element) => element.data()[domainId] == givenDomainId)
        .map((e) => CloudEvent.fromSnapshot(e)));
  }

  Future<Iterable<CloudEvent>> getEventsList(
      {required String givenDomainId}) async {
    try {
      return await events.where(domainId, isEqualTo: givenDomainId).get().then(
          (value) => value.docs.map((doc) => CloudEvent.fromSnapshot(doc)));
    } catch (e) {
      throw CloudGetException();
    }
  }

  Stream<Iterable<CloudActivity>> getActivities(
      {required String givenPlaceId}) {
    return activities.snapshots().map((event) => event.docs
        .where((element) => element.data()[placeId] == givenPlaceId)
        .map((e) => CloudActivity.fromSnapshot(e)));
  }
}
