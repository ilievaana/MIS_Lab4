import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final Function(DateTime) onDateSelected;

  CalendarWidget({required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: DateTime.now(),
      firstDay: DateTime(2000),
      lastDay: DateTime(2100),
      onDaySelected: (selectedDay, focusedDay) {
        onDateSelected(selectedDay);
      },
    );
  }
}
