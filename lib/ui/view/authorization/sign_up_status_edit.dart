import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unity_checkin/core/utilities/strings.dart';

class SignUpStatusEdit extends StatelessWidget {
  final String id;

  SignUpStatusEdit(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                horizontal: 40.0,
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
                  SignUpStatusEditBody(id),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SignUpStatusEditBody extends StatefulWidget {
  final String id;
  SignUpStatusEditBody(this.id);

  @override
  _SignUpStatusEditBodyState createState() => _SignUpStatusEditBodyState(id);
}

class _SignUpStatusEditBodyState extends State<SignUpStatusEditBody> {
  String id;
  _SignUpStatusEditBodyState(this.id);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection(appUsersOnHold).doc(id).get(),
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.connectionState == ConnectionState.done){
          var doc = snapshot.data;
          return Body(doc);
        }

        if (snapshot.connectionState == ConnectionState.waiting){
          return LinearProgressIndicator();
        }

        return Container();
      },
    );
  }
}

class Body extends StatefulWidget {
  final DocumentSnapshot doc;
  Body(this.doc);

  @override
  _BodyState createState() => _BodyState(doc);
}

class _BodyState extends State<Body> {
  var doc;
  _BodyState(this.doc);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

      ],
    );
  }
}
