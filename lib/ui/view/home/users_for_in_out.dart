import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:unity_checkin/core/widgets/somethings_went_wrong.dart';

import 'user_information/user_profile.dart';

class UsersForInOut extends StatefulWidget {
  final String process;
  UsersForInOut(this.process);

  @override
  _UsersForInOutState createState() => _UsersForInOutState(this.process);
}

class _UsersForInOutState extends State<UsersForInOut> {
  String process;
  _UsersForInOutState(this.process);

  String myCompanyUsers, msg;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      myCompanyUsers = prefs.getString(dbUsers) != null ? prefs.getString(dbUsers) : "";
      msg = process == 'in' ? 'Giriş' : 'Çıkış';
    });
  }

  Widget userLists(){
    String first = process == 'in' ? 'entry_status_date' : 'exit_status_date';
    if(myCompanyUsers != null || myCompanyUsers != ''){
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(myCompanyUsers)
            .where(first, isNotEqualTo: _formattedTodaysDate())
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
                  'Bekleyen $msg Kaydı bulunmamaktadır!',
                  style: TextStyle(color: Colors.green),
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
                          onTap: (){
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                    new UserEntranceInformation(data[user_id])));
                          },
                          child: Column(
                            children: [
                              ListTile(
                                leading: ClipOval(
                                  child: Image.network(data[image_link],
                                      width: 50),
                                ),
                                title: Text(
                                    data['name'] + " " + data['surname']),
                                subtitle: Wrap(
                                  children: [
                                    Text('Son $msg: '),
                                    Text(snapshot.data.docs[index][first].toString(), style: TextStyle(color: Colors.blue)),
                                  ],
                                ),
                                trailing: Icon(Icons.chevron_right),
                              ),
                              Divider(),
                            ],
                          ),
                        );
                      }
                    } catch (ex) {}
                    return Container();
                  },
                );
              });
        },
      );
    }
    else{
      return Container();
    }
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
          title: Text('$msg Yapacaklar'),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return Column(
                children: [
                  userLists(),
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


  String _formattedTodaysDate() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }
}
