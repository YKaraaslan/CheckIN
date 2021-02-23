import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_checkin/core/utilities/strings.dart';

class LateInput extends StatefulWidget {
  final String id, date, process;
  LateInput(this.id, this.date, this.process);

  @override
  _LateInputState createState() => _LateInputState(id, date, process);
}

class _LateInputState extends State<LateInput> {
  String id, date, _dateToday, process;
  _LateInputState(this.id, this.date, this.process);

  @override
  void initState() {
    DateTime tempDate = new DateFormat("dd/MM/yyyy").parse(date);
    var formatter = new DateFormat('dd MMMM yyyy');
    setState(() {
      _dateToday = formatter.format(tempDate);
    });

    print(id);

    super.initState();
  }

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
          child: Text('$_dateToday',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: LateInputBody(id, process),
    );
  }
}


class LateInputBody extends StatefulWidget {
  final String id, process;

  LateInputBody(this.id, this.process);

  @override
  _LateInputBodyState createState() => _LateInputBodyState(id, process);
}

class _LateInputBodyState extends State<LateInputBody> {
  final _formKey = GlobalKey<FormState>();
  int counter = 0, _maxChar = 500;
  String process;
  String id;
  String myCompanyExcuses;
  String myID = "";

  _LateInputBodyState(this.id, this.process);
  final excuseController = TextEditingController();


  @override
  void initState() {
    _connectionStatus();
    super.initState();
  }

  Future<void> _connectionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      myID = prefs.getString(my_id);
      myCompanyExcuses = prefs.getString(dbExcuses) != null ? prefs.getString(dbExcuses) : "";
    });
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Kayıt yapılacaktır. Onaylıyor musunuz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Evet'),
              onPressed: () async {
                Navigator.pop(context, true);
                await _submitLateExcuse();
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
                maxLines: 15,
                minLines: 15,
                decoration: const InputDecoration(
                  hintText: 'Mazeretiniz nedir?',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                controller: excuseController,
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
                  'Kaydı Tamamla',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showLoadingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            backgroundColor: Colors.black54,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Kayıt yapılıyor. Lütfen bekleyiniz...",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitLateExcuse() async {
    showLoadingDialog();

    await FirebaseFirestore.instance.collection(myCompanyExcuses).doc(id).update({
      'excuse': excuseController.text.trim(),
      'status': 'waiting',
      'timestamp': DateTime.now(),
    }).then((value) {
      Navigator.of(context, rootNavigator: true).pop();
      Fluttertoast.showToast(
          msg: "Kayıt işlemi başarıyla gerçekleşti.",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
      );
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
    });
  }
}
