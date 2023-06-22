import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:license_project/services/cloud/cloud_activity.dart';
import 'package:license_project/services/cloud/cloud_place.dart';
import 'package:license_project/services/cloud/firebase_cloud_storage.dart';
import 'package:license_project/utilities/generics/calendar.dart';
import 'package:license_project/utilities/generics/extensions.dart';
import 'package:sliver_tools/sliver_tools.dart';
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _cloudPlace = context.getArgument<CloudPlace>()!;
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
                  title: FittedBox(
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
                        tabs: const [
                          Tab(
                            icon: Icon(CupertinoIcons.square_list),
                          ),
                          Tab(
                            icon: Icon(CupertinoIcons.map),
                          ),
                          Tab(
                            icon: Icon(Icons.schedule_outlined),
                          ),
                          Tab(
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
                              StreamBuilder(
                                stream: _cloudService.getActivities(
                                    givenPlaceId: _cloudPlace.id),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.active:
                                      if (snapshot.hasData) {
                                        final activities = snapshot.data
                                            as Iterable<CloudActivity>;
                                        return ListView.builder(
                                          itemCount: activities.length,
                                          itemBuilder: (context, index) {
                                            final activity =
                                                activities.elementAt(index);

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    leading: Container(
                                                      width: 100,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              activity
                                                                  .imageUrl),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      activity.title,
                                                      style: GoogleFonts.actor(
                                                        fontSize: 20,
                                                      ),
                                                    ),
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
                                              child: Text(
                                                ':',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              child: Text(
                                                program,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
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
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Visibility(
                                      visible: _cloudPlace.description != null,
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
                                                      style: GoogleFonts.actor(
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
                                                      style: GoogleFonts.actor(
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
