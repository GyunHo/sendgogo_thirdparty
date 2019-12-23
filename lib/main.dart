import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:provider/provider.dart';
import 'package:sendgogo_thirdparty/screens/candidate_page.dart';

import 'package:sendgogo_thirdparty/utils/barcode_bloc.dart';
import 'screens/auth_page.dart';
import 'screens/out_barcode_page.dart';
import 'screens/in_barcode_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BarcodeBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "main",
        routes: {
          "auth": (context) => AuthPage(),
          "main": (context) => MainWidget()
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}

class MainWidget extends StatefulWidget {
  MainWidget({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> with TickerProviderStateMixin {
  KFDrawerController _drawerController;

  @override
  void initState() {
    super.initState();
    _drawerController = KFDrawerController(
      initialPage: InBarcodePage(),
      items: [
        KFDrawerItem.initWithPage(
          text: Text('입고', style: TextStyle(color: Colors.black)),
          icon: Icon(Icons.input, color: Colors.black),
          page: InBarcodePage(),
        ),
        KFDrawerItem.initWithPage(
          text: Text(
            '출고',
            style: TextStyle(color: Colors.black),
          ),
          icon: Icon(Icons.airport_shuttle, color: Colors.black),
          page: OutBarcodePage(),
        ),
        KFDrawerItem.initWithPage(
          text: Text(
            '기능대기',
            style: TextStyle(color: Colors.black),
          ),
          icon: Icon(Icons.build, color: Colors.black),
          page: Candidate_page(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BarcodeBloc>(context);
    return Scaffold(
      body: KFDrawer(
//        borderRadius: 0.0,
//        shadowBorderRadius: 0.0,
//        menuPadding: EdgeInsets.all(0.0),
//        scrollable: true,
        controller: _drawerController,
//        header: Align(
//          alignment: Alignment.centerLeft,
//          child: Container(
//            padding: EdgeInsets.symmetric(horizontal: 16.0),
//            width: MediaQuery.of(context).size.width * 0.6,
//            child: Image.asset(
//              'assets/logo.png',
//              alignment: Alignment.centerLeft,
//            ),
//          ),
//        ),
        footer: KFDrawerItem(
          text: Text(
            '로그아웃',
            style: TextStyle(color: Colors.black),
          ),
          icon: Icon(
            Icons.input,
            color: Colors.black,
          ),
          onPressed: () {
            bloc.clearInfo();
//            Navigator.popAndPushNamed(context, 'auth');

//            Navigator.of(context).push(CupertinoPageRoute(
//              fullscreenDialog: true,
//              builder: (BuildContext context) {
//                return AuthPage();
//              },
//            ));
          },
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.greenAccent],
            tileMode: TileMode.repeated,
          ),
        ),
      ),
    );
  }
}
