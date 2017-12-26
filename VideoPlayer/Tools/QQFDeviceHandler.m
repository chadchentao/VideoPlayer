//
//  DeviceHandler.m
//  chentao
//
//  Created by chentao on 2017/4/24.
//  Copyright © 2017年 chentao. All rights reserved.
//

#import "QQFDeviceHandler.h"
#import "SAMKeychain.h"
#import "UIDevice+FEPlatForm.h"

NSString *const kSAMKeychainServiceName = @"VideoPlayerChain";
NSString *const kSAMKeychainAccount = @"com.chentao.videoplayer";

@implementation QQFDeviceHandler
+ (void)setupDeviceID {
    NSString *deviceID = [QQFDeviceHandler readUUIDFromKeyChain];
    if (!deviceID) {
        [QQFDeviceHandler saveUUIDToKeyChain];
    }
}

+ (NSString *)deviceID {
    return [QQFDeviceHandler readUUIDFromKeyChain];
}

#pragma mark - 保存和读取UUID
+(BOOL)saveUUIDToKeyChain{
    return [SAMKeychain setPassword:[self getUUIDString] forService:kSAMKeychainServiceName account:kSAMKeychainAccount];
}

+(NSString *)readUUIDFromKeyChain{
    NSString *UUID = [SAMKeychain passwordForService:kSAMKeychainServiceName account:kSAMKeychainAccount];
    return UUID;
}

+ (NSString *)getUUIDString
{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault , uuidRef);
    NSString *uuidString = [(__bridge NSString*)strRef stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(strRef);
    CFRelease(uuidRef);
    return uuidString;
}
+ (NSString *)deviceType {
    return [UIDevice devicePlatForm];
}
@end
