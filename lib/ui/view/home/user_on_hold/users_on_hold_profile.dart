import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:unity_checkin/core/utilities/constants.dart';
import 'package:unity_checkin/core/utilities/strings.dart';

import 'users_on_hold_denial_reason.dart';

class UsersOnHoldProfile extends StatelessWidget {
  final String id;

  UsersOnHoldProfile(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffdfdfd),
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
            'Kullanıcı Profili',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: UsersOnHoldProfileBody(id),
    );
  }
}

class UsersOnHoldProfileBody extends StatefulWidget {
  final String id;

  UsersOnHoldProfileBody(this.id);

  @override
  _UsersOnHoldProfileBodyState createState() =>
      _UsersOnHoldProfileBodyState(id);
}

class _UsersOnHoldProfileBodyState extends State<UsersOnHoldProfileBody> {
  String id;

  _UsersOnHoldProfileBodyState(this.id);

  Timestamp _timeApplied;
  String _companyID = "",
      _networkImageLink = "",
      _email = "",
      _name = "",
      _password = "",
      _phone = "";
  String _surname = "",
      _dateApplied = "",
      _token = "",
      _nameSurname = "",
      _userID = "";
  String result = "";

  @override
  void initState() {
    DocumentReference usersOnHold =
        FirebaseFirestore.instance.collection(appUsersOnHold).doc(id);

    usersOnHold.get().then((value) {
      setState(() {
        _name = value.data()["name"];
        _surname = value.data()["surname"];
        _userID = value.data()["userID"];

        _timeApplied = value.data()["time_applied"];
        _companyID = value.data()["companyID"];
        _password = value.data()["password"];
        _token = value.data()["token"];

        _nameSurname = _name + " " + _surname;
        _dateApplied = timeAgo(DateTime.fromMicrosecondsSinceEpoch(
            value.data()['time_applied'].microsecondsSinceEpoch));
        _networkImageLink = value.data()[image_link];
        _email = value.data()["mail"];
        _phone = value.data()["phone"];
      });
    });
    super.initState();
  }

  Widget header() {
    return Material(
      elevation: 2,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 50, right: 50),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                width: 90,
                margin: EdgeInsets.only(top: 20),
                child: Center(
                  child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 50,
                      backgroundImage:
                          _networkImageLink != null && _networkImageLink != ""
                              ? NetworkImage(_networkImageLink)
                              : AssetImage('assets/images/logo.png')),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                child: Center(
                  child: Text(
                    _nameSurname,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 20),
                child: Center(
                  child: Text(
                    'Başvuru: $_dateApplied',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget email() {
    return Container(
      margin: EdgeInsets.only(left: 50, right: 50, top: 20),
      alignment: Alignment.centerLeft,
      decoration: kBoxDecorationStyleForUserOnHoldProfile,
      height: 60.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(
              Icons.mail_outline,
              color: Colors.white,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  '$_email',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget phone() {
    return Container(
      margin: EdgeInsets.only(left: 50, right: 50, top: 10, bottom: 20),
      alignment: Alignment.centerLeft,
      decoration: kBoxDecorationStyleForUserOnHoldProfile,
      height: 60.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(
              Icons.phone,
              color: Colors.white,
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                '$_phone',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget buttons() {
    return Material(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
        child: Row(
          children: [
            Expanded(
              child: RaisedButton(
                onPressed: () {
                  _showAlertDialogForDenial();
                },
                color: Colors.orange,
                child: Container(
                  height: 40,
                  child: Center(
                    child: Text(
                      'Reddet',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
            SizedBox(
              width: 25,
            ),
            Expanded(
              child: RaisedButton(
                onPressed: () {
                  _showAlertDialog();
                },
                color: Colors.green[300],
                child: Container(
                  height: 40,
                  child: Center(
                    child: Text(
                      'Onayla',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          header(),
          SizedBox(
            height: 20,
          ),
          Material(
            elevation: 2,
            color: Colors.white,
            child: Column(
              children: [
                email(),
                phone(),
              ],
            ),
          ),
          buttons(),
        ],
      ),
    );
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Kullanıcıyı onaylıyor musunuz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Evet'),
              onPressed: () {
                Navigator.of(context).pop();
                showLoadingDialog('Giriş');
                _confirm();
                Navigator.of(context, rootNavigator: true).pop();
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

  Future<void> _showAlertDialogForDeletion() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Kullanıcı başvurusunu silmek istediğinize emin misiniz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Evet'),
              onPressed: () {
                Navigator.of(context).pop();
                showLoadingDialog('Silme');
                _delete();
                Navigator.of(context, rootNavigator: true).pop();
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

  Future<void> _showAlertDialogForDenial() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Red işlemiyle kullanıcıya tekrardan başvurabilme imkanı sağlayabilirsiniz. Silme işlemiyle ise kullanıcı kaydı tamamen silinir.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sil'),
              onPressed: () {
                Navigator.of(context).pop();
                showLoadingDialog('Silme');
                _showAlertDialogForDeletion();
              },
            ),
            TextButton(
              child: Text('Reddet'),
              onPressed: () {
                Navigator.of(context).pop();
                _deny();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showLoadingDialog(process) async {
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
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "$process işlemi gerçekleşiyor. Lütfen bekleyiniz...",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
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

  _confirm() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      )
          .then((value) async {
        await FirebaseFirestore.instance
            .collection(appUsers)
            .doc(value.user.uid)
            .set({
          'companyID': _companyID,
          'image_link': _networkImageLink,
          'mail': _email,
          'name': _name,
          'password': _password,
          'phone': _phone,
          'surname': _surname,
          'userID': _userID,
          'token': _token,
          'time_applied': _timeApplied,
        }).then((value) async {
          await FirebaseFirestore.instance
              .collection(appUsersOnHold)
              .doc(id)
              .delete()
              .then((value) {
            Fluttertoast.showToast(
              msg: "Kullanıcı kaydedildi!",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
            );
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pop(context);
          });
        });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Lütfen daha güvenli bir şifre talep ediniz.')));
        Navigator.of(context, rootNavigator: true).pop();
      } else if (e.code == 'email-already-in-use') {
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                'Bu mail adresine kayıtlı bir kullanıcı bulunmaktadır. Kayıt gerçekleştirilemez.')));
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  _deny() async {
    /*var url = await FirebaseStorage.instance
        .ref(storageUsersOnHold).child(id).getDownloadURL();*/
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserOnHoldDenialReason(id)),
    );
  }

  _delete() async {
    await FirebaseFirestore.instance
        .collection(appUsersOnHold)
        .doc(id)
        .delete();
  }
}

String timeAgo(DateTime dateTime) {
  var format = new DateFormat('dd MMMM yyyy HH:mm');
  return format.format(dateTime);
}
