import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sendgogo_thirdparty/utils/barcode_bloc.dart';
import 'package:qrscan/qrscan.dart' as qrscan;

class InputNoDate extends StatefulWidget {
  final Map<String, dynamic> pob;

  const InputNoDate({Key key, this.pob}) : super(key: key);

  @override
  _InputNoDateState createState() => _InputNoDateState();
}

class _InputNoDateState extends State<InputNoDate> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _barcodeEditingController = TextEditingController();
  List queryList = [];
  Map<String, dynamic> datas = {
    "on_image1": "",
    "on_image2": "",
    "on_image3": "",
    "on_image4": "",
    "on_image5": "",
  };

  listing(String query) {
    queryList.clear();
    List queryResult = pob.keys.toList().where((val) {
      return val.contains(query);
    }).toList();
    setState(() {
      queryList.addAll(queryResult);
    });
  }

  Map<String, dynamic> pob = {};

  @override
  void initState() {
    pob = widget.pob;
    print(pob);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BarcodeBloc>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[RaisedButton(onPressed: (){
          if(_globalKey.currentState.validate()){
            _globalKey.currentState.save();
            print(datas);
          }
        },)],
        title: Text("noDate 등록"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        onSaved: (val){
                          datas['on_local_invoice'] = val;
                        },
                        controller: _barcodeEditingController,
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "트레킹 번호는 필수 입니다. 입력 또는 스캔 해주세요";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            labelText: "트레킹번호",
                            hintText: "트레킹번호 입력 또는 스캔",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_enhance),
                      onPressed: () async {
                        await qrscan.scan().then((barcode) {
                          _barcodeEditingController.text = barcode;
                        });
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                TextFormField(
                  onSaved: (val){
                    datas['on_mb_pob_no'] = val;
                  },
                    validator: (val){
                    if(val.isEmpty){
                      return "사서함은 빈칸일수 없습니다.";
                    }else{
                    return  null;
                    }
                    },
                    decoration: InputDecoration(

                        labelText: "개인사서함",
                        hintText: "개인사서함 입력",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    controller: _textEditingController,
                    onChanged: (val) {
                      if (val.isEmpty) {
                        setState(() {
                          queryList.clear();
                        });
                      } else {
                        listing(val.toUpperCase().toString());
                      }
                    }),
                Container(
                  height: MediaQuery.of(context).size.height * 0.18,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      itemCount: queryList.length,
                      itemBuilder: (context, index) {
                        String title = queryList[index].toString();
                        return ListTile(
                          onTap: () {
                            _textEditingController.text = title;
                            setState(() {
                              queryList.clear();
                            });
                          },
                          title: Text(title.toString()),
                          subtitle: Text(pob[title].toString()),
                        );
                      }),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.black)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "사진첨부",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  onPressed: () {},
                ),
                Container(
                  height: MediaQuery.of(context).size.width * 0.3,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: datas.keys.toList().map((val) {
                        if (datas[val] != "") {
                          return Card(
                            child: Image.memory(
                              base64Decode(datas[val]),
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width * 0.3,
                            ),
                          );
                        } else {
                          return Card(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: IconButton(
                                icon: Icon(Icons.add_a_photo),
                                onPressed: () async {
                                  await cameraOrAlbum().then((File res) async {
                                    if (res != null) {
                                      String base64Image =
                                          base64Encode(res.readAsBytesSync());
                                      setState(() {
                                        datas[val] = base64Image;
                                      });
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        }
                      }).toList()),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<File> cameraOrAlbum() async {
    File image;
    await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("사진 첨부"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.camera_enhance),
                          onPressed: () async {
                            File reImage = await ImagePicker.pickImage(
                                source: ImageSource.camera);
                            Navigator.pop(context, reImage);
                          },
                        ),
                        Text("카메라")
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.photo_album),
                          onPressed: () async {
                            File reImage = await ImagePicker.pickImage(
                                source: ImageSource.gallery);
                            Navigator.pop(context, reImage);
                          },
                        ),
                        Text("앨범")
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }).then((res) {
      image = res;
    });
    return image;
  }
}
