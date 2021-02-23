import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserCalendarPageView extends StatefulWidget {
  final DateTime date;

  UserCalendarPageView({@required this.date});

  @override
  _UserCalendarPageViewState createState() => _UserCalendarPageViewState();
}

class _UserCalendarPageViewState extends State<UserCalendarPageView> {
  Widget date() {
    var formatter = new DateFormat('dd MMMM yyyy');
    String _dateToday = formatter.format(widget.date);

    return Container(
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Text(
        '$_dateToday',
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.orange[300],
      ),
    );
  }

  Widget entrances() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 15),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4,
        margin: EdgeInsets.all(0),
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20, top: 15, bottom: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                'Giriş',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,),
              ),
            ),
            ListTile(
              leading: Container(
                width: 50,
                child: ClipOval(
                  child: Image.asset('assets/images/yunus_karaaslan.jpg'),
                ),
              ),
              title: Text('Yunus Karaaslan'),
              subtitle: Wrap(
                children: [
                  Text('Giriş Saati: '),
                  Text(
                    '07:55   ',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              trailing: Text(
                '5 dakika',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget exits() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 4,
            margin: EdgeInsets.all(0),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20, top: 15, bottom: 10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Çıkış',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,),
                  ),
                ),
                ListTile(
                  leading: Container(
                    width: 50,
                    child: ClipOval(
                      child: Image(
                        image: AssetImage('assets/images/yunus_karaaslan.jpg'),
                      ),
                    ),
                  ),
                  title: Text('Yunus Karaaslan'),
                  subtitle: Wrap(
                    children: [
                      Text('Çıkış Saati: '),
                      Text(
                        '18:27   ',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '3 dakika',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget excusesWidget() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 4,
            margin: EdgeInsets.all(0),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20, top: 15, bottom: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mazeret',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 50,
                        child: ClipOval(
                          child: Image(
                            image: AssetImage('assets/images/yunus_karaaslan.jpg'),
                          ),
                        ),
                      ),
                      title: Text('Yunus Karaaslan'),
                      subtitle: Container(
                        margin: EdgeInsets.only(top: 5, bottom: 10),
                        child: Text(
                            'İş ile ilgili bir nedenden dolayı erkenden çıkıldı. Şirkete bildirildi.'),
                      ),
                      trailing: Icon(
                        Icons.check,
                        size: 17,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 80),
                      child: Text(
                        "Yusuf Aksut - 12 Ocak 2020 11:25",
                        style:
                        TextStyle(fontSize: 13, color: Colors.blue[200]),
                      ),
                    ),
                    Divider(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: Container(
          child: Text(
            'Giriş Çıkış Durumu',
            style: TextStyle(color: Colors.white),
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              date(),
              entrances(),
              exits(),
              excusesWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
