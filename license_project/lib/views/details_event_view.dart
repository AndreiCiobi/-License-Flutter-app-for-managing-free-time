import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:license_project/services/cloud/cloud_event.dart';
import 'package:license_project/utilities/generics/calendar.dart';
import 'package:license_project/utilities/generics/extensions.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsEventView extends StatefulWidget {
  const DetailsEventView({super.key});

  @override
  State<DetailsEventView> createState() => _DetailsEventViewState();
}

class _DetailsEventViewState extends State<DetailsEventView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late CloudEvent _cloudEvent;
  late TabController _tabController;

  Future<void> _launchUrl(Uri uri) async {
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _cloudEvent = context.getArgument<CloudEvent>()!;
    final LatLng source = LatLng(_cloudEvent.latitude, _cloudEvent.longitude);
    final navigation =
        Uri.parse('google.navigation:q=${source.latitude},${source.longitude}');

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final remainingHeight = constraints.biggest.height;
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: remainingHeight * 0.3,
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: const Color.fromARGB(255, 220, 140, 164),
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _cloudEvent.name,
                    style: GoogleFonts.actor(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                background: Hero(
                  tag: _cloudEvent.id,
                  child: Image.network(
                    _cloudEvent.imageUrl,
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
                          icon: Icon(CupertinoIcons.info),
                        ),
                        Tab(
                          icon: Icon(CupertinoIcons.map),
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
                        height: remainingHeight * 0.59,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Icons.calendar_month_outlined,
                                          color: Colors.redAccent,
                                        ),
                                        Text(
                                          eventFormatDate(
                                              _cloudEvent.timestamp),
                                          style: GoogleFonts.actor(
                                            fontSize: 20,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _cloudEvent.description,
                                    style: GoogleFonts.actor(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _launchUrl(
                                          Uri.parse(_cloudEvent.contact));
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    child: Text(
                                      'For tickets and more details',
                                      style: GoogleFonts.actor(
                                        fontSize: 18,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                    _cloudEvent.address,
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
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
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
      }),
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
