//
//  RCCustomMessage.m
//  rongcloud_im_plugin
//
//  Created by huatu on 2021/1/26.
//

#import "RCCustomMessage.h"

@implementation RCCustomMessage






+ (RCMessagePersistent)persistentFlag{
    return MessagePersistent_ISCOUNTED | MessagePersistent_ISPERSISTED;
}


/// NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.data = [aDecoder decodeObjectForKey:@"data"];
    }
    return self;
}


/// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.data forKey:@"data"];
}


///将消息内容编码成json
- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if(self.type){
        [dataDict setObject:self.type forKey:@"type"];
    }

    if(self.data){
        [dataDict setObject:self.data forKey:@"data"];
    }


    if (self.senderUserInfo) {
        [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
    }

    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

///将json解码生成消息内容
- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;

        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        if (dictionary) {
            self.type = dictionary[@"type"];
            self.data = dictionary[@"data"];
            NSDictionary *userinfoDic = dictionary[@"user"];
            if(userinfoDic != nil){
                [self decodeUserInfo:userinfoDic];
            }
        }
    }
}

/// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    if(self.data){
        return self.data[@"content"];
    }
    return @"自定义消息";
}

///消息的类型名
+ (NSString *)getObjectName {
    return @"custom";
}

@end
