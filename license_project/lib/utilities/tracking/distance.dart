import 'package:geolocator/geolocator.dart';

Future<String> getDistanceInKm(
  double targetLatitude,
  double targetLongitude,
) async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.medium,
  );

  return "${(Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        targetLatitude,
        targetLongitude,
      ) / 1000).toStringAsFixed(1)} km";
}
