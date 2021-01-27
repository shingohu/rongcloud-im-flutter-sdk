//
//  RCCustomMessage.h
//  rongcloud_im_plugin
//
//  Created by huatu on 2021/1/26.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCustomMessage : RCMessageContent <NSCoding>

@property(nonatomic, strong) NSString *type;

/*!
 测试消息的附加信息
 */
@property(nonatomic, strong) NSMutableDictionary *data;


@end

NS_ASSUME_NONNULL_END
