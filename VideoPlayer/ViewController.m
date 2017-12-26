//
//  ViewController.m
//  VideoPlayer
//
//  Created by chentao on 2017/12/22.
//  Copyright © 2017年 chentao. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h> // 基于AVFoundation,通过实例化的控制器来设置player属性
#import <AVKit/AVKit.h>   // 1. 导入头文件   iOS 9 新增
#import "NetworkTool.h"
#import "QQFDeviceHandler.h"

#define CURRENT_DOWNLOAD_URL        @"currentDownloadURL"

@interface ViewController ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign)BOOL isBeginPlay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isBeginPlay = YES;
    [self sendRequestVideo];
}

- (void)sendRequestVideo
{
    [NetworkTool postForLastestVideoURLPathWithSuccessHanlder:^(NSDictionary *result) {
        NSString *src = [result objectForKey:@"src"];
        if (src != nil && ![src isEqualToString:@""]) {
            NSString *currentURL = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DOWNLOAD_URL];
            if (currentURL == nil || (currentURL != nil && ![currentURL isEqualToString:src])) {
                [[NSUserDefaults standardUserDefaults] setObject:src forKey:CURRENT_DOWNLOAD_URL];
                [self playCurrentVideo:src];
            }else{
                if (self.isBeginPlay) {
                    self.isBeginPlay = NO;
                    [self playCurrentVideo:src];
                }
            }
        }
    } failedHanlder:^(NSString *error) {
        if (self.isBeginPlay) {
            self.isBeginPlay = NO;
            NSString *currentURL = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DOWNLOAD_URL];
            if (currentURL != nil) {
                 [self playCurrentVideo:currentURL];
            }
        }
    }];
}

- (void)playCurrentVideo:(NSString *)videoURL
{
    self.videoPath = videoURL;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer = playerLayer;
    playerLayer.frame = [[UIScreen mainScreen] bounds];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//视频填充模式
    [self.view.layer addSublayer:playerLayer];
    [self.player play];
    //添加视频播放完成后的通知事件
    [self addNotification];
    [self setupTimer];
}

- (void)setupTimer
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:15.0
                                             target:self
                                           selector:@selector(timerAction)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)timerAction
{
    self.isBeginPlay = NO;
    [self sendRequestVideo];
}

#pragma mark
#pragma mark - getter & setter
- (AVPlayer *)player {
    if (!_player) {
        NSString *filePath = self.videoPath;
        NSURL *saveUrl=[NSURL URLWithString:filePath];
        //通过文件 URL 来实例化 AVPlayerItem
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:saveUrl];
        self.playerItem = playerItem;
        [self addObserverToPlayerItem:playerItem];
        _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    }
    return _player;
}

#pragma mark
#pragma mark - KVO
/** * 给AVPlayerItem添加监控 *
 * @param playerItem AVPlayerItem对象 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

/** * 通过KVO监控播放器状态 *
 * @param keyPath 监控属性
 * @param object 监视器
 * @param change 状态改变
 * @param context 上下文 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }
    else if([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
    }
}
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    //屏幕旋转
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}
//屏幕旋转监听
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.playerLayer.frame = bounds;
    if (orientation == UIInterfaceOrientationLandscapeRight) // home键靠右
    {
        //
        NSLog(@"%@",NSStringFromCGRect(bounds));
    }
    if (
        orientation ==UIInterfaceOrientationLandscapeLeft) // home键靠左
    {
        //
        NSLog(@"%@",NSStringFromCGRect(bounds));
    }
    
    if (orientation == UIInterfaceOrientationPortrait)
    {
        //
        NSLog(@"%@",NSStringFromCGRect(bounds));
    }
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //
        NSLog(@"%@",NSStringFromCGRect(bounds));
    }
}

- (void)dealloc
{
    [self removeNotification];
    [self removeObserverFromPlayerItem:self.playerItem];
    [self.timer invalidate];
    self.timer = nil;
    
}
@end
