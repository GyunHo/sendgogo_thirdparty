import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:provider/provider.dart';
import 'package:qrscan/qrscan.dart' as qrscan;
import 'package:sendgogo_thirdparty/utils/barcode_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                "입 고",
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(width: size.width * 0.1),
            ],
          ),
          FutureBuilder(
            initialData: _initData,
            future: bloc.inBarcodeStatus(),
            builder: (context, AsyncSnapshot<List<Map>> snapshot) {
              if (snapshot.data == null) {
                return Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text("입고 테이블에 바코드가 없습니다."),
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
                    child: Text("입고 테이블에 바코드가 없습니다."),
                  ),
                );
              } else
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data.length ?? 0,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            print(
                                "넘긴 번호${snapshot.data[index]['no']},넘긴 바코드${snapshot.data[index]['barcode']}, 넘긴아이디 ${snapshot.data[index]['customer']},넘긴 오더넘버${snapshot.data[index]['order_number']} ");
                            bloc.clearBase64();

                            bloc.showDialog(
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
                                                    alignment: Alignment.center,
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
                      }),
                );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                qrscan.scan().then((barcode) {
                  bloc.setEnterBarcode(barcode);
                });
//              bloc.setEnterBarcode('test111');
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
