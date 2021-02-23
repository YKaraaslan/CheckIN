import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:unity_checkin/core/widgets/somethings_went_wrong.dart';

import 'users_on_hold_profile.dart';

class UsersOnHold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            'Kayıt Bekleyen Kullanıcılar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: UsersOnHoldBody(),
    );
  }
}

class UsersOnHoldBody extends StatefulWidget {
  @override
  _UsersOnHoldBodyState createState() => _UsersOnHoldBodyState();
}

class _UsersOnHoldBodyState extends State<UsersOnHoldBody> {
  String myCompanyID;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setPrefs());
  }

  setPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myCompanyID = prefs.getString(my_company_id);
    setState(() {
      myCompanyID = myCompanyID;
    });
  }

  @override
  Widget build(BuildContext context) {
    Query usersOnHold = FirebaseFirestore.instance
        .collection(appUsersOnHold)
        .where('companyID', isEqualTo: myCompanyID)
        .where('status', isEqualTo: 'waiting')
        .orderBy('time_applied', descending: true);
    return StreamBuilder<QuerySnapshot>(
      stream: usersOnHold.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return SomethingWentWrong(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) =>
                            new UsersOnHoldProfile(document.id)));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    new ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 25,
                          backgroundImage: document.get(image_link) != null &&
                                  document.get(image_link) != ""
                              ? NetworkImage(document.get(image_link))
                              : AssetImage('assets/images/logo.png')),
                      title: new Text(document.data()['name'] +
                          " " +
                          document.data()['surname']),
                      subtitle: new Text(
                        timeAgo(DateTime.fromMicrosecondsSinceEpoch(document
                            .data()['time_applied']
                            .microsecondsSinceEpoch)),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 80),
                      width: double.infinity,
                      height: 1,
                      color: Colors.grey[200],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

String timeAgo(DateTime dateTime) {
  var format = new DateFormat('dd MMMM yyyy HH:mm');
  return format.format(dateTime);
}
