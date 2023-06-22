import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:license_project/helpers/components/containers/auth_background_container.dart';
import 'package:license_project/helpers/loading/loading_screen.dart';
import 'package:license_project/services/auth/bloc/auth_bloc.dart';
import 'package:license_project/services/auth/bloc/auth_event.dart';
import 'package:license_project/services/auth/bloc/auth_state.dart';
import 'package:license_project/services/auth/firebase_auth_provider.dart';
import 'package:license_project/utilities/routes.dart';
import 'package:license_project/views/details_event_view.dart';
import 'package:license_project/views/domains_view.dart';
import 'package:license_project/views/details_place_view.dart';
import 'package:license_project/views/events_view.dart';
import 'package:license_project/views/favourites_view.dart';
import 'package:license_project/views/forgot_password_view.dart';
import 'package:license_project/views/login_view.dart';
import 'package:license_project/views/places_view.dart';
import 'package:license_project/views/register_view.dart';
import 'package:license_project/views/verify_email.dart';
import 'package:license_project/views/welcome_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      title: 'Your City',
      theme: ThemeData(
        // primaryColor: const Color.fromARGB(255, 194, 23, 80),
        // scaffoldBackgroundColor: const Color.fromARGB(255, 213, 208, 192),
        // scaffoldBackgroundColor: Colors.deepPurple,
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Colors.greenAccent,
          cursorColor: Colors.grey,
          selectionColor: Colors.amber,
        ),
        splashColor: Colors.transparent,
        primarySwatch: Colors.grey,
        highlightColor: Colors.transparent,
      ),

      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(FirebaseAuthProvider()),
          ),
        ],
        child: const HomePage(),
      ),
      routes: {
        places: (context) => const PlacesView(),
        detailsPlace: (context) => const DetailsPlaceView(),
        favourites: (context) => const FavouritesView(),
        events: (context) => const EventsView(),
        detailsEvent: (context) => const DetailsEventView(),
      },
      // home: const WelcomeView(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment..',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedOut) {
          return const WelcomeView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateLoggingIn) {
          return const LoginView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateLoggedIn) {
          return const DomainsView();
        } else {
          return const Scaffold(
            body: Stack(
              children: [
                BackgroundContainer(),
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );

    // return const WelcomeView();
  }
}
