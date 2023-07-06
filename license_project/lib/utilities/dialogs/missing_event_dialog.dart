import 'package:flutter/material.dart';

class MissingEventDialog extends StatelessWidget {
  const MissingEventDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Missing Events'),
      content: const Text(
          'There are currently no events available. Check it later!'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
