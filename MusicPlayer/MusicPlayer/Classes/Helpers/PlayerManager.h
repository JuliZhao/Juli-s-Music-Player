//
//  PlayerManager.h
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerManagerDelegate <NSObject>

// 当播放一首歌结束后，让代理去做的事件
-(void)playerDidPlayEnd;
// 播放中一直在重复执行的一个方法
-(void)playerPlayingWithTime:(NSTimeInterval)time;

@end

@interface PlayerManager : NSObject
// 是否正在播放
@property (nonatomic, assign) BOOL isPlaying;
// 设置代理
@property (nonatomic, assign) id<PlayerManagerDelegate> delegate;


+(PlayerManager *)sharedPlayerManager;

-(void)playWithUrlString:(NSString *)urlStr;
// 播放
-(void)play;
// 暂停
-(void)pause;
// 改变进度 // 根据歌词改变歌曲进度
-(void)seekToTime:(NSTimeInterval)time;
// 访问AVPlayer的音量
-(CGFloat)volume;

@end
