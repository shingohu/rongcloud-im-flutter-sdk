import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:rongcloud_im_plugin/src/util/message_factory.dart';

export 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class IMListener {
  onUnreadCountChange(int count) {}

  onConnectionStatusChange(int connectionStatus) {}

  onConversationRefresh(List<Conversation> conversations) {}

  ///点击通知消息
  onNotificationClick(Conversation conversation) {}

  ///接收到消息
  onMessageReceived(Message message) {}
}

class RCIM {
  static final String _RM_API_HOST1 = "https://api-cn.ronghub.com/";
  static final String _RM_API_HOST2 = "https://api2-cn.ronghub.com/";
  static final String APP_KEY = "lmxuhwagl6itd";
  static final String APP_SECRET = "rxW11Z7LrE6qLl";

  List<IMListener> _imListener = [];

  void addIMListener(IMListener listener) {
    if (!_imListener.contains(listener)) {
      _imListener.add(listener);
    }
  }

  void removeIMListener(IMListener listener) {
    if (_imListener.contains(listener)) {
      _imListener.remove(listener);
    }
  }

  factory RCIM() => _getInstance();

  static RCIM get instance => _getInstance();
  static RCIM _instance;

  RCIM._internal() {
    // 初始化
  }

  static RCIM _getInstance() {
    if (_instance == null) {
      _instance = new RCIM._internal();
      _instance.initIM();
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

  Future<http.Response> _request(String api, {Map data}) async {
    String url = _RM_API_HOST2 + api;
    var response =
        await http.post(url, headers: _apiRequestHeader(), body: data);
    return response;
  }

  ///获取token
  ///only for test
  Future<String> getToken(
      {String userId, String userName, String avatar}) async {
    String api = "user/getToken.json";
    dynamic data = {
      "userId": userId,
      "name": userName,
      "portraitUri": avatar,
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

  ///初始化
  void initIM() {
    RongIMClient.init(APP_KEY);
    RongIMClient.setReconnectKickEnable(true);
    _initIMListener();
  }

  ///监听
  void _initIMListener() {
    ///连接状态变化
    RongIMClient.onConnectionStatusChange = (status) {
      _imListener.forEach((element) {
        element.onConnectionStatusChange(status);
      });
    };

    ///新消息
    RongIMClient.onMessageReceivedWrapper =
        (Message msg, int left, bool hasPackage, bool offline) {
      if (left == 0 && !hasPackage) {
        _refreshConversations();
      }
      _imListener.forEach((element) {
        element.onMessageReceived(msg);
      });
    };
  }

  ///更新当前用户信息
  ///only for ios
  void updateCurrentUserInfo(String userId, String name, String portraitUrl) {
    RongIMClient.updateCurrentUserInfo(userId, name, portraitUrl);
  }

  ///登陆
  void login(String token) {
    RongIMClient.connect(token, (code, userId) {
      ///https://docs.rongcloud.cn/v3/views/im/ui/code/ios.html
      if (code == 0 || code == 34001) {
        _refreshConversations();
        print("RCIM 登陆成功");
      } else {
        print("RCIM connect fail->$code");
      }
    });
  }

  ///退出登录
  void logout() {
    RongIMClient.disconnect(false);
  }

  ///点击通知
  void onNotificationClick(String payload) {
    if(jsonDecode(payload)!=null) {
      Conversation conversation = MessageFactory.instance.string2Conversation(
          payload);
      _imListener.forEach((element) {
        element.onNotificationClick(conversation);
      });
    }
  }

  Conversation message2Conversation(Message message) {
    Conversation conversation = Conversation();
    conversation.objectName = message.objectName;
    conversation.targetId = message.targetId;
    conversation.conversationType = message.conversationType;
    conversation.originContentMap = message.originContentMap;
    conversation.latestMessageContent = message.content;
    return conversation;
  }

  String conversation2String(Conversation conversation) {
    Map map = {};

    map["objectName"] = conversation.objectName;
    map["targetId"] = conversation.targetId;
    map["conversationType"] = conversation.conversationType;
    if (conversation.latestMessageContent != null) {
      map["content"] = conversation.latestMessageContent.encode();
    } else if (conversation.originContentMap != null) {
      map["content"] = conversation.originContentMap;
    }
    return jsonEncode(map);
  }

  ///获取回话列表
  Future<List<Conversation>> getConversationList() async {
    List<int> displayConversationType = [
      RCConversationType.Private,
      RCConversationType.Group
    ];
    return (await RongIMClient.getConversationList(displayConversationType))
        .map((e) {
      return e as Conversation;
    }).toList();
  }

  void removeConversation(int conversationType, String targetId) {
    RongIMClient.removeConversation(conversationType, targetId, (success) {
      _refreshConversations();
    });
  }

  void _refreshConversations() {
    getConversationList().then((value) {
      _getTotalUnreadCount();
      _imListener.forEach((element) {
        element.onConversationRefresh(value);
      });
    });
  }

  ///未读消息数量
  void _getTotalUnreadCount() {
    RongIMClient.getTotalUnreadCount((count, code) {
      if (code == 0) {
        _imListener.forEach((element) {
          element.onUnreadCountChange(count);
        });
      }
      return 0;
    });
  }

  ///设置是否接受消息
  void setNotificationQuiet(bool isNewMessage) {
    if (!isNewMessage) {
      RongIMClient.setNotificationQuietHours("00:00:00", 1339, (code) {});
    } else {
      RongIMClient.removeNotificationQuietHours((code) {});
    }
  }

  ///消息标记已读
  void makeMessagesAsRead(int conversationType, String targetId) async {
    bool success = await RongIMClient.clearMessagesUnreadStatus(
        conversationType, targetId);
    print("RCIM 消息标记已读->$success");
    _refreshConversations();
  }

  ///获取是否接收通知状态
  void getNotificationQuiet(Function(bool) quietCallback) {
    RongIMClient.getNotificationQuietHours((code, startTime, spansMin) {
      if (code == 0) {
        print("RCIM 接收消息?${startTime != null}");
        quietCallback.call(startTime != null || spansMin == 0);
      }
    });
  }

  ///获取历史消息
  Future<List<Message>> getHistoryMessage(int conversationType, String targetId,
      {int messageId = -1, int count = 20}) async {
    return (await RongIMClient.getHistoryMessage(
            conversationType, targetId, messageId, count))
        .map((e) {
      return e as Message;
    }).toList();
  }
}
