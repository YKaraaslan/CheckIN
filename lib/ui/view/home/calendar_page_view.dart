import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:unity_checkin/core/widgets/somethings_went_wrong.dart';

import 'user_information/user_profile.dart';

class CalendarPageView extends StatefulWidget {
  final DateTime date;

  CalendarPageView({@required this.date});

  @override
  _CalendarPageViewState createState() => _CalendarPageViewState();
}

class _CalendarPageViewState extends State<CalendarPageView> {
  DateTime now = DateTime.now();
  String myID = "";
  String myCompanyID = "",
      myCompanyDbRegisters = "",
      myCompanyUsers = "",
      dbRegistersString = "",
      myCompanyExcuses = "";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      myID = prefs.getString(my_id);
      myCompanyID = prefs.getString(my_company_id) != null
          ? prefs.getString(my_company_id)
          : "";
      myCompanyDbRegisters = prefs.getString(dbRegisters) != null
          ? prefs.getString(dbRegisters)
          : "";
      myCompanyUsers =
          prefs.getString(dbUsers) != null ? prefs.getString(dbUsers) : "";
      myCompanyExcuses =
          prefs.getString(dbExcuses) != null ? prefs.getString(dbExcuses) : "";
    });
  }

  Widget date() {
    var formatter = new DateFormat('dd MMMM yyyy');
    String _dateToday = formatter.format(widget.date);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0), //(x,y)
            blurRadius: 20.0,
          ),
        ],
      ),
      child: Text(
        '$_dateToday',
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 17, color: Colors.black54),
      ),
    );
  }

  Widget entrances() {
    var formatter = new DateFormat('dd/MM/yyyy');
    String _date = formatter.format(widget.date);
    if (myCompanyID.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4,
          margin: EdgeInsets.all(0),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, top: 15, bottom: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Girişler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(myCompanyDbRegisters)
                    .where('date', isEqualTo: _date)
                    .where('process', isEqualTo: 'in')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SomethingWentWrong(snapshot.error.toString());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data.docs.length == 0) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20, top: 10),
                        child: Text(
                          'Bugüne ait giriş kaydı bulunmamaktadır',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection(appUsers)
                            .doc(snapshot.data.docs[index][user_id].toString())
                            .get(),
                        builder: (c, s) {
                          try {
                            Map<String, dynamic> data = s.data.data();

                            if (data == null) {
                              return Container();
                            }

                            if (s.connectionState == ConnectionState.done) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              new UserEntranceInformation(
                                                  data[user_id])));
                                },
                                child: ListTile(
                                  leading: ClipOval(
                                    child: Image.network(data[image_link],
                                        width: 50),
                                  ),
                                  title: Text(
                                      data['name'] + " " + data['surname']),
                                  subtitle: Wrap(
                                    children: [
                                      Text('Giriş Saati: '),
                                      Text(
                                        _getTimeForUserEntrance(snapshot
                                            .data.docs[index]
                                            .get('time')),
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    _timeAgo(
                                        snapshot.data.docs[index].get('time')),
                                    style: TextStyle(
                                        color: _timeAgoColor(snapshot
                                            .data.docs[index]
                                            .get('time'))),
                                  ),
                                ),
                              );
                            }
                          } catch (ex) {}
                          return Container();
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget exits() {
    var formatter = new DateFormat('dd/MM/yyyy');
    String _date = formatter.format(widget.date);
    if (myCompanyID.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4,
          margin: EdgeInsets.all(0),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, top: 15, bottom: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Çıkışlar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(myCompanyDbRegisters)
                    .where('date', isEqualTo: _date)
                    .where('process', isEqualTo: 'out')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SomethingWentWrong(snapshot.error.toString());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data.docs.length == 0) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 10),
                        child: Text(
                          'Bugüne ait çıkış kaydı bulunmamaktadır',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection(appUsers)
                            .doc(snapshot.data.docs[index][user_id].toString())
                            .get(),
                        builder: (c, s) {
                          try {
                            Map<String, dynamic> data = s.data.data();

                            if (data == null) {
                              return Container();
                            }

                            if (s.connectionState == ConnectionState.done) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              new UserEntranceInformation(
                                                  data[user_id])));
                                },
                                child: ListTile(
                                  leading: ClipOval(
                                    child: Image.network(data[image_link],
                                        width: 50),
                                  ),
                                  title: Text(
                                      data['name'] + " " + data['surname']),
                                  subtitle: Wrap(
                                    children: [
                                      Text('Çıkış Saati: '),
                                      Text(
                                        _getTimeForUserEntrance(snapshot
                                            .data.docs[index]
                                            .get('time')),
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    _timeAgoExits(
                                        snapshot.data.docs[index].get('time')),
                                    style: TextStyle(
                                        color: _timeAgoExitsColor(snapshot
                                            .data.docs[index]
                                            .get('time'))),
                                  ),
                                ),
                              );
                            }
                          } catch (ex) {}
                          return Container();
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget excusesWidget() {
    if (myCompanyDbRegisters != null && myCompanyDbRegisters.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4,
          margin: EdgeInsets.all(0),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, top: 15, bottom: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mazeretler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ExcusesWidgetsPart(myCompanyExcuses, widget.date),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.chevron_left,
              color: Colors.white,
            )),
        title: Container(
          child: Text(
            'Giriş Çıkış Durumları',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              date(),
              entrances(),
              exits(),
              excusesWidget(),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeForUserEntrance(Timestamp timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    var formatter = new DateFormat('HH:mm');
    return formatter.format(date);
  }

  String _timeAgo(Timestamp timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    DateTime dateWorkBegin =
        new DateTime(date.year, date.month, date.day, 08, 00, 00);
    var difference = dateWorkBegin.difference(date).inMinutes;

    var absDifference = difference.abs();
    if (absDifference <= 1) {
      return "1 dakika";
    } else if (absDifference < 60) {
      return "$absDifference dakika";
    } else if (absDifference < 1440) {
      int res = (absDifference / 60).round();
      return "$res saat";
    } else {
      int res = (absDifference / 1440).round();
      return "$res gün";
    }
  }

  Color _timeAgoColor(Timestamp timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    DateTime dateWorkBegin =
        new DateTime(date.year, date.month, date.day, 08, 00, 00);
    var difference = dateWorkBegin.difference(date).inMinutes;

    if (difference.isNegative) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  String _timeAgoExits(Timestamp timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    DateTime dateWorkBegin =
        new DateTime(date.year, date.month, date.day, 18, 30, 00);
    var difference = dateWorkBegin.difference(date).inMinutes;

    var absDifference = difference.abs();
    if (absDifference <= 1) {
      return "1 dakika";
    } else if (absDifference < 60) {
      return "$absDifference dakika";
    } else if (absDifference < 1410) {
      int res = (absDifference / 60).round();
      return "$res saat";
    } else {
      int res = (absDifference / 1440).round();
      return "$res gün";
    }
  }

  Color _timeAgoExitsColor(Timestamp timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    DateTime dateWorkBegin =
        new DateTime(date.year, date.month, date.day, 18, 30, 00);
    var difference = dateWorkBegin.difference(date).inMinutes;

    if (difference.isNegative) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}

class ExcusesWidgetsPart extends StatefulWidget {
  final String myCompanyDbExcuses;
  final DateTime date;

  ExcusesWidgetsPart(this.myCompanyDbExcuses, this.date);

  @override
  _ExcusesWidgetsPartState createState() =>
      _ExcusesWidgetsPartState(myCompanyDbExcuses, date);
}

class _ExcusesWidgetsPartState extends State<ExcusesWidgetsPart> {
  final String myCompanyDbExcuses;
  DateTime date;

  _ExcusesWidgetsPartState(this.myCompanyDbExcuses, this.date);

  List<Excuses> excusesList = new List<Excuses>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (excusesList.length == 0 || excusesList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15.0, top: 5),
          child: Text(
            'Bugüne ait mazeret kaydı bulunmamaktadır.',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: excusesList.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              leading: ClipOval(
                child: Image(
                  image: NetworkImage(excusesList[index].userImageLink),
                  width: 50,
                ),
              ),
              title: Text(excusesList[index].userName),
              subtitle: Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: Text(excusesList[index].excuse),
              ),
              trailing: excusesList[index].status == "ok"
                  ? Icon(
                Icons.check,
                size: 17,
                color: Colors.green,
              )
                  : Icon(
                Icons.close,
                size: 17,
                color: Colors.red,
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 80, bottom: 10),
              child: excusesList[index].status == "ok"
                  ? Text(
                excusesList[index].statusHandledBy +
                    " - " +
                    excusesList[index].statusHandledTime,
                style: TextStyle(fontSize: 13, color: Colors.blue[200]),
              )
                  : Container(),
            ),
          ],
        );
      },
    );
  }

  void _initialize() async {
    await FirebaseFirestore.instance
        .collection(myCompanyDbExcuses)
        .where('date',
        isEqualTo: DateFormat('dd/MM/yyyy').format(date))
        .where('status', isNotEqualTo: 'empty')
        .get()
        .then((value) {
      value.docs.forEach((document) async {
        try {
          excusesList.add(new Excuses(
            document['userID'].toString().trim() != ''
                ? await FirebaseFirestore.instance
                .collection(appUsers)
                .doc(document['userID'].toString().trim())
                .get()
                .then((value) => value['name'] + " " + value['surname'])
                : "",
            document['userID'].toString().trim() != ''
                ? await FirebaseFirestore.instance
                .collection(appUsers)
                .doc(document['userID'].toString().trim())
                .get()
                .then((value) => value['image_link'])
                : "",
            document['date'].toString() +
                " " +
                document['date_time'].toString(),
            document['status'].toString() != ''
                ? document['status'].toString()
                : "waiting",
            document['status_handled_by'].toString().trim() != ''
                ? await FirebaseFirestore.instance
                .collection(appUsers)
                .doc(document['status_handled_by'].toString().trim())
                .get()
                .then((value) => value['name'] + " " + value['surname'])
                : "",
            document['status_handled_time'].toString() != ''
                ? document['status_handled_time'].toString()
                : "",
            document['excuse'].toString() != ''
                ? document['excuse'].toString()
                : "",
          ));
        } catch (e) {
          print(e);
        }
        setState(() {
          excusesList = excusesList;
        });
      });
    });
  }
}

class Excuses {
  String userName,
      userImageLink,
      excuseDateTime,
      status,
      statusHandledBy,
      statusHandledTime,
      excuse;

  Excuses(
      String userName,
      String userImageLink,
      String excuseDateTime,
      String status,
      String statusHandledBy,
      String statusHandledTime,
      String excuse) {
    this.userName = userName;
    this.userImageLink = userImageLink;
    this.excuseDateTime = excuseDateTime;
    this.status = status;
    this.statusHandledBy = statusHandledBy;
    this.statusHandledTime = statusHandledTime;
    this.excuse = excuse;
  }
}