import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendgogo_thirdparty/utils/barcode_bloc.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size sise = MediaQuery.of(context).size;
    final bloc = Provider.of<BarcodeBloc>(context);

    return Scaffold(
      key: _globalKey,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Flexible(
                  child: Image(
                    image: AssetImage('assets/login.gif'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: sise.height * 0.4,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        elevation: 8.0,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Form(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: "아이디",
                                      icon: Icon(Icons.perm_identity),
                                      hintText: "아이디"),
                                  controller: _idController,
                                ),
                                TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      labelText: "비밀번호",
                                      icon: Icon(Icons.security),
                                      hintText: "비밀번호"),
                                  controller: _passwordController,
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Material(
                                  color: Colors.greenAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  elevation: 8.0,
                                  child: FlatButton(
                                    onPressed: () {
                                      bloc
                                          .check(context, _idController.text,
                                              _passwordController.text)
                                          .then((res) {
                                        if (res != "login success") {
                                          _globalKey.currentState.showSnackBar(
                                            SnackBar(
                                              duration:
                                                  Duration(milliseconds: 1000),
                                              content:
                                                  Text("아이디 또는 비밀번호를 확인해 주세요."),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    child: Text(
                                      "로그인",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//
//class AuthPage extends StatefulWidget {
//  @override
//  _AuthPageState createState() => _AuthPageState();
//}
//
//class _AuthPageState extends State<AuthPage> {
//  @override
//  Widget build(BuildContext context) {
//    final bloc = Provider.of<BarcodeBloc>(context);
//
//    return Scaffold(
//      body: Container(
//        child: SafeArea(
//          child: Center(
//            child: Column(
//              children: <Widget>[
//                FlatButton(
//                  onPressed: () {
//                    bloc.check(context, 'elpis', 'dnfl7532@#');
//                  },
//                  child: Text("go home"),
//                ),
//                Row(
//                  children: <Widget>[
//                    ClipRRect(
//                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
//                      child: Material(
//                        shadowColor: Colors.transparent,
//                        color: Colors.transparent,
//                        child: IconButton(
//                          icon: Icon(
//                            Icons.menu,
//                            color: Colors.black,
//                          ),
//                          onPressed: () {},
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//                Expanded(
//                  child: Column(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Text('Sign in'),
//                    ],
//                  ),
//                ),
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//}
