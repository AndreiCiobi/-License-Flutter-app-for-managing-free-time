import 'package:flutter/material.dart';
import 'package:license_project/utilities/generics/calendar.dart';

class WeeklyListview extends StatefulWidget {
  final Function(int) callback;
  const WeeklyListview({super.key, required this.callback});

  @override
  State<WeeklyListview> createState() => _WeeklyListviewState();
}

class _WeeklyListviewState extends State<WeeklyListview> {
  int _selectedIndex = 0;

  void _sendDayOfMonth() {
    final day = DateTime.now().day + _selectedIndex;
    widget.callback(day);
  }

  @override
  Widget build(BuildContext context) {
    final currentTimestamp = DateTime.now();
    List<DateTime> weeklyTimestamp = [
      for (var i = 0; i < 7; ++i)
        currentTimestamp.add(
          Duration(days: i),
        ),
    ];

    return ListView.builder(
      itemCount: weeklyTimestamp.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final crtTimestamp = weeklyTimestamp[index];
        return Container(
          width: 100,
          color: const Color.fromARGB(150, 220, 140, 164),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
                _sendDayOfMonth();
              });
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: _selectedIndex == index
                    ? const BorderSide(
                        color: Colors.black38,
                      )
                    : BorderSide.none,
              ),
              color: const Color.fromARGB(150, 220, 140, 164),
              elevation: _selectedIndex == index ? 8 : 0,
              child: Container(
                color: _selectedIndex == index
                    ? const Color.fromARGB(255, 220, 140, 164)
                    : const Color.fromARGB(0, 220, 140, 164),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatDate(crtTimestamp),
                      style: TextStyle(
                        color: _selectedIndex == index
                            ? Colors.white
                            : Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
