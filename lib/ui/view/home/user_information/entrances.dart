import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:unity_checkin/ui/model/people.dart';

import '../calendar_page_view.dart';

class Entrances extends StatelessWidget {
  final String userID;
  Entrances(this.userID);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
        ),
        title: Text('Giriş Çıkışlar'),
      ),
      body: SafeArea(
        child: EntrancesBody(userID),
      ),
    );
  }
}

class EntrancesBody extends StatefulWidget {
  final String userID;
  EntrancesBody(this.userID);

  @override
  _EntrancesBodyState createState() => _EntrancesBodyState(userID);
}

class _EntrancesBodyState extends State<EntrancesBody> {
  List<People> meetings;
  String myCompanyDbRegisters;

  String userID;
  _EntrancesBodyState(this.userID);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
    super.initState();
  }

  _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      myCompanyDbRegisters = prefs.getString(dbRegisters) != null
          ? prefs.getString(dbRegisters)
          : "";

      meetings = new List<People>();
      FirebaseFirestore.instance.collection(myCompanyDbRegisters).where('process', isEqualTo: 'in').where('userID', isEqualTo: userID).get().then((value) {
        value.docs.forEach((document) {
          Timestamp time = document.get('time');
          var date = DateTime.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);

          FirebaseFirestore.instance.collection(myCompanyDbRegisters).where('userID', isEqualTo: userID).where('date', isEqualTo: document.get('date')).where('process', isEqualTo: 'out').get().then((value) {
            Timestamp timeEnd = value.docs.first.get('time');
            var dateEnd = DateTime.fromMillisecondsSinceEpoch(timeEnd.millisecondsSinceEpoch);
            meetings.add(People('Yunus Karaaslan', date, dateEnd, const Color(0xFF0F8644), false));

            setState(() {
              meetings = meetings;
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      allowedViews: [
        CalendarView.schedule,
        CalendarView.day,
        CalendarView.week,
        CalendarView.month,
        CalendarView.timelineDay,
        CalendarView.timelineWorkWeek,
        CalendarView.timelineWeek,
        CalendarView.timelineMonth,
      ],
      showDatePickerButton: true,
      allowViewNavigation: true,
      view: CalendarView.month,
      dataSource: MeetingDataSource(meetings),
      firstDayOfWeek: 1,
      initialSelectedDate: DateTime.now(),
      timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 0,
          endHour: 24,
          nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
      monthViewSettings: MonthViewSettings(
          showAgenda: true,
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          appointmentDisplayCount: 4),
      onLongPress: (index) {
        Navigator.push(context, new MaterialPageRoute(builder: (context) => new CalendarPageView(date: index.date)));
      },
    );
  }
}

