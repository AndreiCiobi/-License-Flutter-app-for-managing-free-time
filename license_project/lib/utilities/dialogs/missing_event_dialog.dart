import 'package:flutter/material.dart';

class MissingEventDialog extends StatelessWidget {
  const MissingEventDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Missing Events'),
      content: Text('There are currently no events available. Check it later!'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Ok'),
        ),
      ],
    );
  }
}
