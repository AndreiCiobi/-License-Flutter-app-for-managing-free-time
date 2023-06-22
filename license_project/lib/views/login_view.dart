import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_project/helpers/components/buttons/auth_google_button.dart';
import 'package:license_project/helpers/components/containers/auth_background_container.dart';
import 'package:license_project/services/auth/auth_exceptions.dart';
import 'package:license_project/services/auth/bloc/auth_bloc.dart';
import 'package:license_project/services/auth/bloc/auth_event.dart';
import 'package:license_project/services/auth/bloc/auth_state.dart';
import 'package:license_project/utilities/dialogs/error_dialog.dart';
import 'package:license_project/utilities/generics/extensions.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _obscureText = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _email.addListener(() {
      setState(() {});
    });
    _password.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = context.getWidth();
    final height = context.getHeight();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggingIn) {
          _email.clear();
          _password.clear();
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              'Cannot find a user with the entered credential!',
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 220, 140, 164),
            title: Text(
              'Welcome Back!',
              style: GoogleFonts.actor(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: width * 0.085,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    );
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: height * 0.03,
              ),
            ),
          ),
          body: Stack(
            children: [
              const BackgroundContainer(),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.05),
                          const AuthGoogleButton(),
                          SizedBox(height: height * 0.025),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  child: const Divider(
                                    color: Colors.white70,
                                    thickness: 2,
                                  ),
                                ),
                              ),
                              Text(
                                'or',
                                style: GoogleFonts.actor(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: const Divider(
                                    color: Colors.white70,
                                    thickness: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.025),
                          TextField(
                            controller: _email,
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
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.65),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: height * 0.02,
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.015),
                          TextField(
                            controller: _password,
                            obscureText: _obscureText,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.black.withOpacity(0.65),
                              ),
                              suffixIcon: _password.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(_obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      color: Colors.black.withOpacity(0.65),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    )
                                  : null,
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
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.65),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: height * 0.02,
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          Container(
                            margin: EdgeInsets.only(left: width * 0.33),
                            child: TextButton(
                              onPressed: () {
                                context
                                    .read<AuthBloc>()
                                    .add(const AuthEventForgotPassword());
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.actor(
                                  fontSize: width * 0.04,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed:
                                _password.text.isEmpty || _email.text.isEmpty
                                    ? null
                                    : () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        final email = _email.text.trim();
                                        final password = _password.text.trim();
                                        context.read<AuthBloc>().add(
                                              AuthEventLogIn(
                                                email: email,
                                                password: password,
                                              ),
                                            );
                                      },
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              fixedSize: Size(
                                width * 0.65,
                                height * 0.075,
                              ),
                              disabledBackgroundColor: Colors.white,
                              disabledForegroundColor: Colors.black26,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black.withOpacity(0.8),
                              textStyle: TextStyle(
                                fontSize: width * 0.05,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: Text(
                              'Log In',
                              style: GoogleFonts.actor(),
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: GoogleFonts.actor(
                                  fontSize: width * 0.04,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                  right: 5,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.read<AuthBloc>().add(
                                        const AuthEventShouldRegister(),
                                      );
                                },
                                child: Text(
                                  'Create Account',
                                  style: GoogleFonts.actor(
                                    fontSize: width * 0.04,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom + 20,
                          ),
                        ],
                      ),
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
