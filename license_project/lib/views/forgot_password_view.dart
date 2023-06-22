import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_project/helpers/components/containers/auth_background_container.dart';
import 'package:license_project/services/auth/bloc/auth_bloc.dart';
import 'package:license_project/services/auth/bloc/auth_event.dart';
import 'package:license_project/services/auth/bloc/auth_state.dart';
import 'package:license_project/utilities/dialogs/error_dialog.dart';
import 'package:license_project/utilities/dialogs/password_reset_dialog.dart';
import 'package:license_project/utilities/generics/extensions.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = context.getHeight();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(
              context,
              'We could not process your request. Please make sure that you are a registered user, or if not, register now!',
            );
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              const BackgroundContainer(),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.05),
                        Text(
                          textAlign: TextAlign.center,
                          'Forgot Password',
                          style: GoogleFonts.actor(
                            fontSize: height * 0.04,
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        TextField(
                          controller: _controller,
                          enableSuggestions: false,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.black.withOpacity(0.65),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white70,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white70,
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Your email address',
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.65),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: height * 0.02,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _controller.text.trim().isEmpty
                              ? null
                              : () {
                                  final email = _controller.text.trim();
                                  context.read<AuthBloc>().add(
                                      AuthEventForgotPassword(email: email));
                                },
                          child: Text(
                            'Send me a password reset link',
                            style: GoogleFonts.actor(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.1),
                        TextButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            context.read<AuthBloc>().add(
                                  const AuthEventLogOut(),
                                );
                          },
                          child: Text(
                            'Back to login page',
                            style: GoogleFonts.actor(
                              color: Colors.black,
                              fontSize: height * 0.03,
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
        ),
      ),
    );
  }
}
