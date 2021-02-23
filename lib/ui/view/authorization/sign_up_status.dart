import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:unity_checkin/ui/model/sign_up_denial_model.dart';

import 'sign_up.dart';

class SignUpStatus extends StatefulWidget {
  @override
  _SignUpStatusState createState() => _SignUpStatusState();
}

class _SignUpStatusState extends State<SignUpStatus> {
  String token;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    token = await _fcm.getToken();

    setState(() {
      token = token;
    });
  }

  Widget cardStatus() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection(appUsersOnHold)
          .where('token', isEqualTo: token)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          try{
            DocumentSnapshot document = snapshot.data.docs.first;
            return Container(
              width: double.infinity,
              child: Column(
                children: [
                  Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  radius: 50,
                                  backgroundImage: NetworkImage(
                                      document.get(image_link)),
                                ),
                              ),
                            ),
                            title: Text(
                                document.get(name) + " " + document.get(surname)),
                            subtitle: Wrap(
                              children: [
                                Text('Durum: '),
                                Text(
                                  document.get('status') == "denied"
                                      ? 'Reddedildi'
                                      : 'Bekleniyor...',
                                  style: TextStyle(
                                      color: document.get('status') == "denied"
                                          ? Colors.red
                                          : Colors.blueAccent),
                                ),
                              ],
                            ),
                            trailing: document.get('status') == "denied"
                                ? Icon(
                              Icons.close,
                              color: Colors.red,
                            )
                                : Icon(
                              Icons.watch_later_outlined,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Visibility(
                            visible:
                            document.get('status') == "denied" ? true : false,
                            child: Column(
                              children: [
                                Divider(),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10, top: 10, bottom: 5),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Reddedilme Nedeni',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10, bottom: 10, right: 10),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    document.get('status_denied_message'),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10, bottom: 10, right: 10),
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    _setTime(document.get('status_denied_time')),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                  Visibility(
                    visible: document.get('status') == "denied" ? true : false,
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      margin: EdgeInsets.only(top: 15, left: 50, right: 50),
                      child: RaisedButton(
                        onPressed: () {
                          SignUpDenialModel userModel = new SignUpDenialModel(document.get('name'), document.get('surname'),
                              document.get('mail'), document.get('phone'), document.get('password'), document.get('image_link'), document.id, document.get('image_name'));
                          Navigator.pushReplacement(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new SignUp(userModel)));
                        },
                        child: Text(
                          'Düzenle',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        color: Colors.deepOrange,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          catch (e){
            return Center(child: Column(
              children: [
                Text('Bekleyen kaydınız bulunmamaktadır.', style: TextStyle(color: Colors.white),),
                Icon(Icons.done, color: Colors.white, size: 50,),
              ],
            ),);
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator();
        }

        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 75.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Unity Mobil Giriş Çıkış',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Redressed',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      cardStatus(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _setTime(Timestamp timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    DateTime dateWorkBegin = DateTime.now();
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
}
