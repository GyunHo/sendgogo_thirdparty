import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:provider/provider.dart';
import 'package:qrscan/qrscan.dart' as qrscan;
import 'package:sendgogo_thirdparty/utils/barcode_bloc.dart';
import 'package:sendgogo_thirdparty/utils/classes.dart';

class OutBarcodePage extends KFDrawerContent {
  OutBarcodePage({
    Key key,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<OutBarcodePage> {
  List initData = [];

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BarcodeBloc>(context);
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: size.width * 0.1,
                child: Material(
                  child: IconButton(
                    icon: Icon(
                      Icons.list,
                      color: Colors.black,
                    ),
                    onPressed: widget.onMenuPressed,
                  ),
                ),
              ),
              Text(
                "출 고",
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(width: size.width * 0.1),
            ],
          ),
          FutureBuilder(
            initialData: initData,
            future: bloc.outBarcodeStatus(),
            builder: (context, AsyncSnapshot<List> snapshot) {
              if (snapshot.data == null) {
                return Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text("출고 테이블에 바코드가 없습니다."),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    width: size.width * 0.1,
                    height: size.width * 0.1,
                    child: CircularProgressIndicator());
              }
              if (snapshot.data.length == 0) {
                return Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text("출고 테이블에 바코드가 없습니다."),
                  ),
                );
              } else
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            bloc.outRun(snapshot.data[index]['id']);
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
                                  Container(
                                    width: double.infinity,
                                    child: snapshot.data[index]['state']
                                                .toString() ==
                                            "307"
                                        ? Text(
                                            "상태 : 출고완료",
                                            style: TextStyle(fontSize: 15.0),
                                          )
                                        : Text(
                                            "상태 : 출고준비",
                                            style: TextStyle(fontSize: 15.0),
                                          ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                qrscan.scan().then((barcode) {
                  bloc.setOutBarcode(barcode);
                });
//                bloc.setOutBarcode("1111122222");
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(5.0, 5.0),
                          blurRadius: 5.0)
                    ],
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(16.0)),
                child: Text(
                  "바코드 스캔",
                  style: TextStyle(fontSize: 20.0),
                ),
                height: size.height * 0.08,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
