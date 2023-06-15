import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:license_project/services/auth/bloc/auth_bloc.dart';
import 'package:license_project/services/auth/bloc/auth_event.dart';

class ActivitiesView extends StatefulWidget {
  const ActivitiesView({super.key});

  @override
  State<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            context.read<AuthBloc>().add(const AuthEventLogOut());
          },
          child: const Text('Log out'),
        ),
      ),
    );
  }
}
