//
//  NetworkTool.m
//  VideoPlayer
//
//  Created by chentao on 2017/12/22.
//  Copyright © 2017年 chentao. All rights reserved.
//

#import "NetworkTool.h"
#import "QQFDeviceHandler.h"
#define VIDEO_LIST_URL   @"https://www.homelybeauty.com/loreal_api/videos/"
#define CONFIRM_URL @"http://www.baidu.com/login"

@implementation NetworkTool
+ (void)postForLastestVideoURLPathWithSuccessHanlder:(SuccessCompletionBlock) successHanlder
                                       failedHanlder:(FailureCompletionBlock) failedHanlder{
    // 获得NSURLSession对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 创建请求
    
    NSString *deviceID = [QQFDeviceHandler deviceID];
    if (deviceID == nil) {
        [QQFDeviceHandler setupDeviceID];
        deviceID = [QQFDeviceHandler deviceID];
    }
    
    NSString *requestURL = [NSString stringWithFormat:@"%@%@",VIDEO_LIST_URL,@"aaa"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    request.HTTPMethod = @"get"; //请求方
    
    // 创建任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
        if (!error) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if ([resultDict objectForKey:@"resCode"] != nil &&
                [[resultDict objectForKey:@"resCode"] integerValue] == 0) {
               successHanlder([resultDict objectForKey:@"data"]);
            }
        }else{
            failedHanlder([error description]);
        }
    }];
    // 启动任务
    [task resume];
}



+ (void)postForConfrimWorking {
    
    NSString *deviceID = [QQFDeviceHandler deviceID];
    NSString *param = [NSString stringWithFormat:@"deviceID=%@",deviceID];
    // 获得NSURLSession对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:CONFIRM_URL]];
    request.HTTPMethod = @"POST"; // 请求方法
    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding]; // 请求体
    
    // 创建任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
        
        
    }];
    // 启动任务
    [task resume];
}
@end
