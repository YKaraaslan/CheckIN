import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';

import 'package:intl/intl.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:unity_checkin/core/widgets/somethings_went_wrong.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import '../late_days/late_days.dart';
import '../user_information/user_profile.dart';
import '../users_for_in_out.dart';
import '../user_on_hold/users_on_hold.dart';
import 'package:unity_checkin/ui/view/home/excuses_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static var now = new DateTime.now();
  static var formatter = new DateFormat('dd MMMM yyyy');
  String _dateToday = formatter.format(now), myEntryStatus = "";

  String _wifiName = "wifi";
  String _wifiConst = "FiberHGW_TP518A_2.4GHz";
  String _wifiConst2 = "FiberHGW_TP518A_5GHz";
  String myID = "";
  String myCompanyID = "",
      myCompanyDbRegisters = "",
      myCompanyUsers = "",
      dbRegistersString = "",
      myCompanyExcuses = "";

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  @override
  void initState() {
    super.initState();
    _connectionStatus();
  }

  Future<void> _connectionStatus() async {
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

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final String wifiName = await WifiInfo().getWifiName();

    setState(() {
      _wifiName = wifiName;
      try {
        _wifiName = _wifiName.toLowerCase();
      } catch (ex) {}
    });
  }

  Future<void> _showAlertDialog(process) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$process yapılacaktır. Onaylıyor musunuz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Evet'),
              onPressed: () {
                Navigator.pop(context, true);
                showLoadingDialog();
                if (process == "Giriş") {
                  _registerEntrance();
                } else if (process == "Çıkış") {
                  _registerExit();
                }
                Fluttertoast.showToast(
                  msg: "$process yapıldı!",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 1,
                );
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            TextButton(
              child: Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /*Widget TopBar() {
    return Container(
      padding: EdgeInsets.only(top: 20),
      height: 240,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
          color: Colors.blue,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [

            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 22, top: 10, right: 10),
              child: Text(
                "Kişileri arayarak bireysel bazlı kullanıcı bilgilerine erişebilirsiniz.",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Redressed',
                    color: Colors.white70),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 0.0), //(x,y)
                    blurRadius: 15.0,
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 2),
                child: TextFormField(
                  cursorColor: Colors.black,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      suffixIcon: Icon(Icons.search),
                      hintText: "Kişi Ara..."),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  Widget date() {
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

  Widget lateAlert() {
    if (myCompanyExcuses.isNotEmpty) {
      return ExcuseAmount(myCompanyExcuses, myID);
    }
    return Container();
  }

  Widget usersWaitingDecider() {
    var me = FirebaseFirestore.instance
        .collection(appUsersOnHold)
        .where(company_id, isEqualTo: myCompanyID)
        .where('status', isEqualTo: 'waiting');
    return StreamBuilder<QuerySnapshot>(
      stream: me.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: Center(child: Text(snapshot.error.toString())),
          );
        } else {
          if (snapshot.data.docs.length > 0) {
            return usersWaitingToBeSignedUp(
                snapshot.data.docs.length.toString());
          } else {
            return noUsersWaitingToBeSignedUp();
          }
        }
      },
    );
  }

  Widget usersWaitingToBeSignedUp(lengthReceived) {
    return InkWell(
      onTap: () => {
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => new UsersOnHold())),
      },
      child: Container(
        margin: EdgeInsets.only(top: 5, left: 15, right: 15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blueGrey,
              child: Icon(
                Icons.person_add,
                size: 30,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.blueGrey,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Wrap(
                    children: [
                      RichText(
                        text: TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(text: "Kayıt bekleyen "),
                              TextSpan(
                                  text: lengthReceived + " kişi",
                                  style: TextStyle(color: Colors.red[200])),
                              TextSpan(
                                  text: " bulunmaktadır. Kaydı yapmak için "),
                              TextSpan(
                                  text: "bu alana tıklayın",
                                  style: TextStyle(color: Colors.blue[200])),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget noUsersWaitingToBeSignedUp() {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 15, right: 15),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.blueGrey,
            child: Icon(
              Icons.done_outline_sharp,
              size: 23,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.blueGrey,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Wrap(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                              text:
                                  "Kayıt bekleyen kullanıcı bulunmamaktadır!"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget excusesWaitingToBeConfirmed() {
    try {
      var me = FirebaseFirestore.instance
          .collection(myCompanyExcuses)
          .where(user_id, isEqualTo: myID)
          .where('status', isEqualTo: 'waiting');
      return StreamBuilder<QuerySnapshot>(
        stream: me.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: Center(child: Text(snapshot.error.toString())),
            );
          } else {
            if (snapshot.data.docs.length > 0) {
              return excusesWaitingToBeSignedUp(
                  snapshot.data.docs.length.toString());
            } else {
              return noExcusesWaitingToBeSignedUp();
            }
          }
        },
      );
    } catch (e) {
      return Container();
    }
  }

  Widget noExcusesWaitingToBeSignedUp() {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 15, right: 15),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.indigo[400],
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Wrap(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                              text: "Onay bekleyen mazeret bulunmamaktadır!"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.indigo[400],
            child: Icon(
              Icons.done_outline_sharp,
              size: 23,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget excusesWaitingToBeSignedUp(lengthReceived) {
    return InkWell(
      onTap: () => {
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => new ExcusesPage())),
      },
      child: Container(
        margin: EdgeInsets.only(top: 5, left: 15, right: 15),
        child: Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.indigo[400],
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Wrap(
                    children: [
                      RichText(
                        text: TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(text: "Onay bekleyen "),
                              TextSpan(
                                  text: lengthReceived + " mazeret",
                                  style: TextStyle(color: Colors.red[200])),
                              TextSpan(text: " bulunmaktadır. Onaylamak için "),
                              TextSpan(
                                  text: "bu alana tıklayın",
                                  style: TextStyle(color: Colors.blue[200])),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.indigo[400],
              child: Icon(
                Icons.assignment,
                size: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInAndOut() {
    if (myCompanyUsers.isNotEmpty) {
      var me = FirebaseFirestore.instance
          .collection(myCompanyUsers)
          .where(user_id, isEqualTo: FirebaseAuth.instance.currentUser.uid);
      return StreamBuilder<QuerySnapshot>(
        stream: me.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: Center(child: Text(snapshot.error.toString())),
            );
          } else {
            if (snapshot.data.docs.first.get(entry_status) == "out" && (_wifiName == _wifiConst || _wifiName == _wifiConst2)) {
              return getIn();
            } else if (snapshot.data.docs.first.get(entry_status) == "in" &&
                (_wifiName == _wifiConst || _wifiName == _wifiConst2)) {
              return getOut();
            } else {
              return Container();
            }
          }
        },
      );
    } else {
      return Container();
    }
  }

  Widget getIn() {
    return Container(
      margin: EdgeInsets.only(top: 15, left: 20, right: 20),
      child: Center(
        child: SizedBox(
          height: 45,
          width: double.infinity,
          child: RaisedButton(
            onPressed: () {
              _showAlertDialog("Giriş");
            },
            padding: EdgeInsets.all(8),
            child: Text(
              'Giriş Yap',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            color: Colors.green,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget getOut() {
    return Container(
      margin: EdgeInsets.only(top: 15, left: 20, right: 20),
      child: Center(
        child: SizedBox(
          height: 45,
          width: double.infinity,
          child: RaisedButton(
            onPressed: () {
              _showAlertDialog("Çıkış");
            },
            padding: EdgeInsets.all(8),
            child: Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            color: Colors.redAccent,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget entrances() {
    if (myCompanyID.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 15),
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
                    .where('date', isEqualTo: _formattedTodaysDate())
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
                        padding: EdgeInsets.only(bottom: 10, top: 10),
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
                              .doc(
                                  snapshot.data.docs[index][user_id].toString())
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
                                      _timeAgo(snapshot.data.docs[index]
                                          .get('time')),
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
                      });
                },
              ),
              Divider(),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(myCompanyUsers)
                      .where(entry_status_date,
                          isNotEqualTo: _formattedTodaysDate())
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Container();
                    }

                    if (snapshot.hasError) {
                      return SomethingWentWrong(snapshot.error.toString());
                    }

                    if (snapshot.data.docs.length == 0) {
                      return new Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Tüm giriş kayıtları yapıldı!',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      );
                    }

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new UsersForInOut('in')));
                      },
                      child: Container(
                        height: 30,
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 80, bottom: 10),
                        child: Row(
                          children: [
                            ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  return FutureBuilder(
                                      future: FirebaseFirestore.instance
                                          .collection(appUsers)
                                          .doc(snapshot
                                              .data.docs[index][user_id]
                                              .toString())
                                          .get(),
                                      builder: (context, snapshot) {
                                        try {
                                          Map<String, dynamic> data =
                                              snapshot.data.data();
                                          return Align(
                                            widthFactor: 0.5,
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width: 30,
                                              decoration: new BoxDecoration(
                                                color: const Color(0xff7c94b6),
                                                image: new DecorationImage(
                                                  image: new NetworkImage(
                                                      data[image_link]),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: new BorderRadius
                                                        .all(
                                                    new Radius.circular(25.0)),
                                                border: new Border.all(
                                                  color: Colors.white,
                                                  width: 1.0,
                                                ),
                                              ),
                                            ),
                                          );
                                        } catch (ex) {}
                                        return Container();
                                      });
                                }),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                "+" +
                                    snapshot.data.docs.length.toString() +
                                    " kişi",
                                style: TextStyle(color: Colors.orangeAccent),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget exits() {
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
                    .where('date', isEqualTo: _formattedTodaysDate())
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
                              .doc(
                                  snapshot.data.docs[index][user_id].toString())
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
                                      _timeAgoExits(snapshot.data.docs[index]
                                          .get('time')),
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
                      });
                },
              ),
              Divider(),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(myCompanyUsers)
                      .where(exit_status_date,
                          isNotEqualTo: _formattedTodaysDate())
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Container();
                    }

                    if (snapshot.hasError) {
                      return SomethingWentWrong(snapshot.error.toString());
                    }

                    if (snapshot.data.docs.length == 0) {
                      return new Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Tüm çıkış kayıtları yapıldı!',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      );
                    }

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    new UsersForInOut('out')));
                      },
                      child: Container(
                        height: 30,
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 80, bottom: 10),
                        child: Row(
                          children: [
                            ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  return FutureBuilder(
                                      future: FirebaseFirestore.instance
                                          .collection(appUsers)
                                          .doc(snapshot
                                              .data.docs[index][user_id]
                                              .toString())
                                          .get(),
                                      builder: (context, snapshot) {
                                        try {
                                          Map<String, dynamic> data =
                                              snapshot.data.data();
                                          return Align(
                                            widthFactor: 0.5,
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width: 30,
                                              decoration: new BoxDecoration(
                                                color: const Color(0xff7c94b6),
                                                image: new DecorationImage(
                                                  image: new NetworkImage(
                                                      data[image_link]),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: new BorderRadius
                                                        .all(
                                                    new Radius.circular(25.0)),
                                                border: new Border.all(
                                                  color: Colors.white,
                                                  width: 1.0,
                                                ),
                                              ),
                                            ),
                                          );
                                        } catch (ex) {}
                                        return Container();
                                      });
                                }),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                "+" +
                                    snapshot.data.docs.length.toString() +
                                    " kişi",
                                style: TextStyle(color: Colors.orangeAccent),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
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
              ExcusesWidgetsPart(myCompanyExcuses),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  /*Widget excusesWidget() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 4,
            margin: EdgeInsets.all(0),
            color: Colors.white,
            child: Column(
              children: [
                Row(
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
                  ],
                ),
                InkWell(
                  onTap: () => {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) =>
                                new UserEntranceInformation())),
                  },
                  child: Column(
                    children: [
                      ListTile(
                        leading: ClipOval(
                          child: Image(
                            image:
                                AssetImage('assets/images/yunus_karaaslan.jpg'),
                            width: 50,
                          ),
                        ),
                        title: Text('Yunus Karaaslan'),
                        subtitle: Container(
                          margin: EdgeInsets.only(top: 5, bottom: 10),
                          child: Text(
                              'İş ile ilgili bir nedenden dolayı erkenden çıkıldı. Şirkete bildirildi.'),
                        ),
                        trailing: Icon(
                          Icons.check,
                          size: 17,
                          color: Colors.green,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 80),
                        child: Text(
                          "Yusuf Aksut - 12 Ocak 2020 11:25",
                          style:
                              TextStyle(fontSize: 13, color: Colors.blue[200]),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () => {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) =>
                                new UserEntranceInformation())),
                  },
                  child: ListTile(
                    leading: ClipOval(
                      child: Image(
                        image: AssetImage('assets/images/okan_kayhan.jpg'),
                        width: 50,
                      ),
                    ),
                    title: Text('Okan Kayhan'),
                    subtitle: Container(
                      margin: EdgeInsets.only(top: 5, bottom: 10),
                      child: Text(
                          'Servise gidilmesi gerekildiginden erkenden cikildi.'),
                    ),
                    trailing: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 17,
                    ),
                  ),
                ),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    //final List<String> list = List.generate(10, (index) => "Test $index");

    return Scaffold(
      appBar: AppBar(
        title: Text("Ana Sayfa"),
        /*actions: [
         Padding(
            padding: const EdgeInsets.all(15.0),
            child: IconButton(
              onPressed: () {
                showSearch(context: context, delegate: Search(list));
              },
              icon: Icon(Icons.search),
            ),
          ),
        ],*/
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            date(),
            lateAlert(),
            usersWaitingDecider(),
            excusesWaitingToBeConfirmed(),
            getInAndOut(),
            entrances(),
            exits(),
            excusesWidget(),
          ],
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
        new DateTime(now.year, now.month, now.day, 08, 00, 00);
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
        new DateTime(now.year, now.month, now.day, 08, 00, 00);
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
        new DateTime(now.year, now.month, now.day, 18, 30, 00);
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
        new DateTime(now.year, now.month, now.day, 18, 30, 00);
    var difference = dateWorkBegin.difference(date).inMinutes;

    if (difference.isNegative) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String _formattedTodaysDate() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> showLoadingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            backgroundColor: Colors.black54,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Kayıt yapılıyor. Lütfen bekleyiniz...",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _registerEntrance() async {
    bool excuseSaved = false;
    var now = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');
    var formatterTime = new DateFormat('HH:mm');
    String _dateToday = formatter.format(now);
    String _timeToday = formatterTime.format(now);

    var date = new DateTime(now.year, now.month, now.day, 8, 0, 0);

    if (now.isAfter(date)) {
      excuseSaved = true;
    }

    await FirebaseFirestore.instance.collection(myCompanyDbRegisters).add({
      'date': _dateToday,
      'date_time': _timeToday,
      'excuse_saved': excuseSaved,
      'process': 'in',
      'time': now,
      'userID': myID,
    }).then((value) async {
      if (excuseSaved) {
        await FirebaseFirestore.instance
            .collection(myCompanyExcuses)
            .doc(value.id)
            .set({
          'date': _dateToday,
          'date_time': _timeToday,
          'excuse': '',
          'process': 'in',
          'registerID': value.id,
          'status': 'empty',
          'status_handled_by': '',
          'status_handled_time': '',
          'timestamp': now,
          'userID': myID
        });
      }
    });

    await FirebaseFirestore.instance
        .collection(myCompanyUsers)
        .doc(myID)
        .update({
      'entry_status_date': _dateToday,
      'entry_status_time': now,
      'status': 'in'
    });
  }

  _registerExit() async {
    bool excuseSaved = false;
    var now = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');
    var formatterTime = new DateFormat('HH:mm');
    String _dateToday = formatter.format(now);
    String _timeToday = formatterTime.format(now);

    var date = new DateTime(now.year, now.month, now.day, 18, 30, 0);

    if (now.isBefore(date)) {
      excuseSaved = true;
    }

    await FirebaseFirestore.instance.collection(myCompanyDbRegisters).add({
      'date': _dateToday,
      'date_time': _timeToday,
      'excuse_saved': excuseSaved,
      'process': 'out',
      'time': now,
      'userID': myID,
    }).then((value) async {
      if (excuseSaved) {
        await FirebaseFirestore.instance
            .collection(myCompanyExcuses)
            .doc(value.id)
            .set({
          'date': _dateToday,
          'date_time': _timeToday,
          'excuse': '',
          'process': 'out',
          'registerID': value.id,
          'status': 'empty',
          'status_handled_by': '',
          'status_handled_time': '',
          'timestamp': now,
          'userID': myID
        });
      }
    });

    await FirebaseFirestore.instance
        .collection(myCompanyUsers)
        .doc(myID)
        .update({
      'exit_status_date': _dateToday,
      'exit_status_time': now,
      'status': 'out'
    });
  }
}

class Search extends SearchDelegate {
  String selectedResult;
  final List<String> listExample;

  Search(this.listExample);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(
        child: Text(selectedResult),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> recentList = ["text", "text"];
    List<String> suggestionList = [];
    query.isEmpty
        ? suggestionList = recentList
        : suggestionList.addAll(listExample.where(
            (element) => element.contains(query),
          ));

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(
              suggestionList[index],
            ),
            onTap: () {
              selectedResult = suggestionList[index];
              showResults(context);
            });
      },
    );
  }
}

class ExcusesWidgetsPart extends StatefulWidget {
  final String myCompanyDbExcuses;

  ExcusesWidgetsPart(this.myCompanyDbExcuses);

  @override
  _ExcusesWidgetsPartState createState() =>
      _ExcusesWidgetsPartState(myCompanyDbExcuses);
}

class _ExcusesWidgetsPartState extends State<ExcusesWidgetsPart> {
  final String myCompanyDbExcuses;

  _ExcusesWidgetsPartState(this.myCompanyDbExcuses);

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
              margin: EdgeInsets.only(left: 80),
              child: excusesList[index].status == "ok"
                  ? Text(
                      excusesList[index].statusHandledBy +
                          " - " +
                          excusesList[index].statusHandledTime,
                      style: TextStyle(fontSize: 13, color: Colors.blue[200]),
                    )
                  : Container(),
            ),
            Divider(),
          ],
        );
      },
    );
  }

  void _initialize() async {
    await FirebaseFirestore.instance
        .collection(myCompanyDbExcuses)
        .where('date',
            isEqualTo: DateFormat('dd/MM/yyyy').format(DateTime.now()))
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

class ExcuseAmount extends StatefulWidget {
  final String myCompanyExcuses, myID;

  ExcuseAmount(this.myCompanyExcuses, this.myID);

  @override
  _ExcuseAmountState createState() =>
      _ExcuseAmountState(myCompanyExcuses, myID);
}

class _ExcuseAmountState extends State<ExcuseAmount> {
  final String myCompanyExcuses, myID;

  _ExcuseAmountState(this.myCompanyExcuses, this.myID);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(myCompanyExcuses)
          .where('userID', isEqualTo: myID)
          .where('status', isEqualTo: 'empty')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        int amount = snapshot.data.docs.length;
        if (snapshot.data.docs.length == 0) {
          return Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.orange[200],
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                      child: Text(
                    'Bekleyen mazeret kaydınız bulunmamaktadır.',
                    style: TextStyle(color: Colors.brown),
                  )),
                ),
              ));
        } else {
          return InkWell(
            onTap: () {
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => new LateDays()));
            },
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.orange[200],
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: RichText(
                    text: TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(text: "Tamamlanmamış "),
                          TextSpan(
                              text: "$amount adet mazeret",
                              style: TextStyle(color: Colors.red)),
                          TextSpan(
                              text:
                                  " kaydınız bulunmaktadır. Kaydı yapmak için "),
                          TextSpan(
                              text: "bu alana tıklayın",
                              style: TextStyle(color: Colors.blue)),
                          TextSpan(
                            text: " ya da ",
                            style: TextStyle(fontSize: 15),
                          ),
                          TextSpan(
                              text: "profilinize gidin",
                              style: TextStyle(color: Colors.blue)),
                          TextSpan(text: "."),
                        ]),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
