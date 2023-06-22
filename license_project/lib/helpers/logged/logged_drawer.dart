import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_project/services/auth/bloc/auth_bloc.dart';
import 'package:license_project/services/auth/bloc/auth_event.dart';
import 'package:license_project/utilities/dialogs/logout_dialog.dart';

class LoggedAppDrawer extends StatelessWidget {
  const LoggedAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Container(
              width: 65,
              height: 50,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/bucharest.png'),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.8),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black26,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Text(
                  'Your',
                  style: GoogleFonts.antic(
                      fontSize: 8,
                      color: const Color.fromARGB(255, 214, 169, 76),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 220, 140, 164),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: Text(
              'Logout',
              style: GoogleFonts.actor(
                fontSize: 18,
              ),
            ),
            onTap: () async {
              final shouldLogout = await showLogOutDialog(context);
              if (shouldLogout) {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              }
            },
          ),
        ],
      ),
    );
  }
}
