import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:license_project/helpers/components/listviews/weekly_list_view.dart';
import 'package:license_project/services/cloud/cloud_activity.dart';
import 'package:license_project/services/cloud/cloud_place.dart';
import 'package:license_project/services/cloud/firebase_cloud_storage.dart';
import 'package:license_project/utilities/generics/calendar.dart';
import 'package:license_project/utilities/generics/extensions.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:developer' as dev;

class DetailsPlaceView extends StatefulWidget {
  const DetailsPlaceView({super.key});

  @override
  State<DetailsPlaceView> createState() => _DetailsPlaceViewState();
}

class _DetailsPlaceViewState extends State<DetailsPlaceView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late CloudPlace _cloudPlace;
  late TabController _tabController;
  late final FirebaseCloudStorage _cloudService;

  Future<void> _launchUrl(Uri uri) async {
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  void initState() {
    super.initState();
    _cloudService = FirebaseCloudStorage();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void modifyNumberOfTabs(int length) {
    _tabController = TabController(length: length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _cloudPlace = context.getArgument<CloudPlace>()!;
    if (_cloudPlace.hasActivities == false) {
      modifyNumberOfTabs(3);
    }

    final contactList = _cloudPlace.contacts!;
    final LatLng source = LatLng(_cloudPlace.latitude!, _cloudPlace.longitude!);
    final navigation =
        Uri.parse('google.navigation:q=${source.latitude},${source.longitude}');

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double remainingHeight = constraints.biggest.height;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                backgroundColor: const Color.fromARGB(255, 220, 140, 164),
                expandedHeight: remainingHeight * 0.3,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _cloudPlace.name,
                        style: GoogleFonts.actor(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  background: Hero(
                    tag: _cloudPlace.id,
                    child: Image.network(
                      _cloudPlace.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              MultiSliver(
                children: [
                  SliverPinnedHeader(
                    child: SizedBox(
                      height: remainingHeight * 0.075,
                      child: TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        controller: _tabController,
                        tabs: [
                          if (_cloudPlace.hasActivities == true)
                            const Tab(
                              icon: Icon(CupertinoIcons.square_list),
                            ),
                          const Tab(
                            icon: Icon(CupertinoIcons.map),
                          ),
                          const Tab(
                            icon: Icon(Icons.schedule_outlined),
                          ),
                          const Tab(
                            icon: Icon(CupertinoIcons.info),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: 1,
                      (context, index) {
                        return SizedBox(
                          height: remainingHeight * 0.58375,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              if (_cloudPlace.hasActivities == true)
                                _cloudPlace.hasCalendar!
                                    ? _CachedContent(
                                        child: PlaceDynamicActivities(
                                          cloudService: _cloudService,
                                          cloudPlace: _cloudPlace,
                                        ),
                                      )
                                    : PlaceStaticActivities(
                                        cloudService: _cloudService,
                                        cloudPlace: _cloudPlace,
                                      ),
                              _CachedContent(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: GoogleMap(
                                        gestureRecognizers: <Factory<
                                            OneSequenceGestureRecognizer>>{
                                          Factory<OneSequenceGestureRecognizer>(
                                            () => EagerGestureRecognizer(),
                                          ),
                                        },
                                        mapType: MapType.normal,
                                        initialCameraPosition: CameraPosition(
                                          target: source,
                                          zoom: 14,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId: const MarkerId('source'),
                                            position: source,
                                          ),
                                        },
                                      ),
                                    ),
                                    Text(
                                      _cloudPlace.address!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          _launchUrl(navigation);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.grey,
                                        ),
                                        child: Text(
                                          'Open in GPS',
                                          style: GoogleFonts.actor(
                                            fontSize: 18,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ListView.builder(
                                  itemCount: _cloudPlace.schedule!.keys.length,
                                  itemBuilder: (context, index) {
                                    final day = getCurentDay(index);
                                    final program =
                                        _cloudPlace.schedule![day].toString();
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              width: 90,
                                              child: Center(
                                                child: Text(
                                                  toBeginningOfSentenceCase(
                                                    day,
                                                  )!,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                              child: Text(
                                                ':',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Text(
                                                program,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      Visibility(
                                        visible:
                                            _cloudPlace.description != null,
                                        child: Center(
                                          child: Text(
                                            _cloudPlace.description ?? '',
                                            style:
                                                GoogleFonts.actor(fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 200,
                                        child: ListView.builder(
                                          itemCount: contactList.length,
                                          itemBuilder: (context, index) {
                                            final url =
                                                Uri.parse(contactList[index]);
                                            switch (index) {
                                              case 0:
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        CupertinoIcons.globe),
                                                    TextButton(
                                                      onPressed: () {
                                                        _launchUrl(url);
                                                      },
                                                      child: Text(
                                                        'Check our site!',
                                                        style:
                                                            GoogleFonts.actor(
                                                          fontSize: 18,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              case 1:
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.facebook),
                                                    TextButton(
                                                      onPressed: () {
                                                        _launchUrl(url);
                                                      },
                                                      child: Text(
                                                        'Follow us here!',
                                                        style:
                                                            GoogleFonts.actor(
                                                          fontSize: 18,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              default:
                                                return null;
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      // bottomNavigationBar: const LoggedBottomNavBar(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PlaceDynamicActivities extends StatefulWidget {
  const PlaceDynamicActivities({
    super.key,
    required FirebaseCloudStorage cloudService,
    required CloudPlace cloudPlace,
  })  : _cloudService = cloudService,
        _cloudPlace = cloudPlace;

  final FirebaseCloudStorage _cloudService;
  final CloudPlace _cloudPlace;

  @override
  State<PlaceDynamicActivities> createState() => _PlaceDynamicActivitiesState();
}

class _PlaceDynamicActivitiesState extends State<PlaceDynamicActivities> {
  var _currentDay = DateTime.now().day;

  void _getDayOfMonth(int day) {
    setState(() {
      _currentDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: WeeklyListview(callback: _getDayOfMonth),
        ),
        Expanded(
          child: StreamBuilder(
            stream: widget._cloudService
                .getActivities(givenPlaceId: widget._cloudPlace.id),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    final activities = snapshot.data as Iterable<CloudActivity>;

                    final activitiesCopy = activities
                        .where(
                            (element) => element.timestamp.day == _currentDay)
                        .toList();
                    if (activitiesCopy.isEmpty) {
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

                    activitiesCopy
                        .sort((a, b) => a.timestamp.compareTo(b.timestamp));
                    return ListView.builder(
                      itemCount: activitiesCopy.length,
                      itemBuilder: (context, index) {
                        final activity = activitiesCopy.elementAt(index);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: activity.imageUrl,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      height: 150,
                                      width: 125,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Text(
                                      activity.title,
                                      style: GoogleFonts.actor(
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
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
          ),
        ),
      ],
    );
  }
}

class PlaceStaticActivities extends StatelessWidget {
  const PlaceStaticActivities({
    super.key,
    required FirebaseCloudStorage cloudService,
    required CloudPlace cloudPlace,
  })  : _cloudService = cloudService,
        _cloudPlace = cloudPlace;

  final FirebaseCloudStorage _cloudService;
  final CloudPlace _cloudPlace;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _cloudService.getActivities(givenPlaceId: _cloudPlace.id),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            if (snapshot.hasData) {
              final activities = snapshot.data as Iterable<CloudActivity>;

              if (activities.isEmpty) {
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
                            'Upcoming activities to be uploaded..',
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
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities.elementAt(index);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: activity.imageUrl,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: 100,
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                activity.title,
                                style: GoogleFonts.actor(
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                      ],
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
  }
}

class _CachedContent extends StatefulWidget {
  final Widget child;

  const _CachedContent({required this.child});

  @override
  _CachedContentState createState() => _CachedContentState();
}

class _CachedContentState extends State<_CachedContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.child;
  }
}
