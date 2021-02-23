import 'package:flutter/material.dart';

import 'somethings_went_wrong.dart';

class FutureBuilderWidget extends StatelessWidget {
  FutureBuilderWidget({@required this.future, @required this.child});

  final future;
  final child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return child(snapshot.data);
          } else {
            return SomethingWentWrong(snapshot.error);
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return SomethingWentWrong(snapshot.error);
        }
      },
    );
  }
}
