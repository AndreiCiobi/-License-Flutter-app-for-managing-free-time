import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_project/helpers/components/buttons/auth_google_button.dart';
import 'package:license_project/helpers/components/containers/auth_background_container.dart';
import 'package:license_project/services/auth/auth_exceptions.dart';
import 'package:license_project/services/auth/bloc/auth_bloc.dart';
import 'package:license_project/services/auth/bloc/auth_event.dart';
import 'package:license_project/services/auth/bloc/auth_state.dart';
import 'package:license_project/utilities/auth/register_validator.dart';
import 'package:license_project/utilities/dialogs/error_dialog.dart';
import 'package:license_project/utilities/generics/extensions.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late FocusNode _passwordNode;
  late FocusNode _emailNode;
  bool _obscureText = true;
  bool _tappedEmail = false;
  bool _tappedPassword = false;
  bool _focusedPassword = false;
  bool _focusedEmail = false;
  final registerValidator = RegisterValidator();

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _password.addListener(() {
      setState(() {});
    });
    _email.addListener(() {
      setState(() {});
    });
    _passwordNode = FocusNode();
    _emailNode = FocusNode();
    _emailNode.addListener(_handleFocusChange);
    _passwordNode.addListener(_handleFocusChange);
    super.initState();
  }

  void _handleFocusChange() {
    if (_passwordNode.hasFocus) {
      setState(() {
        _tappedPassword = true;
        _focusedPassword = true;
      });
    } else {
      setState(() {
        _focusedPassword = false;
      });
    }

    if (_emailNode.hasFocus) {
      setState(() {
        _tappedEmail = true;
        _focusedEmail = true;
      });
    } else {
      setState(() {
        _focusedEmail = false;
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordNode.dispose();
    _emailNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = context.getWidth();
    final height = context.getHeight();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          _password.clear();
          _tappedEmail = _tappedPassword = false;
          _email.clear();
          if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email is already in use');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Failed to register');
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
              'Create Account',
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
                            onTap: () {
                              _focusedEmail
                                  ? _emailNode.unfocus()
                                  : _emailNode.requestFocus();
                            },
                            focusNode: _emailNode,
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
                                borderSide: BorderSide(
                                  color: _tappedEmail &&
                                          !registerValidator
                                              .isEmailValid(_email.text)
                                      ? Colors.red.shade800
                                      : Colors.white70,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.white70,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              errorText: _focusedEmail
                                  ? registerValidator
                                      .validateEmailResponse(_email.text)
                                  : null,
                              errorMaxLines: 2,
                              errorStyle:
                                  GoogleFonts.actor(color: Colors.red.shade800),
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
                            onTap: () {
                              _focusedPassword
                                  ? _passwordNode.unfocus()
                                  : _passwordNode.requestFocus();
                            },
                            focusNode: _passwordNode,
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
                                borderSide: BorderSide(
                                  color: _tappedPassword &&
                                          !registerValidator
                                              .isPasswordValid(_password.text)
                                      ? Colors.red.shade800
                                      : Colors.white70,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.white70,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.white70,
                                ),
                              ),
                              errorText: _focusedPassword
                                  ? registerValidator
                                      .validatePasswordResponse(_password.text)
                                  : null,
                              errorMaxLines: 2,
                              errorStyle:
                                  GoogleFonts.actor(color: Colors.red.shade800),
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
                          SizedBox(height: height * 0.065),
                          ElevatedButton(
                            onPressed: registerValidator.areCredentialsValid(
                              _email.text,
                              _password.text,
                            )
                                ? () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();

                                    final email = _email.text.trim();
                                    final password = _password.text.trim();
                                    context.read<AuthBloc>().add(
                                          AuthEventRegister(
                                            email: email,
                                            password: password,
                                          ),
                                        );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              fixedSize: Size(
                                width * 0.65,
                                height * 0.075,
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black.withOpacity(0.8),
                              disabledBackgroundColor: Colors.white,
                              disabledForegroundColor: Colors.black26,
                              textStyle: TextStyle(
                                fontSize: width * 0.05,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: Text(
                              'Create account',
                              style: GoogleFonts.actor(),
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
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
                                        const AuthEventShouldLogIn(),
                                      );
                                },
                                child: Text(
                                  'Log In',
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
