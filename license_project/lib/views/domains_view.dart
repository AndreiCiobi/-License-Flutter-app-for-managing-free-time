import 'package:flutter/material.dart';
import 'package:license_project/helpers/logged/logged_app_bar.dart';
import 'package:license_project/helpers/logged/logged_bottom_nav_bar.dart';
import 'package:license_project/helpers/logged/logged_drawer.dart';
import 'package:license_project/services/cloud/cloud_domain.dart';
import 'package:license_project/services/cloud/firebase_cloud_storage.dart';
import 'package:license_project/utilities/enums/nav_bar.dart';
import 'package:license_project/utilities/routes.dart';
import 'package:license_project/views/domains_grid_view.dart';

import 'dart:developer' as developer;

class DomainsView extends StatefulWidget {
  const DomainsView({super.key});

  @override
  State<DomainsView> createState() => _DomainsViewState();
}

class _DomainsViewState extends State<DomainsView> {
  late final FirebaseCloudStorage _cloudService;

  @override
  void initState() {
    _cloudService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LoggedAppBar(),
      drawer: const LoggedAppDrawer(),
      body: StreamBuilder(
        stream: _cloudService.getAllActivities(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              if (snapshot.hasData) {
                final domains = snapshot.data as Iterable<CloudDomain>;
                return DomainsGridView(
                  domains: domains,
                  onTap: (domain) {
                    Navigator.of(context).pushNamed(
                        domain.hasEvents ? events : places,
                        arguments: domain);
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
