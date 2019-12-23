import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendgogo_thirdparty/utils/barcode_bloc.dart';

class InDetail extends StatefulWidget {

  final String cus_name;
  final String id_no;
  final String barcode;


  const InDetail({Key key, this.cus_name, this.id_no, this.barcode}) : super(key: key);
  @override
  _InDetailState createState() => _InDetailState();
}

class _InDetailState extends State<InDetail> {




  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BarcodeBloc>(context);
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,

        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              "입고 처리",
              style: TextStyle(fontSize: 30.0),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            height: size.height * 0.2,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bloc.getImageList().length + 1,
                itemBuilder: (context, index) {
                  return index == 0
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          margin: EdgeInsets.only(right: 8.0),
                          width: size.width * 0.3,
                          child: Card(
                            elevation: 5.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.add_a_photo),
                                    onPressed: () {
                                      bloc.shotToString();
                                    }),
                                Text("사진 추가")
                              ],
                            ),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(right: 8.0),
                          width: size.width * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: MemoryImage(
                                  base64Decode(bloc.getImageList()[index - 1])),
                            ),
                          ),
                        );
                }),
          ),
          Container(
            width: size.width * 0.4,
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                elevation: 5.0,
                color: Colors.blue.withOpacity(0.7),
                child: FlatButton(
                  onPressed: () {
                    bloc.sendImage(widget.id_no,widget.cus_name);
                    bloc.writeImageLog(widget.id_no, widget.barcode);

                    Navigator.pop(context);
                  },
                  child: Text("입고완료전송"),
                )),
          )
        ],
      ),
    );
  }
}
