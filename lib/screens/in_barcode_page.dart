import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:provider/provider.dart';
import 'package:qrscan/qrscan.dart' as qrscan;
import 'package:sendgogo_thirdparty/screens/input_nodata_page.dart';
import 'package:sendgogo_thirdparty/utils/barcode_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class InBarcodePage extends KFDrawerContent {
  InBarcodePage({
    Key key,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<InBarcodePage> {
  List<Map> _initData = [];

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BarcodeBloc>(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Row(
            children: <Widget>[
              Text('노데이터'),
              IconButton(
                icon: Icon(Icons.library_add),
                onPressed: () async {
                  try {
                    Map<String, dynamic> deno = await getDeNo(bloc.getUrl());
                    await getPob(bloc.getUrl()).then((res) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InputNoDate(
                                    pob: res,
                                    deno: deno,
                                  ))).then((popRes) {
                        try {
                          if (popRes) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text("데이터를 등록 했습니다."),
                            ));
                          }
                          if (!popRes) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text("데이터 등록 실패 했습니다. 다시 시도해 주세요."),
                            ));
                          }
                        } catch (e) {
                          print('아무 결과 없이 노데이터 빠짐');
                        }
                      });
                    });
                  } catch (e) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("페이지 url 오류 또는 알수 없는 오류"),
                    ));
                  }
                },
              ),
            ],
          )
        ],
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.list,
            color: Colors.white,
          ),
          onPressed: widget.onMenuPressed,
        ),
        title: Text('입고'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FutureBuilder(
                initialData: _initData,
                future: bloc.inBarcodeStatus(),
                builder: (context, AsyncSnapshot<List<Map>> snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        alignment: Alignment.center, child: Text("바코드가 없습니다."));
                  }
                  if (snapshot.connectionState == ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        alignment: Alignment.center,
                        width: size.width * 0.1,
                        height: size.width * 0.1,
                        child: CircularProgressIndicator());
                  } else
                    return ListView.builder(
                        itemCount: snapshot?.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              print(
                                  "넘긴 번호${snapshot.data[index]['no']},넘긴 바코드${snapshot.data[index]['barcode']}, 넘긴아이디 ${snapshot.data[index]['customer']},넘긴 오더넘버${snapshot.data[index]['order_number']} ");
                              bloc.clearBase64();

                              bloc.showSendDialog(
                                  context,
                                  snapshot.data[index]['no'].toString(),
                                  snapshot.data[index]['customer'],
                                  snapshot.data[index]['barcode'],
                                  snapshot.data[index]['order_number']);
                            },
                            child: Card(
                              elevation: 5.0,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            width: size.width * 0.4,
                                            child: Text(
                                                "검색 바코드 : ${snapshot.data[index]['barcode']}"),
                                          ),
                                          Container(
                                            width: size.width * 0.4,
                                            child: Text(
                                                "주문ID : ${snapshot.data[index]['customer'].isEmpty ? "?" : "${snapshot.data[index]['customer']}"}"),
                                          ),
                                        ],
                                      ),
                                      width: double.infinity,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        CachedNetworkImage(
                                          height: size.width * 0.2,
                                          width: size.width * 0.2,
                                          imageUrl: snapshot.data[index]['url'],
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                  height: size.width * 0.2,
                                                  width: size.width * 0.2,
                                                  child: Center(
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.clear,
                                                          size: 50.0,
                                                          color: Colors.grey,
                                                        ),
                                                        Text("No Image!"),
                                                      ],
                                                    ),
                                                  )),
                                        ),
                                        Container(
                                          width: size.width * 0.2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                  "상품 : ${snapshot.data[index]['item_name'] ?? "?"}"),
                                              Text(
                                                  "수량 : ${snapshot.data[index]['item_count'] ?? 0}"),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: size.width * 0.2,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                  "옵션1 : ${snapshot.data[index]['option1'].isEmpty ? "없음" : "${snapshot.data[index]['option1']}"}"),
                                              Text(
                                                  "옵션2 : ${snapshot.data[index]['option2'].isEmpty ? "없음" : "${snapshot.data[index]['option2']}"}"),
                                            ],
                                          ),
                                        ),
                                        SizedBox(),
                                      ],
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: snapshot.data[index]['state']
                                                  .toString() ==
                                              "1003"
                                          ? Text(
                                              "상태 : 입고완료",
                                              style: TextStyle(fontSize: 15.0),
                                            )
                                          : Text(
                                              "상태 : 입고대기",
                                              style: TextStyle(fontSize: 15.0),
                                            ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                },
              ),
            ),
            InkWell(
              onTap: () async {
                qrscan.scan().then((barcode) async {
                  bloc.setEnterBarcode(barcode);
                });

//                bloc.setEnterBarcode('8806011615408');
              },
              child: SizedBox(
                width: size.width,
                height: size.height * 0.1,
                child: Card(
                  elevation: 5.0,
                  color: Colors.white,
                  child: Center(
                      child: Text(
                    "바코드 스캔",
                    style: TextStyle(color: Colors.black),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getDeNo(String url) async {
    Map<String, dynamic> list = Map();
    Map body = {'query': 'nt_service_delivery_view', 'action': 'r'};
    http.Response response = await http.post(url, body: body);
    List<dynamic> json = jsonDecode(response.body);
    for (var i in json) {
      String key = '[${i['de_send_code']}] ${i['de_name']}';
      String value = i['de_no'].toString();
      list[key] = value;
    }
    return list;
  }

  Future<Map<String, dynamic>> getPob(String url) async {
    Map<String, dynamic> list = Map();
    Map body = {'query': 'nt_member_view', 'action': 'r'};
    http.Response response = await http.post(url, body: body);
    List<dynamic> json = jsonDecode(response.body);
    for (var i in json) {
      String mb_id = i['mb_id'];
      String mb_name = i['mb_name'];
      String mb_pob_no = i['mb_pob_no'];
      String pob_text = '$mb_pob_no $mb_id($mb_name)';

      list[mb_pob_no] = pob_text;
    }
    return list;
  }
}
