import 'dart:convert';
import 'dart:io';

import 'package:sendgogo_thirdparty/screens/in_barcode_detail_page.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'classes.dart';
import 'package:http/http.dart' as http;

class BarcodeBloc extends ChangeNotifier {
  Map<String, Map<String, String>> imgLog = {};
  List _list;
  List<String> _bas64Images = [];
  String _enterBarcode;
  String _outBarcode;
  String _userId;
  String _pw;
  String _url = '';
  String url2 = '';
  String _requestUrl =
      'http://mobilescan.sendgogo.com/elpisbbs/app_register.php';

  getList() => _list;

  clearInfo() => _enterBarcode = null;

  setUser(String id) => _userId = id;

  getUser() => _userId;

  List<String> getImageList() => _bas64Images;



  void writeImageLog(no, barcode, order_num, cusid) async {
    http.Response res = await http.post(getUrl(), body: {
      'query':
          'nt_order_item SET it_state=1003, it_image1="${imgLog[no]['it_image1']}",it_image2="${imgLog[no]['it_image2']}",it_image3="${imgLog[no]['it_image3']}",it_image4="${imgLog[no]['it_image4']}",it_image5="${imgLog[no]['it_image5']}",it_image6="${imgLog[no]['it_image6']}",it_image7="${imgLog[no]['it_image7']}",it_image8="${imgLog[no]['it_image8']}",it_image9="${imgLog[no]['it_image9']}",it_image10="${imgLog[no]['it_image10']}" WHERE it_no=$no and it_local_invoice="$barcode" ',
      'order_number': order_num,
      'customer_id': cusid,
      'action': 'in'
    });
    notifyListeners();
    print(res.body.toString());
  }

  String getUrl() => _url;

  void sendImage(String id_no, String cusname) {
    if (getImageList().isNotEmpty) {
      for (var base64 in _bas64Images) {
        var image_name =
            "from_android_${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

        http.post(getUrl(), body: {
          "image": base64,
          "image_name": image_name,
          "folder_name": cusname,
          'action': 'c'
        }).then((result) {
          print(result.statusCode);
          print(result.body);
        }).catchError((error) {
          print(error);
        });
        for (var i = 0; i < 10; i++) {
          if (imgLog[id_no]['it_image${i + 1}'] == "" ||
              imgLog[id_no]['it_image${i + 1}'] == "None" ||
              imgLog[id_no]['it_image${i + 1}'] == null ||
              imgLog[id_no]['it_image${i + 1}'] == "null") {
//              imgLog[id_no]['it_image${i + 1}'] = "$cusname/$image_name";
            imgLog[id_no]['it_image${i + 1}'] = image_name;
            break;
          }
        }
      }
      print(imgLog);
    }
  }

  void showSendDialog(context, id_no, cusname, barcode, order_numbet) {
    slideDialog.showSlideDialog(
        context: context,
        child: InDetail(
          id_no: id_no,
          cus_name: cusname,
          barcode: barcode,
          order_number: order_numbet,
        ));
  }

  void clearBase64() {
    print("64이미지 클리어 전 $_bas64Images");
    _bas64Images.clear();
    print("64이미지 클리어 후 $_bas64Images");
  }

  Future<void> shotToString() async {
    File cap = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 1920, maxWidth: 1080);
    String base64Image = base64Encode(cap.readAsBytesSync());
    _bas64Images.add(base64Image);
    print(base64Image);
    notifyListeners();
  }

  setOutBarcode(String barcode) {
    _outBarcode = barcode;
    notifyListeners();
  }

  Future<void> setEnterBarcode(String barcode) async {
    _enterBarcode = barcode;
    notifyListeners();
  }

  Future<String> check(context, id, pw) async {
    String res = '';
    http.Response response =
        await http.post(_requestUrl, body: {'id': id, 'key': pw});
    if (response.statusCode != 200) {
      res = 'connection fail';
    }
    if (response.statusCode == 200 && response.body == 'fail') {
      res = 'login fail';
    }
    if (response.statusCode == 200 && response.body != 'fail') {
      String url = response.body;
      url2 = 'http://www.$url';
      _url = 'http://www.$url/test.php';

      res = 'success';
    }
    return res;
  }

  Future<List<Map>> inBarcodeStatus() async {
    imgLog.clear();
    final http.Response response = await http.post(getUrl(), body: {
      'query':
          'nt_order_item WHERE it_state!=1003 AND it_local_invoice="$_enterBarcode"',
      'action': 'r'
    });
    List jsons = jsonDecode(response.body);
    List<Map> dummy = List();

    for (var a in jsons) {
      Map<String, dynamic> res = {
        'no': a['it_no'],
        'customer': a['it_mb_id'],
        'item_name': a['it_name'],
        'url': a['it_img_url'],
        'option1': a['it_option1'],
        'option2': a['it_option2'],
        'item_count': a['it_count'],
        'barcode': a['it_local_invoice'],
        'state': a['it_state'],
        'order_number': a['it_or_code']
      };
      dummy.add(res);

      imgLog[a['it_no']] = {
        'it_image1': a['it_image1'],
        'it_image2': a['it_image2'],
        'it_image3': a['it_image3'],
        'it_image4': a['it_image4'],
        'it_image5': a['it_image5'],
        'it_image6': a['it_image6'],
        'it_image7': a['it_image7'],
        'it_image8': a['it_image8'],
        'it_image9': a['it_image9'],
        'it_image10': a['it_image10'],
      };
      print(imgLog);
    }

    return dummy;
  }

  void outRun(no) async {
    final http.Response response = await http.post(getUrl(), body: {
      'query': 'nt_order_group SET gr_state=307 WHERE gr_no=$no',
      'action': 'w'
    });

    notifyListeners();
  }

  Future<List<Map>> outBarcodeStatus() async {
    final http.Response response = await http.post(getUrl(), body: {
      'query': 'nt_order_group WHERE gr_tc_invoice="$_outBarcode"',
      'action': 'r'
    });
    List jsons = jsonDecode(response.body);
    List<Map> dummy = [];

    for (Map<String, dynamic> i in jsons) {
      final res = Map();

      res['id'] = i['gr_no'];
      res['customer'] = i['gr_mb_id'];
      res['barcode'] = i['gr_tc_invoice'];
      res['state'] = i['gr_state'];
      dummy.add(res);
    }

    return dummy;
  }
}
