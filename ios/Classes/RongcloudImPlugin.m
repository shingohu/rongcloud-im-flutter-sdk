#import "RongcloudImPlugin.h"
#import "RCIMFlutterWrapper.h"
#import <RongIMLib/RongIMLib.h>

@implementation RongcloudImPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"rongcloud_im_plugin"
            binaryMessenger:[registrar messenger]];
  RongcloudImPlugin* instance = [[RongcloudImPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar addApplicationDelegate:instance];
  [[RCIMFlutterWrapper sharedWrapper] addFlutterChannel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[RCIMFlutterWrapper sharedWrapper] handleMethodCall:call result:result];
}




///app 启动
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    

   ///监听登陆状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onIMLoginSuccess:) name:@"IMLoginSuccessNotification" object:nil];
   
    
    return TRUE;
}


- (void)onIMLoginSuccess:(NSNotification *)notification {
    
    ///注册通知
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center =  [UNUserNotificationCenter currentNotificationCenter];
        
        ///请求权限
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if(granted){
                printf("允许通知");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    ///不放到这会报错
                    [[UIApplication sharedApplication] registerForRemoteNotifications];

                });
                //有权限 请求远程通知
               
                
            }else{
                printf("不允许通知");
            }
        }];
        
    } else {
        // Fallback on earlier versions
    }
    
    
    

   
}



//进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application{
    
}


//进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application{
    
    application.applicationIconBadgeNumber = 1;
    [application cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 0;
}



/**
    *  App处于前台时收到通知(iOS 10+)
    */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    printf("1收到通知1");
}

/**
     *  触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
     */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    printf("点击打开了通知");
    
    completionHandler();
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    printf("获取到远程推送token");
    [[RCIMClient sharedRCIMClient] setDeviceTokenData:deviceToken];
}

///活跃
- (void)applicationDidBecomeActive:(UIApplication *)application{
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}




@end
