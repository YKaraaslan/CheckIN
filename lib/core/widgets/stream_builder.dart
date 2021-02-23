import 'package:flutter/material.dart';

import 'somethings_went_wrong.dart';

class StreamBuilderWidget extends StatelessWidget {
  StreamBuilderWidget({@required this.stream, @required this.child});

  final stream;
  final child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
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
