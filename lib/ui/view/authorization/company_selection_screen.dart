import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:unity_checkin/core/widgets/somethings_went_wrong.dart';

class CompanySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Şirketler'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.search),
              )
            ],
          ),
          body: CompanySelectionScreenBody(),
        ),
      ],
    );
  }
}

class CompanySelectionScreenBody extends StatefulWidget {
  @override
  _CompanySelectionScreenBodyState createState() =>
      _CompanySelectionScreenBodyState();
}

class _CompanySelectionScreenBodyState
    extends State<CompanySelectionScreenBody> {

  @override
  Widget build(BuildContext context) {
    CollectionReference companies = FirebaseFirestore.instance.collection(appCompanies);

    return StreamBuilder<QuerySnapshot>(
      stream: companies.snapshots(),
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
              onTap: (){
                Navigator.pop(context, document.get("name"));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  child: new ListTile(
                    leading: Icon(Icons.add),
                    title: new Text(document.data()['name']),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}