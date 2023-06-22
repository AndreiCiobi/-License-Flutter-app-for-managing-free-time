import 'package:flutter/material.dart';
import 'package:license_project/utilities/tracking/distance.dart';
import 'package:license_project/utilities/tracking/permissions.dart';

class ShowDistance {
  final double? latitude;
  final double? longitude;

  const ShowDistance({
    required this.latitude,
    required this.longitude,
  });

  bool _areCoordinatesValid() {
    return latitude != null && longitude != null;
  }

  Future<String?> _getDistance() async {
    final arePermissionsEnabled = await handleLocationPermission();

    if (arePermissionsEnabled) {
      return getDistanceInKm(latitude!, longitude!);
    } else {
      return Future.value(null);
    }
  }

  Widget? display() {
    return _areCoordinatesValid()
        ? FutureBuilder(
            future: _getDistance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return const Text('Unknown distance');
                } else {
                  return Text(
                    snapshot.data as String,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  );
                }
              } else {
                return const CircularProgressIndicator(
                  color: Colors.white,
                );
              }
            },
          )
        : null;
  }
}
