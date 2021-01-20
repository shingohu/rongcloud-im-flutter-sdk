import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:http/http.dart' as http;

class RCIM {
  static final String _RM_API_HOST1 = "https://api-cn.ronghub.com/";
  static final String _RM_API_HOST2 = "https://api2-cn.ronghub.com/";
  static final String APP_KEY = "lmxuhwagl6itd";
  static final String APP_SECRET = "rxW11Z7LrE6qLl";

  factory RCIM() => _getInstance();

  static RCIM get instance => _getInstance();
  static RCIM _instance;

  RCIM._internal() {
    // 初始化
  }

  static RCIM _getInstance() {
    if (_instance == null) {
      _instance = new RCIM._internal();
    }
    return _instance;
  }

  ///融云server api header
  Map<String, String> _apiRequestHeader() {
    Map<String, String> header = {};

    String nonce = Random().nextInt(10000).toString();

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    String signature =
        sha1.convert(utf8.encode(APP_SECRET + nonce + timestamp)).toString();
    header["App-Key"] = APP_KEY;
    header["Nonce"] = nonce;
    header["Timestamp"] = timestamp;
    header["Signature"] = signature;

    return header;
  }

  ///设置用户信息
  Future<bool> setUserInfo(UserInfo userInfo) {}

  Future<http.Response> _request(String api, {Map data}) async {
    String url = _RM_API_HOST2 + api;
    var response =
        await http.post(url, headers: _apiRequestHeader(), body: data);
    return response;
  }

  ///获取token
  Future<String> getToken(UserInfo userInfo) async {
    String api = "user/getToken.json";
    dynamic data = {
      "userId": userInfo.userId,
      "name": userInfo.name,
      "portraitUri": userInfo.portraitUri,
    };
    http.Response response = await _request(api, data: data);
    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);
        print("获取RCIM-Token->" + response.body);
        if (body["code"] == 200) {
          return body["token"];
        }
      }
    } catch (e) {}
    print("获取RCIM-Token失败->" + response.body);

    return null;
  }
}
