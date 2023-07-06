import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_project/helpers/components/listviews/weekly_list_view.dart';
import 'package:license_project/helpers/logged/logged_app_bar.dart';
import 'package:license_project/helpers/logged/logged_bottom_nav_bar.dart';
import 'package:license_project/services/auth/auth_service.dart';
import 'package:license_project/services/cloud/cloud_domain.dart';
import 'package:license_project/services/cloud/cloud_event.dart';
import 'package:license_project/services/cloud/firebase_cloud_storage.dart';
import 'package:license_project/utilities/dialogs/missing_event_dialog.dart';
import 'package:license_project/utilities/enums/nav_bar.dart';

import 'dart:developer' as dev;

import 'package:license_project/utilities/generics/extensions.dart';
import 'package:license_project/utilities/routes.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  String get userId => AuthService.firebase().currentUser!.id;
  late Future<DocumentSnapshot<Map<String, dynamic>>> futureDocSnapshot;
  late CloudDomain _cloudDomain;
  late final FirebaseCloudStorage _cloudService;
  var _currentDay = DateTime.now().day;

  @override
  void initState() {
    _cloudService = FirebaseCloudStorage();
    futureDocSnapshot = _cloudService.getUserFavouritesList(userId: userId);
    super.initState();
  }

  void _getDayOfMonth(int day) {
    setState(() {
      _currentDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    _cloudDomain = context.getArgument<CloudDomain>()!;

    return Scaffold(
      appBar: const LoggedAppBar(),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: WeeklyListview(callback: _getDayOfMonth),
          ),
          Expanded(
              child: FutureBuilder(
            future: futureDocSnapshot,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    final docSnapshot = snapshot.data!;
                    return StreamBuilder(
                      stream: _cloudService.getEvents(
                          givenDomainId: _cloudDomain.id),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.active:
                            if (snapshot.hasData) {
                              final events =
                                  snapshot.data as Iterable<CloudEvent>;

                              if (events.any((element) => element.timestamp
                                      .isAfter(DateTime.now())) ==
                                  false) {
                                return const MissingEventDialog();
                              }

                              if (events.isEmpty) {
                                return const MissingEventDialog();
                              }

                              final eventsCopy = events
                                  .where((element) =>
                                      element.timestamp.day == _currentDay)
                                  .toList();

                              if (eventsCopy.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'There are no events proggramed today',
                                            style: GoogleFonts.actor(
                                              fontSize: 40,
                                              color: Colors.grey,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                itemCount: eventsCopy.length,
                                itemBuilder: (context, index) {
                                  final event = eventsCopy.elementAt(index);

                                  final isFavourite =
                                      _cloudService.getFavouriteStatus(
                                    docSnapshot: docSnapshot,
                                    fieldName: event.id,
                                  );

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
                                              BorderRadius.circular(14),
                                        ),
                                        elevation: 4,
                                        child: SizedBox(
                                          height: 200,
                                          child: GridTile(
                                            footer: GridTileBar(
                                              backgroundColor: Colors.black87,

                                              title: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  event.name,
                                                  style: GoogleFonts.actor(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              // subtitle: ShowDistance(
                                              //   latitude: place.latitude,
                                              //   longitude: place.longitude,
                                              // ).display(),
                                              trailing: isFavourite
                                                  ? IconButton(
                                                      icon: const Icon(Icons
                                                          .favorite_outlined),
                                                      color: Colors.red,
                                                      onPressed: () async {
                                                        await _cloudService
                                                            .removeFromFavourites(
                                                          userId: userId,
                                                          documentId: event.id,
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
                                                          documentId: event.id,
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
                                            child: CachedNetworkImage(
                                              imageUrl: event.imageUrl,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  const Center(
                                                child:
                                                    CircularProgressIndicator(),
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
                              return const Placeholder();
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
          )),
        ],
      ),
      bottomNavigationBar: const LoggedBottomNavBar(choice: NavBarChoice.home),
    );
  }
}
