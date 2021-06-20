import 'package:table_calendar/table_calendar.dart';

String? _lastUserId = null;
String? _lastPassword = null;

Map<DateTime, Map<String, String>> _bookings = {
  DateTime.utc(2021, 6, 11): {"aaa": "AAA"},
  DateTime.utc(2021, 6, 21): {"aaa": "AAA"},
  DateTime.utc(2021, 6, 23): {"aaa": "AAA"},
  DateTime.utc(2021, 7, 7): {"aaa": "AAA"},
  DateTime.utc(2021, 7, 13): {"aaa": "AAA"},
};

List<int> bookingsOnDay(DateTime day) {
  Map<String, String>? b = _bookings[day];
  if (b == null) return [];
  if (_lastUserId != null) {
    var pw = b[_lastUserId];
    if (pw != null && pw == _lastPassword) {
      return [b.length, 1];
    }
  }
  return [b.length];
}

bool makeBooking(DateTime day, String userId, String password) {
  day = normalizeDate(day);
  _lastUserId = userId;
  _lastPassword = password;

  Map<String, String>? b = _bookings[day];
  if (b == null) {              // Create a new book for the day.
    _bookings[day] = {userId: password};
    return true;
  }
  var pw = b[userId];

  print("pw = $pw, password = $password");

  if (pw == null) {             // Add a booking to the book for the day.
    b[userId] = password;
    return true;
  }
  return false;
}

bool deleteBooking(DateTime day, String userId, String password) {
  day = normalizeDate(day);
  _lastUserId = userId;
  _lastPassword = password;

  Map<String, String>? b = _bookings[day];
  if (b == null) return false;

  var pw = b[userId];
  if (pw == null) return false;

  if (pw != password) return false;

  b.remove(userId);
  return true;
}
