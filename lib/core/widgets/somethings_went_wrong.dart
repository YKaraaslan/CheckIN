import 'package:flutter/material.dart';

class SomethingWentWrong extends StatelessWidget {
  final String error;

  SomethingWentWrong(this.error);

  Widget header() {
    return Container(
      height: 250,
      width: double.infinity,
      child: Image(
        image: AssetImage('assets/images/not_found.png'),
      ),
    );
  }

  Widget titleText() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      alignment: Alignment.centerLeft,
      child: Text(
        'Bir hatayla karşılaşıldı.',
        style: TextStyle(
          color: Colors.blue[800],
          fontSize: 17
        ),
      ),
    );
  }

  Widget errors() {
    return Container(
      margin: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 20),
      alignment: Alignment.centerLeft,
      child: Text(
        '$error',
        style: TextStyle(
            color: Colors.black,
            fontSize: 15
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header(),
        titleText(),
        errors(),
      ],
    );
  }
}
