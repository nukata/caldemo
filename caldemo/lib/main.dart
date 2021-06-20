import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'calendar.dart';
import 'bookings.dart';

main() async {
  await initializeDateFormatting();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking Calendar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyAppPage(title: '予約カレンダー デモ'),
    );
  }
}

class MyAppPage extends StatefulWidget {
  const MyAppPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyAppPageState createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {
  final _formKey = GlobalKey<FormState>();
  final DayNotifier _day = DayNotifier(null); // the selected day (or null)
  bool _hidePassword = false;
  String? _userId;
  String? _password;

  @override
  void initState() {
    super.initState();
    _day.addListener(() => setState(() {
      // print("_day.value is ${_day.value}");
    }));
  }

  static String _toS(DayNotifier day) =>
    "${day.value?.year}年${day.value?.month}月${day.value?.day}日";

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Column(
      children: <Widget>[
        BookingCalendar(
          locale: "ja_JP",
          firstDay: DateTime.utc(2021, 6, 1),
          lastDay: DateTime.utc(2021, 8, 31),
          bookingsOnDay: bookingsOnDay,
          selectedDayNotifier: _day,
        ),
        Container(
          height: 10,
        ),
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Text((_day.value == null) ? "　" : _toS(_day)), 
                Container(height: 10),
                TextFormField(
                  enabled: (_day.value != null),
                  onSaved: (text) {
                    _userId = text;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: "ユーザ ID",
                  ),
                ),
                TextFormField(
                  enabled: (_day.value != null),
                  onSaved: (text) {
                    _password = text;
                  },
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: "パスワード",
                    suffixIcon: IconButton(
                      icon: Icon(_hidePassword
                                 ? Icons.visibility_off_rounded
                                 : Icons.visibility_rounded),
                      onPressed: () => setState(() {
                        _hidePassword = ! _hidePassword;
                      }),
                    ),
                  ),
                ),
                Container(height: 10),
                ElevatedButton(
                  child: Text((_day.value != null &&
                                bookingsOnDay(_day.value!).length > 1)
                               ? "予約取消し"
                               : "予約"),
                  onPressed: (_day.value == null) ? null : () => setState(() {
                    var formState = _formKey.currentState;
                    if (formState != null) {
                      formState.save();
                      bool mine = bookingsOnDay(_day.value!).length > 1;
                      bool ok;
                      if (mine) {
                        ok = deleteBooking(_day.value!, _userId!, _password!);
                      } else {
                        ok = makeBooking(_day.value!, _userId!, _password!);
                      }
                      var msg = ok ?
                         (mine ? "予約を取り消しています" : "予約しています") :
                         (mine ? "予約を取り消けませんでした" : "予約できませんでした");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("$msg: $_userId " + _toS(_day))
                        ),
                      );
                      _hidePassword = true;
                      _day.value = null; // Notify the BookingCalendar.
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
