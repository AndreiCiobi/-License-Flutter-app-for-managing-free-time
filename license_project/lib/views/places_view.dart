import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_project/helpers/components/texts/show_distance.dart';
import 'package:license_project/helpers/logged/logged_app_bar.dart';
import 'package:license_project/helpers/logged/logged_bottom_nav_bar.dart';
import 'package:license_project/helpers/logged/logged_drawer.dart';
import 'package:license_project/services/auth/auth_service.dart';
import 'package:license_project/services/cloud/cloud_domain.dart';
import 'package:license_project/services/cloud/cloud_place.dart';
import 'package:license_project/services/cloud/firebase_cloud_storage.dart';
import 'package:license_project/utilities/dialogs/missing_event_dialog.dart';
import 'package:license_project/utilities/enums/nav_bar.dart';
import 'package:license_project/utilities/generics/extensions.dart';

import 'dart:developer' as developer;

import 'package:license_project/utilities/routes.dart';

class PlacesView extends StatefulWidget {
  const PlacesView({super.key});

  @override
  State<PlacesView> createState() => _PlacesViewState();
}

class _PlacesViewState extends State<PlacesView> {
  late CloudDomain _cloudDomain;
  late Future<DocumentSnapshot<Map<String, dynamic>>> futureDocSnapshot;
  late final FirebaseCloudStorage _cloudService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _cloudService = FirebaseCloudStorage();
    futureDocSnapshot = _cloudService.getUserFavouritesList(userId: userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _cloudDomain = context.getArgument<CloudDomain>()!;

    return Scaffold(
      appBar: const LoggedAppBar(),
      drawer: const LoggedAppDrawer(),
      body: FutureBuilder(
        future: futureDocSnapshot,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasData) {
                final docSnapshot = snapshot.data!;
                return StreamBuilder(
                  stream:
                      _cloudService.getPlaces(givenDomainId: _cloudDomain.id),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final places = snapshot.data as Iterable<CloudPlace>;

                          if (places.isEmpty) {
                            return const MissingEventDialog();
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            itemCount: places.length,
                            itemBuilder: (context, index) {
                              final place = places.elementAt(index);
                              final isFavourite =
                                  _cloudService.getFavouriteStatus(
                                docSnapshot: docSnapshot,
                                fieldName: place.id,
                              );

                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    detailsPlace,
                                    arguments: place,
                                  );
                                },
                                child: Hero(
                                  tag: place.id,
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 4,
                                    child: SizedBox(
                                      height: 200,
                                      child: GridTile(
                                        header: GridTileBar(
                                          backgroundColor: Colors.black87,
                                          leading:
                                              const Icon(Icons.location_pin),
                                          title: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              place.name,
                                              style: GoogleFonts.actor(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          subtitle: ShowDistance(
                                            latitude: place.latitude,
                                            longitude: place.longitude,
                                          ).display(),
                                          trailing: isFavourite
                                              ? IconButton(
                                                  icon: const Icon(
                                                      Icons.favorite_outlined),
                                                  color: Colors.red,
                                                  onPressed: () async {
                                                    await _cloudService
                                                        .removeFromFavourites(
                                                      userId: userId,
                                                      documentId: place.id,
                                                    );
                                                    setState(() {
                                                      futureDocSnapshot =
                                                          _cloudService
                                                              .getUserFavouritesList(
                                                        userId: userId,
                                                      );
                                                    });
                                                  })
                                              : IconButton(
                                                  icon: const Icon(Icons
                                                      .favorite_border_outlined),
                                                  onPressed: () async {
                                                    await _cloudService
                                                        .addToFavourites(
                                                      documentId: place.id,
                                                      userId: userId,
                                                    );
                                                    setState(() {
                                                      futureDocSnapshot =
                                                          _cloudService
                                                              .getUserFavouritesList(
                                                        userId: userId,
                                                      );
                                                    });
                                                  },
                                                ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(place.imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                      default:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                    }
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
      bottomNavigationBar: const LoggedBottomNavBar(choice: NavBarChoice.home),
    );
  }
}
