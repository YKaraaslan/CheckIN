import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:unity_checkin/core/utilities/constants.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:unity_checkin/ui/model/sign_up_denial_model.dart';
import 'company_selection_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SignUp extends StatelessWidget {
  final SignUpDenialModel userModel;

  SignUp(this.userModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SignUpBody(userModel),
    );
  }
}

class SignUpBody extends StatefulWidget {
  final SignUpDenialModel userModel;

  SignUpBody(this.userModel);

  @override
  _SignUpBodyState createState() => _SignUpBodyState(userModel);
}

class _SignUpBodyState extends State<SignUpBody> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final mailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordRepeatController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final companyController = TextEditingController();

  bool _isMailVisible = false;
  bool _isPhoneVisible = false;
  bool _isPasswordVisible = false;
  bool _isPasswordRepeatVisible = false;
  bool _isNameVisible = false;
  bool _isSurnameVisible = false;
  bool _isCompanyVisible = false;
  bool _isPhotoVisible = false;
  bool saved = false;

  String _imageName = getRandString();

  double _progressValue = 0;

  File _image;
  final picker = ImagePicker();

  var result;

  SignUpDenialModel userModel;

  _SignUpBodyState(this.userModel);

  @override
  void initState() {
    if (userModel != null) {
      nameController.text = userModel.name;
      surnameController.text = userModel.surname;
      mailController.text = userModel.mail;
      phoneController.text = userModel.phone;
      passwordController.text = userModel.password;
      passwordRepeatController.text = userModel.password;
    }
    super.initState();
  }

  @override
  void dispose() {
    mailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    passwordRepeatController.dispose();
    nameController.dispose();
    surnameController.dispose();
    companyController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool _photo = false;
    bool _mails = false,
        _phone = false,
        _passwords = false,
        _passwordRepeats = false,
        _names = false,
        _surnames = false,
        _companies = false;

    if (_image == null && userModel == null) {
      _photo = true;
    }
    if (nameController.text.trim().length == 0) {
      _names = true;
    }
    if (surnameController.text.trim().length == 0) {
      _surnames = true;
    }
    if (!EmailValidator.validate(mailController.text.trim())) {
      _mails = true;
    }
    if (phoneController.text.trim().contains('.') ||
        phoneController.text.trim().isEmpty ||
        phoneController.text.length < 11 ||
        phoneController.text.length > 13) {
      _phone = true;
    }
    if (passwordController.text.trim().length < 5 ||
        passwordController.text.length > 16 ||
        passwordController.text.trim().isEmpty) {
      _passwords = true;
    }
    if (passwordRepeatController.text != passwordController.text) {
      _passwordRepeats = true;
    }
    if (result == null) {
      _companies = true;
    }

    setState(() {
      _isMailVisible = _mails;
      _isPhoneVisible = _phone;
      _isPasswordVisible = _passwords;
      _isPasswordRepeatVisible = _passwordRepeats;
      _isNameVisible = _names;
      _isSurnameVisible = _surnames;
      _isCompanyVisible = _companies;
      _isPhotoVisible = _photo;
    });

    if (_photo ||
        _mails ||
        _phone ||
        _passwords ||
        _passwordRepeats ||
        _companies ||
        _surnames ||
        _names) {
      return false;
    }
    return true;
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "İşleminiz gerçekleşiyor. Lütfen bekleyiniz...",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: Colors.white,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> signUp() async {
    String token = await _fcm.getToken();

    await FirebaseFirestore.instance.collection(appUsersOnHold).where('token', isEqualTo: token).get().then((value) {
      if (value.docs.isNotEmpty){
        Fluttertoast.showToast(msg: 'Bu telefona ait kayıtlı bir hesap bulunmaktadır.', timeInSecForIosWeb: 1);
        return;
      }
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(storageUsersOnHold)
          .child(_imageName);

      ref.putFile(_image).then((event) async {
        String link = await event.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection(appCompanies)
            .where('name', isEqualTo: result)
            .get()
            .then((value) {
          CollectionReference usersOnHold =
          FirebaseFirestore.instance.collection(appUsersOnHold);

          usersOnHold
              .add({
            'name': nameController.text.trim(),
            'surname': surnameController.text.trim(),
            'mail': mailController.text.trim(),
            'phone': phoneController.text.trim(),
            'password': passwordController.text.trim(),
            'companyID': value.docs.first.id,
            'time_applied': DateTime.now(),
            'token': token,
            'image_link': link,
            'image_name': _imageName,
            'status': 'waiting',
            'status_denied_by': '',
            'status_denied_time': DateTime.now(),
            'status_denied_message': '',
          }).then((value) {
            Navigator.pop(context, true);
          });
        }).catchError((error) {});

        setState(() {
          _progressValue =
              event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        });
      });
    });

    await FirebaseAuth.instance.signOut().then((value) => Navigator.of(context, rootNavigator: true).pop());
  }

  Future<void> update() async {
    String token = await _fcm.getToken();


    if(_image != null){
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(storageUsersOnHold)
          .child(userModel.imageName);

      await ref.delete().then((value) async {
        await ref.putFile(_image).then((event) async {
          String link = await event.ref.getDownloadURL();
          await FirebaseFirestore.instance
              .collection(appCompanies)
              .where('name', isEqualTo: result)
              .get()
              .then((value) {
            CollectionReference usersOnHold =
            FirebaseFirestore.instance.collection(appUsersOnHold);

            usersOnHold
                .doc(userModel.docID)
                .update({
              'name': nameController.text.trim(),
              'surname': surnameController.text.trim(),
              'mail': mailController.text.trim(),
              'phone': phoneController.text.trim(),
              'password': passwordController.text.trim(),
              'companyID': value.docs.first.id,
              'time_applied': DateTime.now(),
              'token': token,
              'image_link': link,
              'image_name': userModel.imageName,
              'status': 'waiting',
              'status_denied_by': '',
              'status_denied_message': '',
            }).then((value) {
              Navigator.pop(context, true);
            });
          });

          setState(() {
            _progressValue =
                event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
          });
        }).catchError((error) {});
      });
    }
    else{
      await FirebaseFirestore.instance
          .collection(appCompanies)
          .where('name', isEqualTo: result)
          .get()
          .then((value) {
        CollectionReference usersOnHold = FirebaseFirestore.instance.collection(appUsersOnHold);

        usersOnHold
            .doc(userModel.docID)
            .update({
          'name': nameController.text.trim(),
          'surname': surnameController.text.trim(),
          'mail': mailController.text.trim(),
          'phone': phoneController.text.trim(),
          'password': passwordController.text.trim(),
          'companyID': value.docs.first.id,
          'time_applied': DateTime.now(),
          'token': token,
          'status': 'waiting',
          'status_denied_by': '',
          'status_denied_message': '',
        }).then((value) {
          Navigator.pop(context, true);
        });
      });
    }

    await FirebaseAuth.instance.signOut();
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CompanySelectionScreen()),
    );

    if (result != null) {
      setState(() {
        result = result;
      });
    }
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Widget photo() {
    return InkWell(
      onTap: () async {
        await getImage();
      },
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 50,
        backgroundImage: _image == null
            ? userModel == null
                ? AssetImage('assets/images/logo.png')
                : NetworkImage(userModel.imageLink)
            : FileImage(_image),
      ),
    );
  }

  Widget photoValidatorText() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Visibility(
        visible: _isPhotoVisible,
        child: Text(
          'Bir fotoğraf seçiniz.',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    ));
  }

  Widget _buildName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'İsim',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: nameController,
            keyboardType: TextInputType.name,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: 'İsminiz...',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget nameValidatorText() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Visibility(
        visible: _isNameVisible,
        child: Text(
          'Geçerli bir isim giriniz.',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    ));
  }

  Widget _buildSurname() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Soyisim',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: surnameController,
            keyboardType: TextInputType.name,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: 'Soyisminiz...',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget surnameValidatorText() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Visibility(
        visible: _isSurnameVisible,
        child: Text(
          'Geçerli bir soyisim giriniz.',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    ));
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Mail Adresi',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: mailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Mail Adresiniz...',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget emailValidatorText() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Visibility(
        visible: _isMailVisible,
        child: Text(
          'Geçerli bir mail adresi giriniz.',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    ));
  }

  Widget _buildPhoneNumber() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Telefon Numarası',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.phone_android,
                color: Colors.white,
              ),
              hintText: 'Telefon Numaranız...',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget phoneValidatorText() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Visibility(
        visible: _isPhoneVisible,
        child: Text(
          'Geçerli bir telefon numarası giriniz.',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    ));
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Şifre',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: passwordController,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Şifreniz...',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget passwordValidatorText() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 7.0, left: 5, right: 5),
      child: Visibility(
        visible: _isPasswordVisible,
        child: Text(
          'Şifreniz 5 haneden büyük 16 haneden küçük olmalıdır ve boş bırakılamaz.',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    ));
  }

  Widget _buildPasswordRepeat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Şifre Tekrar',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: passwordRepeatController,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock_open_outlined,
                color: Colors.white,
              ),
              hintText: 'Şifre tekrar...',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget passwordRepeatValidatorText() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 7.0, left: 5, right: 5),
      child: Visibility(
        visible: _isPasswordRepeatVisible,
        child: Text(
          'Şifreleriniz uyuşmamaktadır.',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    ));
  }

  Widget _buildCompanies() {
    return InkWell(
      onTap: () {
        _navigateAndDisplaySelection(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Şirket İsmi',
            style: kLabelStyle,
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Icon(
                    Icons.work,
                    color: Colors.white,
                  ),
                ),
                Text(
                  result == null ? 'Şirketiniz...' : result,
                  style: result == null
                      ? TextStyle(
                          color: Color(0xffBCD7F9),
                          fontFamily: 'OpenSans',
                          fontSize: 17)
                      : TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget companyValidatorText() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 7.0, left: 5, right: 5),
      child: Visibility(
        visible: _isCompanyVisible,
        child: Text(
          'Geçerli bir şirket seçiniz.',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    ));
  }

  Widget _buildSignUpBtn() {
    return Container(
      padding: EdgeInsets.only(top: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          if(!_validate())
            return;
          if (userModel == null) {
            _showAlertDialog("Kayıt");
          } else {
            _showAlertDialog("Güncelleme");
          }
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Kayıt Ol',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              vertical: 50.0,
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
                photo(),
                photoValidatorText(),
                SizedBox(height: 30.0),
                _buildName(),
                nameValidatorText(),
                SizedBox(height: 20.0),
                _buildSurname(),
                surnameValidatorText(),
                SizedBox(height: 20.0),
                _buildEmailTF(),
                emailValidatorText(),
                SizedBox(height: 20.0),
                _buildPhoneNumber(),
                phoneValidatorText(),
                SizedBox(
                  height: 20.0,
                ),
                _buildPasswordTF(),
                passwordValidatorText(),
                SizedBox(
                  height: 20.0,
                ),
                _buildPasswordRepeat(),
                passwordRepeatValidatorText(),
                SizedBox(
                  height: 20.0,
                ),
                _buildCompanies(),
                companyValidatorText(),
                _buildSignUpBtn(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAlertDialog(process) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$process yapılacaktır. Onaylıyor musunuz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Evet'),
              onPressed: () {
                Navigator.pop(context, true);
                showLoadingDialog();
                if (process == "Kayıt") {
                  signUp();
                } else {
                  update();
                }
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
}

String getRandString() {
  var random = Random.secure();
  var values = List<int>.generate(15, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}