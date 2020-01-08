import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sendgogo_thirdparty/utils/barcode_bloc.dart';

class InputNoDate extends StatefulWidget {
  @override
  _InputNoDateState createState() => _InputNoDateState();
}

class _InputNoDateState extends State<InputNoDate> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BarcodeBloc>(context);
    String url = bloc.url2 + '/elpisbbs/ajax.nt_typeahead.php';

    Future<Map<String, dynamic>> getPob(String url) async {
      Map<String, dynamic> list = Map();
      Map body = {'mode': 'mb_pob_no', 'name': ''};
      http.Response response = await http.post(url, body: body);
      List<dynamic> json = jsonDecode(response.body);
      for (var i in json) {
        list[i['pob_no']] = i['mb_text'];
      }

      return list;
    }

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          RaisedButton(
            onPressed: () async {
              print(url);
              await getPob(url).then((res) {
                print(res);
              });
            },
          )
        ],
        title: Text("noDate 등록"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[],
        ),
      ),
    );
  }
}
