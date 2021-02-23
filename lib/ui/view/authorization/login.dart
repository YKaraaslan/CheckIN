import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_checkin/core/utilities/constants.dart';
import 'package:unity_checkin/core/utilities/strings.dart';

import '../main_page.dart';
import 'password_forgotten.dart';
import 'sign_up.dart';
import 'sign_up_status.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBody(),
    );
  }
}

class LoginBody extends StatefulWidget {
  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  bool _rememberMe = true, _isEmailVisible = false, isPasswordVisible = false;
  String userNameString, userPasswordString;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Kullanıcı Adı',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            onChanged: (value){
              userNameString = value;
            },
            controller: usernameController,
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
              hintText: 'Kullanıcı adınız...',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emailValidatorText() {
    return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 7.0, left: 5, right: 5),
          child: Visibility(
            visible: _isEmailVisible,
            child: Text(
              'Geçerli bir kullanıcı adı giriniz.',
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
            onChanged: (value){
              userPasswordString = value;
            },
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

  Widget _passwordValidatorText() {
    return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 7.0, left: 5, right: 5),
          child: Visibility(
            visible: isPasswordVisible,
            child: Text(
              'Şifre hanesi boş bırakılamaz.',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ));
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => Navigator.push(
            context, new MaterialPageRoute(builder: (context) => new PasswordForgotten())),
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Şifremi Unuttum',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value;
                });
              },
            ),
          ),
          Text(
            'Beni Hatırla',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          await _login();
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Giriş Yap',
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

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () async { await _navigateAndDisplaySelection(context); },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Hesabınız yok mu? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Kayıt Olun',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLookUp() {
    return GestureDetector(
      onTap: () async { await
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => new SignUpStatus())); },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Kayıt durumunuz için ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'buraya tıklayın',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
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
                    _buildEmailTF(),
                    _emailValidatorText(),
                    SizedBox(
                      height: 20.0,
                    ),
                    _buildPasswordTF(),
                    _passwordValidatorText(),
                    Container(
                      width: double.infinity,
                      child: Stack(
                        children: [
                          _buildForgotPasswordBtn(),
                          _buildRememberMeCheckbox(),
                        ],
                      ),
                    ),
                    _buildLoginBtn(),
                    _buildSignupBtn(),
                    SizedBox(
                      height: 15.0,
                    ),
                    _buildLookUp(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  var result;

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUp(null)),
    );

    print(result);

    if (result == true) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Kayıt isteğiniz gönderilmiştir. Kaydınız onaylandığı takdirde bildirim alacaksınız. ')));
    }
  }

  bool _validate(){
    bool _username = false, _password = false;
    if (usernameController.text.trim().length == 0) {
      _username = true;
    }
    if (passwordController.text.trim().length == 0) {
      _password = true;
    }
    setState(() {
      _isEmailVisible = _username;
      isPasswordVisible = _password;
    });
    if (_username || _password) {
      return false;
    }
    return true;
  }

  Future<void> _login() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    showLoadingDialog();
    if (!_validate()) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }

    FirebaseFirestore.instance
        .collection(appUsers)
        .where('mail',isEqualTo: userNameString)
        .where('password',isEqualTo: userPasswordString)
        .get()
        .then((value) async {
          print(value.size);
          if(value.docs.isNotEmpty){
            prefs.setBool(signed_in, _rememberMe);
            var user = value.docs.first;

            prefs.setString(my_id, user.get(user_id));
            prefs.setString(my_name, user.get(name));
            prefs.setString(my_surname, user.get(surname));
            prefs.setString(my_company_id, user.get(company_id));
            prefs.setString(my_mail, user.get(mail));
            prefs.setString(my_password, user.get(password));
            prefs.setString(my_phone, user.get(phone));

            await FirebaseFirestore.instance.collection(appCompanies).where("companyID", isEqualTo: user.get(company_id)).get().then((value)
            {
              var document = value.docs.first;
              prefs.setString(dbRegisters, document.get(dbRegisters));
              prefs.setString(dbUsers, document.get(dbUsers));
              prefs.setString(dbExcuses, document.get(dbExcuses));
            });

            try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: userNameString,
                  password: userPasswordString
              );
              Navigator.pushReplacement(
                  context, new MaterialPageRoute(builder: (context) => new MainPage()));
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                print('No user found for that email.');
              } else if (e.code == 'wrong-password') {
                print('Wrong password provided for that user.');
              }

              prefs.clear();
              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Yanlış kullanıcı adı veya şifre. ')));
              Navigator.of(context, rootNavigator: true).pop();
            }
            return;
          }
          else{
            Scaffold.of(context).showSnackBar(SnackBar(content: Text('Yanlış kullanıcı adı veya şifre. ')));
            Navigator.of(context, rootNavigator: true).pop();
          }
    }).catchError((error) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      Navigator.of(context, rootNavigator: true).pop();
    });
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
                      "Giriş yapılıyor. Lütfen bekleyiniz...",
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
}
