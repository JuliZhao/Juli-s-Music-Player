//
//  PlayerManager.m
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "PlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayingViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PlayerManager ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation PlayerManager

static PlayerManager *playerManager = nil;

//+ (void)initialize{
//    // 设置后台播放
//    [self sutupForBackgroundPlay];
//}

// 设置后台播放
+ (void)sutupForBackgroundPlay{
    // 后台播放三步曲之第三步，设置 音频会话类型
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // 类型是:播放和录音
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    // 而且要激活 音频会话
    [session setActive:YES error:nil];
}

+(PlayerManager *)sharedPlayerManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerManager = [PlayerManager new];
    });
    return playerManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        // 添加通知中心，当self发出AVPlayerItemDidPlayToEndTimeNotification时触发playerDidPlayEnd:事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}
#pragma mark --- PlayerManagerDelegate
-(void)playerDidPlayEnd:(NSNotification *)note{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayEnd)]) {
        // 接收到item播放结束后，让代理去干一些事情，代理会怎么干，播放器不需要知道
        [self.delegate playerDidPlayEnd];
    }
}

-(void)playWithUrlString:(NSString *)urlStr{
    // 如果是切换歌曲，要先吧正在播放的观察者移除掉
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    // 创建一个item
    NSURL *url = [NSURL URLWithString:urlStr];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    // 对 item 添加观察者
    // 观察 item 的状态
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 替换当前正在播放的歌曲
    [self.player replaceCurrentItemWithPlayerItem:item];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}
-(void)play{
    // 如果正在播放的话，就播放了，直接返回就行了
//    if (_isPlaying) {
//        return;
//    }
    
    [self.player play];
    // 开始播放后标记一下
    _isPlaying = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playWithSeonds) userInfo:nil repeats:YES];
    [PlayingViewController sharedPlayingVC].block = ^(CGFloat value){
        self.player.volume = value;
    };
}
-(void)playWithSeonds{
//    NSLog(@"%lld", self.player.currentTime.value / self.player.currentTime.timescale);
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerPlayingWithTime:)]) {
        NSTimeInterval time = self.player.currentTime.value / self.player.currentTime.timescale;
        [self.delegate playerPlayingWithTime:time];
    }
}
-(void)pause{
    [self.player pause];
    [self.timer invalidate];
    self.timer = nil;
    _isPlaying = NO;
}
// time：50秒
-(void)seekToTime:(NSTimeInterval)time{
    // 先暂停
    [self pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
        if (finished) {
            // 托拽成功后在播放
            [self play];
        }
    }];
}

-(CGFloat)volume{
    return self.player.volume;
}

#pragma mark --- lazy load
-(AVPlayer *)player{
    if (!_player) {
        _player = [AVPlayer new];
    }
    return _player;
}
#pragma mark --- 观察响应
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
//    NSLog(@"%@", keyPath);
//    NSLog(@"%@", change);
    AVPlayerItemStatus status = [change[@"new"]integerValue];
    switch (status) {
        case AVPlayerItemStatusFailed:
            NSLog(@"加载失败");
            break;
        case AVPlayerItemStatusUnknown:
            NSLog(@"资源不对");
            break;
        case AVPlayerItemStatusReadyToPlay:
//            NSLog(@"可以播放了");
            // 先暂停，将NSTimer销毁，然后再播放，创建NSTimer
            [self pause];
            // 播放
            [self play];
            break;
        default:
            break;
    }
}


@end
