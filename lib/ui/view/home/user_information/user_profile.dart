import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:unity_checkin/core/widgets/somethings_went_wrong.dart';

import 'entrances.dart';
import 'lates.dart';

class UserEntranceInformation extends StatefulWidget {
  final String userID;

  UserEntranceInformation(this.userID);

  @override
  _UserEntranceInformationState createState() =>
      _UserEntranceInformationState(userID);
}

class _UserEntranceInformationState extends State<UserEntranceInformation> {
  String userID;

  _UserEntranceInformationState(this.userID);

  String nameSurname = "",
      status = "",
      statusDate = "",
      statusTime = "",
      overworkWeekly = "",
      overworkMonthly = "",
      imageLink = "";

  String entranceStatus = "", entranceStatusLatency = 'erken';
  Color latencyColor = Colors.green;
  String exitStatus = "", exitStatusLatency = 'erken';
  String daysEntered = '0', daysLate = '0';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
    super.initState();
  }

  void _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String myCompanyUsers =
        prefs.getString(dbUsers) != null ? prefs.getString(dbUsers) : "";
    String myCompanyDbRegisters = prefs.getString(dbRegisters) != null
        ? prefs.getString(dbRegisters)
        : "";

    FirebaseFirestore.instance
        .collection(appUsers)
        .doc(userID)
        .get()
        .then((value) {
      setState(() {
        imageLink = value.get(image_link);
        nameSurname = value.get('name') + " " + value.get('surname');
      });
    });

    FirebaseFirestore.instance
        .collection(myCompanyUsers)
        .where(user_id, isEqualTo: userID)
        .get()
        .then((value) {
      setState(() {
        status = value.docs.first.get('status') == 'in' ? "Giriş" : "Çıkış";
        var time = value.docs.first.get(entry_status) == 'in'
            ? value.docs.first.get(entry_status_time)
            : value.docs.first.get(exit_status_time);

        var date = new DateTime.fromMicrosecondsSinceEpoch(
            time.microsecondsSinceEpoch);

        statusDate = DateFormat('dd MMMM').format(date);
        statusTime = DateFormat('HH:mm').format(date);
      });
    });

    Timestamp myTimeStamp = Timestamp.fromDate(
        new DateTime(DateTime.now().year, DateTime.now().month));

    FirebaseFirestore.instance
        .collection(myCompanyDbRegisters)
        .where(user_id, isEqualTo: userID)
        .where('time', isGreaterThanOrEqualTo: myTimeStamp)
        .where('process', isEqualTo: 'in')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        Duration timeDuration = new Duration();

        for (var document in value.docs) {
          Timestamp timestamp = document.get('time');
          var date = new DateTime.fromMillisecondsSinceEpoch(
              timestamp.millisecondsSinceEpoch);
          var date1 = new DateTime(date.year, date.month, date.day, 8, 0, 0);
          timeDuration += date1.difference(date);
        }

        format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

        List<String> splitted = format(timeDuration.abs()).split(':');

        entranceStatus = splitted[0] +
            ' saat ' +
            splitted[1] +
            ' dak. ' +
            splitted[2] +
            ' sn.';
        if (splitted[0] == '0' || splitted[0] == '-0' || splitted[0] == '00') {
          entranceStatus = splitted[1] + ' dak. ' + splitted[2] + ' sn.';
        }

        setState(() {
          if (timeDuration.isNegative) {
            entranceStatusLatency = 'geç';
            latencyColor = Colors.red;
          }
        });
      } else {
        setState(() {
          entranceStatus = '-';
          entranceStatusLatency = '';
          latencyColor = Colors.black;
        });
      }
    });

    FirebaseFirestore.instance
        .collection(myCompanyDbRegisters)
        .where(user_id, isEqualTo: userID)
        .where('time', isGreaterThanOrEqualTo: myTimeStamp)
        .where('process', isEqualTo: 'out')
        .get()
        .then((value) {
      Duration timeDuration = new Duration();

      for (var document in value.docs) {
        Timestamp timestamp = document.get('time');
        var date = new DateTime.fromMillisecondsSinceEpoch(
            timestamp.millisecondsSinceEpoch);
        var date1 = new DateTime(date.year, date.month, date.day, 18, 45, 0);

        if (date.isAfter(date1)) {
          var dateNew =
              new DateTime(date.year, date.month, date.day, 18, 30, 0);
          timeDuration += date.difference(dateNew);
        }
      }

      print(timeDuration);

      format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

      List<String> splitted = format(timeDuration.abs()).split(':');

      exitStatus = splitted[0] +
          ' saat ' +
          splitted[1] +
          ' dak. ' +
          splitted[2] +
          ' sn.';
      if (splitted[0] == '0' || splitted[0] == '-0' || splitted[0] == '00') {
        exitStatus = splitted[1] + ' dak. ' + splitted[2] + ' sn.';
      }

      setState(() {
        if (timeDuration.isNegative) {
          exitStatus = "-";
        }
      });
    });

    FirebaseFirestore.instance
        .collection(myCompanyDbRegisters)
        .where(user_id, isEqualTo: userID)
        .where('process', isEqualTo: 'in')
        .get()
        .then((value) {
      daysEntered = value.docs.length.toString();
    });
  }

  Widget header() {
    if (imageLink != null || imageLink != "") {
      return Column(
        children: [
          Container(
            width: 100,
            margin: EdgeInsets.only(top: 20),
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50,
                backgroundImage: imageLink != null
                    ? NetworkImage('$imageLink')
                    : AssetImage('assets/images/logo.png'),
                ),
              ),
            ),
          Container(
            child: Center(
              child: Text(
                '$nameSurname',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Center(
              child: Wrap(
                children: [
                  Text(
                    '$status: ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '$statusDate, ',
                    style: TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '$statusTime',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget overwork() {
    return Container(
      margin: EdgeInsets.only(top: 30, left: 30, right: 20, bottom: 10),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aylık Durum',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              children: [
                Text(
                  '- Mesai Durumu: ',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                Text(
                  '$exitStatus',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              children: [
                Text(
                  '- Giriş Durumu: ',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                Text(
                  '$entranceStatus $entranceStatusLatency',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: latencyColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget entrances() {
    return InkWell(
      splashColor: Colors.green[200],
      highlightColor: Colors.green[200],
      onTap: () {
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => new Entrances(userID)));
      },
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 10),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Icon(
                Icons.subdirectory_arrow_right,
                color: Colors.green[900],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 70, top: 3),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Giriş Çıkışlar',
                      style: TextStyle(color: Colors.green[900], fontSize: 17),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3, right: 35),
                      child: daysEntered != '0' ?  Text('$daysEntered günlük kayıt bulunmaktadır.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ) : Text('Kayıt bulunmamaktadır.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10, top: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.green[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget late() {
    return InkWell(
      splashColor: Colors.orange[200],
      highlightColor: Colors.orange[200],
      onTap: () {
        Navigator.push(
            context, new MaterialPageRoute(builder: (context) => new Lates(userID)));
      },
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 10),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Icon(
                Icons.watch_later_outlined,
                color: Colors.orange[900],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 70, top: 3),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Geç Kalınan Günler',
                      style: TextStyle(color: Colors.orange[900], fontSize: 17),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3, right: 30),
                      child: daysLate != '0' ?  Text('$daysLate günlük kayıt bulunmaktadır.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ) : Text('Kayıt bulunmamaktadır.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10, top: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.orange[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget lateEntrance() {
    return InkWell(
      splashColor: Colors.red[200],
      highlightColor: Colors.red[200],
      onTap: () {
        Navigator.push(
            context, new MaterialPageRoute(builder: (context) => new Lates(userID)));
      },
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 10),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Icon(
                Icons.watch_later,
                color: Colors.red[900],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 70, top: 3),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Erken Çıkılan Günler',
                      style: TextStyle(color: Colors.red[900], fontSize: 17),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3, right: 30),
                      child: daysLate != '0'
                          ? Text(
                        '$daysLate günlük kayıt bulunmaktadır.',
                        style:
                        TextStyle(color: Colors.grey, fontSize: 14),
                      )
                          : Text(
                        'Kayıt bulunmamaktadır.',
                        style:
                        TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10, top: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.red[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
          ),
          title: Text('Kişi Profili'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Chip(
                label: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '$status Yaptı',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                backgroundColor: Colors.blue[300],
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return Column(
                children: [
                  header(),
                  overwork(),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[100],
                  ),
                  entrances(),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[100],
                  ),
                  late(),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[100],
                  ),
                  lateEntrance(),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[100],
                  ),
                ],
              );
            },
          ),
        ),
      );
    } catch (e) {
      return SomethingWentWrong(e);
    }
  }
}
