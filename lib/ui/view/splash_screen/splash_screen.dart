import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:unity_checkin/core/utilities/strings.dart';
import 'package:unity_checkin/ui/view/authorization/login.dart';

import '../main_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool signedIn = false;
  String appName, packageName, version, buildNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPackageInfo());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      appName = info.appName;
      packageName = info.packageName;
      version = info.version;
      buildNumber = info.buildNumber;
    });

    Future.delayed(const Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(prefs.getBool(signed_in) != null && prefs.getBool(signed_in)){
        try{
          String email = prefs.getString(my_mail);
          String password = prefs.getString(my_password);

          EmailAuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

          await FirebaseAuth.instance.currentUser.reauthenticateWithCredential(credential);
        }
        catch (e) { }
        finally {
          Navigator.pushReplacement(
              context, new MaterialPageRoute(builder: (context) => new MainPage()));
        }
      }
      else{
        Navigator.pushReplacement(
            context, new MaterialPageRoute(builder: (context) => new Login()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: 10, top: 20),
                child: ListTile(
                  title: Text(
                    "Unity Mobil",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        fontSize: 30,
                        fontFamily: 'Redressed'),
                  ),
                  subtitle: Text(
                    "Unity Çalışan Takip Sistemi",
                    style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        fontSize: 21,
                        fontFamily: 'Redressed'),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Image(
                image: AssetImage('assets/images/unity_logo.png'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Wrap(
                children: [
                  Text(
                    'Version: ',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$version',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
