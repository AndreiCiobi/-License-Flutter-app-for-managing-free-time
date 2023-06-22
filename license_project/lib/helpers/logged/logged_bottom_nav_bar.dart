import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:license_project/utilities/enums/nav_bar.dart';
import 'package:license_project/views/favourites_view.dart';

import 'dart:developer' as dev;

class LoggedBottomNavBar extends StatefulWidget {
  final NavBarChoice choice;

  const LoggedBottomNavBar({super.key, required this.choice});

  @override
  State<LoggedBottomNavBar> createState() => _LoggedBottomNavBarState();
}

class _LoggedBottomNavBarState extends State<LoggedBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black38,
          spreadRadius: 0,
          blurRadius: 10,
        ),
      ]),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.heart_circle_fill),
              label: 'Your Favourites',
            ),
          ],
          currentIndex: widget.choice.index,
          backgroundColor: const Color.fromARGB(255, 220, 140, 164),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.popUntil(
                  context,
                  (route) => route.settings.name == '/',
                );
              case 1:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavouritesView(),
                  ),
                  ModalRoute.withName('/'),
                );
            }
          },
        ),
      ),
    );
  }
}
