import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_project/services/auth/bloc/auth_bloc.dart';
import 'package:license_project/services/auth/bloc/auth_event.dart';
import 'package:license_project/utilities/generics/device_size.dart';

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = context.getWidth();
    final height = context.getHeight();

    return OutlinedButton(
      onPressed: () async {
        context.read<AuthBloc>().add(const AuthEventSignInWithGoogle());
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        fixedSize: Size(width * 0.65, height * 0.075),
      ),
      child: Row(
        children: [
          Image(
            image: const AssetImage('assets/images/google_logo.png'),
            height: height * 0.05,
          ),
          Padding(
            padding: EdgeInsets.only(left: width * 0.025),
            child: Text(
              'Continue with Google',
              style: GoogleFonts.actor(
                fontSize: width * 0.042,
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
