//
//  NetworkTool.h
//  VideoPlayer
//
//  Created by chentao on 2017/12/22.
//  Copyright © 2017年 chentao. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^SuccessCompletionBlock)(NSDictionary *result);
typedef void(^FailureCompletionBlock)(NSString *error);
@interface NetworkTool : NSObject
/**
 请求最新的视频地址
 */
+ (void)postForLastestVideoURLPathWithSuccessHanlder:(SuccessCompletionBlock) successHanlder
                                       failedHanlder:(FailureCompletionBlock) failedHanlder;
/**
 发送请求，视频正在播放
 */
+ (void)postForConfrimWorking;
@end
