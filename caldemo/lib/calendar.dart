import 'dart:math' as math;
import "package:intl/intl.dart" as intl;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

typedef DayNotifier = ValueNotifier<DateTime?>;

class BookingCalendar extends StatefulWidget {
  BookingCalendar({this.locale,
                  required this.firstDay,
                  required this.lastDay,
                  this.bookingsOnDay,
                  required this.selectedDayNotifier,
                  Key? key}) : super(key: key);
  final String? locale;
  final DateTime firstDay;
  final DateTime lastDay;

  // Return [] if there are not any bookings on the day.
  // Return [n] if there are n bookings on the day.
  // Return [n, 1] if there are n bookings and one of them is mine.
  // Should return the result in O(1) time.
  final List<int> Function(DateTime day)? bookingsOnDay;

  // Change notifier of the selected day (or null)
  final DayNotifier selectedDayNotifier;

  @override
  _BookingCalendarState createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  late final DayNotifier _day; 
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _day = widget.selectedDayNotifier;
  }

  @override
  Widget build(BuildContext context) => TableCalendar<int>(
    locale: widget.locale,
    firstDay: widget.firstDay,
    lastDay: widget.lastDay,
    eventLoader: widget.bookingsOnDay,
    focusedDay: _focusedDay,
    headerStyle: HeaderStyle(formatButtonVisible: false),
    calendarBuilders: CalendarBuilders(
      dowBuilder: _dowBuilder,
      defaultBuilder: _defaultBuilder,
      markerBuilder: _markerBuilder,
    ),
    selectedDayPredicate: (day) => isSameDay(_day.value, day),
    onDaySelected: (selectedDay, focusedDay) => setState(() {
      if (isSameDay(_day.value, selectedDay)) {
        _day.value = null;
      } else {
        _day.value = selectedDay;
      }
      _focusedDay = focusedDay;
    }),
    onPageChanged: (focusedDay) {
      // print("onPageChanged $_focusedDay -> $focusedDay");
      _focusedDay = focusedDay;
    },
  );

  // Create a cell for a given day of week.
  Widget? _dowBuilder(BuildContext context, DateTime day) {
    if (day.weekday == DateTime.saturday) {
      return Center(
        child: Text(
          intl.DateFormat.E(widget.locale).format(day),
          style: TextStyle(color: Colors.blue),
        ));
    } else if (day.weekday == DateTime.sunday) {
      return Center(
        child: Text(
          intl.DateFormat.E(widget.locale).format(day),
          style: TextStyle(color: Colors.red),
        ));
    }
    return null; // Use the default style.
  }
}

// Create a cell for a given day.
Widget? _defaultBuilder(
    BuildContext context, DateTime day, DateTime focusedDay) {
  if (day.weekday == DateTime.saturday) {
    return Center(
        child: Text(
          day.day.toString(),
          style: TextStyle(color: Colors.blue),
        ));
  } else if (day.weekday == DateTime.sunday) {
    return Center(
        child: Text(
          day.day.toString(),
          style: TextStyle(color: Colors.red),
        ));
  }
  return null; // Use the default style.
}

// Create an event marker for a given day.
Widget? _markerBuilder(BuildContext context, DateTime day, List<int> events) {
  if (events.isEmpty) return null;
  int value = events[0];
  bool mine = events.length > 1;
  return AnimatedContainer(
    duration: const Duration(milliseconds: 900),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
       border: (mine ? Border.all(width: 2.0) : null),
      color: Colors.red[math.min(900, value * 100)],
    ),
    height: 16,
    width: (mine ? 24 : 16),
    child: Center(
      child: Text(
        (value < 100) ? value.toString() : "∞",
        style: TextStyle(color: Colors.white, fontSize: 10)
      )
    ),
  );
}
