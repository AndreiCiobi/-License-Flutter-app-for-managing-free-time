import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_project/helpers/components/listviews/weekly_list_view.dart';
import 'package:license_project/helpers/components/texts/show_distance.dart';
import 'package:license_project/helpers/logged/logged_app_bar.dart';
import 'package:license_project/helpers/logged/logged_bottom_nav_bar.dart';
import 'package:license_project/helpers/logged/logged_drawer.dart';
import 'package:license_project/services/auth/auth_service.dart';
import 'package:license_project/services/cloud/cloud_event.dart';
import 'package:license_project/services/cloud/cloud_place.dart';
import 'package:license_project/services/cloud/cloud_point_of_interest.dart';
import 'package:license_project/services/cloud/firebase_cloud_storage.dart';
import 'package:license_project/utilities/dialogs/missing_event_dialog.dart';
import 'package:license_project/utilities/enums/nav_bar.dart';
import 'package:license_project/utilities/generics/calendar.dart';

import 'package:collection/collection.dart';

import 'dart:developer' as dev;

import 'package:license_project/utilities/routes.dart';

class FavouritesView extends StatefulWidget {
  const FavouritesView({super.key});

  @override
  State<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView>
    with TickerProviderStateMixin {
  late final FirebaseCloudStorage _cloudService;
  String get userId => AuthService.firebase().currentUser!.id;
  late Future<DocumentSnapshot<Map<String, dynamic>>> futureDocSnapshot;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _cloudService = FirebaseCloudStorage();
    futureDocSnapshot = _cloudService.getUserFavouritesList(userId: userId);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LoggedAppBar(),
      drawer: const LoggedAppDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              controller: _tabController,
              tabs: const [
                Tab(text: 'Locations'),
                Tab(text: 'Events'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: futureDocSnapshot,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.done:
                    if (snapshot.hasData) {
                      final docSnapshot = snapshot.data!;
                      return StreamBuilder(
                        stream: _cloudService.getFavouritesByUser(
                          userId: userId,
                          docSnapshot: docSnapshot,
                        ),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.active:
                              final pointsOfInterest = snapshot.data
                                  as Iterable<Iterable<CloudPointOfInterest>>;

                              if (pointsOfInterest.isEmpty) {
                                return const TabBarView(children: [
                                  NoFavouriteAdded(),
                                  NoFavouriteAdded()
                                ]);
                              }

                              final places = pointsOfInterest.elementAt(0)
                                  as Iterable<CloudPlace>;

                              final events = pointsOfInterest.elementAt(1)
                                  as Iterable<CloudEvent>;

                              return TabBarView(
                                controller: _tabController,
                                children: [
                                  places.isEmpty
                                      ? const NoFavouriteAdded()
                                      : ListView.builder(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          itemCount: places.length,
                                          itemBuilder: (context, index) {
                                            final place =
                                                places.elementAt(index);

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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                  ),
                                                  elevation: 4,
                                                  child: SizedBox(
                                                    height: 200,
                                                    child: GridTile(
                                                      header: GridTileBar(
                                                        backgroundColor:
                                                            Colors.black87,
                                                        leading: const Icon(
                                                            Icons.location_pin),
                                                        title: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            place.name,
                                                            style: GoogleFonts
                                                                .actor(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 22,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        subtitle: ShowDistance(
                                                          latitude:
                                                              place.latitude,
                                                          longitude:
                                                              place.longitude,
                                                        ).display(),
                                                        trailing: IconButton(
                                                          color: Colors.red,
                                                          icon: const Icon(
                                                              Icons.favorite),
                                                          onPressed: () async {
                                                            await _cloudService
                                                                .removeFromFavourites(
                                                              documentId:
                                                                  place.id,
                                                              userId: userId,
                                                            );
                                                            setState(() {
                                                              futureDocSnapshot =
                                                                  _cloudService
                                                                      .getUserFavouritesList(
                                                                          userId:
                                                                              userId);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                place.imageUrl),
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
                                        ),
                                  events.isEmpty
                                      ? const NoFavouriteAdded()
                                      : ListView.builder(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          itemCount: events.length,
                                          itemBuilder: (context, index) {
                                            final event =
                                                events.elementAt(index);

                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).pushNamed(
                                                  detailsEvent,
                                                  arguments: event,
                                                );
                                              },
                                              child: Hero(
                                                tag: event.id,
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                  ),
                                                  elevation: 4,
                                                  child: SizedBox(
                                                    height: 200,
                                                    child: GridTile(
                                                      footer: GridTileBar(
                                                        backgroundColor:
                                                            Colors.black87,
                                                        // leading: const Icon(
                                                        //     Icons.location_pin),

                                                        title: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            event.name,
                                                            style: GoogleFonts
                                                                .actor(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 22,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                          formatDate(
                                                              event.timestamp),
                                                        ),
                                                        trailing: IconButton(
                                                          color: Colors.red,
                                                          icon: const Icon(
                                                              Icons.favorite),
                                                          onPressed: () async {
                                                            await _cloudService
                                                                .removeFromFavourites(
                                                              documentId:
                                                                  event.id,
                                                              userId: userId,
                                                            );
                                                            setState(() {
                                                              futureDocSnapshot =
                                                                  _cloudService
                                                                      .getUserFavouritesList(
                                                                          userId:
                                                                              userId);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                event.imageUrl),
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
                                        ),
                                ],
                              );
                            default:
                              return const NoFavouriteAdded();
                          }
                        },
                      );
                    } else {
                      return const Placeholder();
                    }

                  default:
                    return const Placeholder();
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const LoggedBottomNavBar(
        choice: NavBarChoice.favourites,
      ),
    );
  }
}

class NoFavouriteAdded extends StatelessWidget {
  const NoFavouriteAdded({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.square_favorites_alt,
            size: 80,
            color: Colors.grey,
          ),
          Text(
            'You currently have no favourites',
            style: GoogleFonts.actor(
              fontSize: 40,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
