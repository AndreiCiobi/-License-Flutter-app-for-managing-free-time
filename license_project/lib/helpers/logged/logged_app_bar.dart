import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoggedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LoggedAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.5);
}
