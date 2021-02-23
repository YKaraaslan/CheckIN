import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:unity_checkin/core/widgets/somethings_went_wrong.dart';

import 'late_input.dart';

class LateDays extends StatelessWidget {
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
            'Kayıt Bekleyen Mazeretler',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: LateDaysBody(),
    );
  }
}

class LateDaysBody extends StatefulWidget {
  LateDaysBody();

  @override
  _LateDaysBodyState createState() => _LateDaysBodyState();
}

class _LateDaysBodyState extends State<LateDaysBody> {
  String myCompanyExcuses;
  String myID = "";

  @override
  void initState() {
    _connectionStatus();
    super.initState();
  }

  Future<void> _connectionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      myID = prefs.getString(my_id);
      myCompanyExcuses =
          prefs.getString(dbExcuses) != null ? prefs.getString(dbExcuses) : "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (myCompanyExcuses != null && myCompanyExcuses != "")
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(myCompanyExcuses)
            .where(user_id, isEqualTo: myID)
            .where('status', isEqualTo: 'empty')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SomethingWentWrong(snapshot.error.toString());
          }

          if (snapshot.data == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return LinearProgressIndicator(
              backgroundColor: Colors.red,
            );
          }

          if (snapshot.data.docs.length == 0) {
            return Center(
              child: Text('Kayıt bekleyen mazeret bulunmamaktadır'),
            );
          }

          return ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children:
                snapshot.data.docs.map<Widget>((DocumentSnapshot document) {
              return new SetListView(document, myID);
            }).toList(),
          );
        },
      );
    else
      return CircularProgressIndicator();
  }
}

class SetListView extends StatefulWidget {
  final DocumentSnapshot document;
  final String myID;

  SetListView(this.document, this.myID);

  @override
  _SetListViewState createState() => _SetListViewState(document, myID);
}

class _SetListViewState extends State<SetListView> {
  DocumentSnapshot document;
  String myID;

  _SetListViewState(this.document, this.myID);

  String myName = "", imageLink = "";

  @override
  void initState() {
    _getRequired();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) =>
                    new LateInput(document.id, document.get('date'), document.get('process'))));
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListTile(
              leading: imageLink != null && imageLink != ""
                  ? ClipOval(
                      child: Image(
                        image: NetworkImage('$imageLink'),
                      ),
                    )
                  : SizedBox(
                      width: 50,
                      height: 50,
                    ),
              title: Text('$myName'),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: document.get('process') == "out"
                          ? Text('Geç giriş yapıldı')
                          : Text('Erken çıkış yapıldı'),
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text(document.get('date') +
                              " " +
                              document.get('date_time'), style: TextStyle(color: Colors.blue),),
                        )),
                  ],
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.deepOrange,
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  void _getRequired() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myName = prefs.getString(my_name) + " " + prefs.getString(my_surname);
    });
    await FirebaseFirestore.instance
        .collection(appUsers)
        .doc(myID)
        .get()
        .then((value) => {
              setState(() {
                imageLink = value.get(image_link);
              })
            });
  }
}
