import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_project/helpers/components/containers/auth_background_container.dart';
import 'package:license_project/services/auth/bloc/auth_bloc.dart';
import 'package:license_project/services/auth/bloc/auth_event.dart';
import 'package:license_project/utilities/generics/extensions.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
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
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.025),
                    LogoContainer(deviceSize: context.getSize()),
                    SizedBox(height: height * 0.05),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthEventShouldRegister(),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        fixedSize: Size(width * 0.65, height * 0.085),
                        backgroundColor: Colors.white.withOpacity(0.8),
                        side: const BorderSide(width: 1.0, color: Colors.grey),
                        textStyle: TextStyle(
                          fontSize: width * 0.055,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.actor(
                          color: const Color.fromARGB(255, 214, 169, 76),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthEventShouldLogIn(),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        fixedSize: Size(width * 0.65, height * 0.085),
                        backgroundColor: Colors.white.withOpacity(0.8),
                        side: const BorderSide(width: 1.0, color: Colors.grey),
                        textStyle: TextStyle(
                          fontSize: width * 0.055,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: Text(
                        'Log In',
                        style: GoogleFonts.actor(
                          color: const Color.fromARGB(255, 214, 169, 76),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoContainer extends StatelessWidget {
  const LogoContainer({
    required this.deviceSize,
    super.key,
  });

  final Size deviceSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: deviceSize.width * 0.65,
      height: deviceSize.height * 0.35,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/bucharest.png'),
          fit: BoxFit.contain,
        ),
        border: Border.all(color: Colors.grey),
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
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          'Your',
          style: GoogleFonts.antic(
              fontSize: deviceSize.width * 0.085,
              color: const Color.fromARGB(255, 214, 169, 76),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300),
        ),
      ),
    );
  }
}
