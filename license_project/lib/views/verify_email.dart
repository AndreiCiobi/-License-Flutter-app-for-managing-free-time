import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_project/helpers/components/containers/auth_background_container.dart';
import 'package:license_project/services/auth/auth_service.dart';
import 'package:license_project/services/auth/bloc/auth_bloc.dart';
import 'package:license_project/services/auth/bloc/auth_event.dart';
import 'package:license_project/utilities/generics/extensions.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final userEmail = AuthService.firebase().currentUser!.email;

  Timer? timer;

  @override
  void initState() {
    timer = Timer.periodic(
      const Duration(seconds: 4),
      (timer) {
        context.read<AuthBloc>().add(
              const AuthEventLogInAfterVerification(),
            );
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = context.getWidth();
    final height = context.getHeight();

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundContainer(),
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: height * 0.05),
                  Text(
                    textAlign: TextAlign.center,
                    'Check your \n Email',
                    style: GoogleFonts.actor(
                      fontSize: height * 0.04,
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  Text(
                    'We have sent you an email to $userEmail',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.actor(
                      fontSize: height * 0.03,
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                  const CircularProgressIndicator(
                    color: Colors.black,
                  ),
                  SizedBox(height: height * 0.025),
                  Text(
                    'Verifying email...',
                    style: GoogleFonts.actor(),
                  ),
                  SizedBox(height: height * 0.07),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventSendEmailVerification(),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      fixedSize: Size(width * 0.35, height * 0.075),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Resend',
                      style: GoogleFonts.actor(
                        color: Colors.black,
                        fontSize: height * 0.025,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
