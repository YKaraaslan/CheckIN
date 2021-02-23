import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_checkin/core/utilities/strings.dart';

class UserOnHoldDenialReason extends StatelessWidget {
  final String id;
  UserOnHoldDenialReason(this.id);

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
          child: Text('Kullanıcı Reddi',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: UserOnHoldDenialReasonBody(id),
    );
  }
}

class UserOnHoldDenialReasonBody extends StatefulWidget {
  final String id;
  UserOnHoldDenialReasonBody(this.id);

  @override
  _UserOnHoldDenialReasonBodyState createState() => _UserOnHoldDenialReasonBodyState(id);
}

class _UserOnHoldDenialReasonBodyState extends State<UserOnHoldDenialReasonBody> {
  final _formKey = GlobalKey<FormState>();
  int counter = 0, _maxChar = 300;
  final reasonController = TextEditingController();

  String id, myID;
  _UserOnHoldDenialReasonBodyState(this.id);

  @override
  void initState() {
    _connectionStatus();
    super.initState();
  }

  Future<void> _connectionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      myID = prefs.getString(my_id);
    });
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    counter = value.length;
                  });
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(_maxChar),
                ],
                autofocus: true,
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                minLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Kullanıcıyı reddetme sebebinizi yazınız. Reddedilen kullanıcı bu sebebi görecek ve akabinde gerekli düzenlemeyi yapıp tekrardan başvurabilecektir.',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                controller: reasonController,
                onSaved: (String value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
                validator: (String value) {
                  return value.isEmpty ? 'Bu alan boş bırakılamaz.' : null;
                },
              ),
            ),
            Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('$counter/$_maxChar'),
              ),
            ),
            Container(
              width: double.infinity,
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, otherwise false.
                  if (_formKey.currentState.validate()) {
                    _showAlertDialog();
                  }
                },
                child: Text(
                  'İşlemi Tamamla',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Kullanıcı red işlemi yapılacaktır. İşlemi onaylıyor musunuz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Evet'),
              onPressed: () {
                Navigator.pop(context, true);
                _submit();
              },
            ),
            TextButton(
              child: Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _submit() async {
    FirebaseFirestore.instance.collection(appUsersOnHold).doc(id).update({
      'status': 'denied',
      'status_denied_by': myID,
      'status_denied_message': reasonController.text.trim(),
      'status_denied_time': DateTime.now(),
    });
  }
}
