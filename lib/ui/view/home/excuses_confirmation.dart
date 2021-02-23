import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_checkin/core/utilities/strings.dart';

class ExcusesConfirmation extends StatelessWidget {
  final String id;

  ExcusesConfirmation(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Mazeret Onayı'),
      ),
      backgroundColor: Colors.white,
      body: ExcusesConfirmationBody(id),
    );
  }
}

class ExcusesConfirmationBody extends StatefulWidget {
  final String id;

  ExcusesConfirmationBody(this.id);

  @override
  _ExcusesConfirmationBodyState createState() =>
      _ExcusesConfirmationBodyState(id);
}

class _ExcusesConfirmationBodyState extends State<ExcusesConfirmationBody> {
  final String id;

  _ExcusesConfirmationBodyState(this.id);

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


      try{
        _confirmChanges();
      }
      catch (e) { print(e.toString());}
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection(myCompanyExcuses)
            .doc(id)
            .get(),
        builder: (context, snapshot) {
          if (snapshot == null) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            return Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection(appUsers)
                        .doc(data['userID'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> dataUser = snapshot.data.data();
                        return ListTile(
                          leading: ClipOval(
                              child: Image(
                            image: NetworkImage(dataUser['image_link']),
                          )),
                          title:
                              Text(dataUser['name'] + " " + dataUser['surname']),
                          subtitle: data['process'] == 'in'
                              ? Text('Erken Çıkıldı')
                              : Text('Geç Kalındı'),
                        );
                      }

                      return Container();
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 17),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data['excuse'],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text(
                        data['date'] + " - " + data['date_time'],
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            );
          }

          return LinearProgressIndicator();
        },
      );
    } catch (e) {
      return Container();
    }
  }

  _confirmChanges() async {
    await FirebaseFirestore.instance.collection(myCompanyExcuses).doc(id).update(
        {
          'status': 'ok',
          'status_handled_by': myID,
          'status_handled_time': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())
        }).then((value) => Get.snackbar("Unity Mobil", "Mazeret onayı otomatik gerçekleşti."));
  }
}
