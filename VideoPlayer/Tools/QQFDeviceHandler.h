//
//  QQFDeviceHandler.h
//  chentao
//
//  Created by chentao on 2017/4/24.
//  Copyright © 2017年 chentao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QQFDeviceHandler : NSObject


/**
 设备ID初始化， 如果不存在设备ID，则生成32位UUID并保存到KeyChain中，如果存在，则不操作
 */
+ (void)setupDeviceID;

/**
 获取设备ID

 @return 设备ID
 */
+ (NSString *)deviceID;

/**
 获取设备类型

 @return 设备类型
 */
+ (NSString *)deviceType;

@end
