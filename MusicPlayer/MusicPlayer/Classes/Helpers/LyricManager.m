//
//  LyricManager.m
//  MusicPlayer
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "LyricManager.h"
#import "LyricModel.h"


@interface LyricManager ()
//用来存放歌词
@property (nonatomic, strong) NSMutableArray *lyrics;

@end

@implementation LyricManager

static LyricManager *lyricManager = nil;
+(instancetype)sharedLyricManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lyricManager = [LyricManager new];
    });
    return lyricManager;
}

-(void)loadLyricWith:(NSString *)lyricStr{
    // 1.分行
    NSMutableArray *lyricStrArray = [[lyricStr componentsSeparatedByString:@"\n"]mutableCopy];
    // 解决方案一：
    // 移除最后一个元素（他是空的）
    [lyricStrArray removeLastObject];
    // 要先移除之前歌曲的歌词
    [self.lyrics removeAllObjects];
    
    if (lyricStrArray.count == 0) {
        LyricModel *lyric = [[LyricModel alloc]initWithTime:1 lyric:@"暂无歌词"];
        [self.lyrics addObject:lyric];
    }else{
        for (NSString *str in lyricStrArray) {
            // 解决方案二：
            //        // 判断是不是空的
            //        if ([str isEqualToString:@""]) {
            //            continue;
            //        }
            
            // 2.分开时间和歌词
            NSArray *timeAndLyric = [str componentsSeparatedByString:@"]"];
            if (timeAndLyric.count != 2) {
                continue;
            }
            // 3.去掉时间左边的“[”
            NSString *time = [timeAndLyric[0] substringFromIndex:1];
            // 格式：time = 02:02.080
            // 4.截取时间获取分和秒
            NSArray *minuteAndSecond = [time componentsSeparatedByString:@":"];
            // 分
            NSInteger minute = [minuteAndSecond[0] integerValue];
            // 秒
            double second = [minuteAndSecond[1] doubleValue];
            // 5.创建一个lyricModel
            LyricModel *lyric = [[LyricModel alloc]initWithTime:(minute * 60 + second) lyric:timeAndLyric[1]];
            // 6.添加到数组中
            [self.lyrics addObject:lyric];
        }
    }
}

-(NSInteger)indexWith:(NSTimeInterval)time{
    NSInteger index = 0;
    // 遍历数组，找到还没有播放的那一句歌词
    for (int i = 0; i < self.lyrics.count; i ++) {
        LyricModel *model = self.lyrics[i];
        if (model.time > time) {
            // 如果是第0个元素，而且元素时间比要播放的时间大，i- 1就会比0小，这样tableView就会crash
            index = (i - 1 > 0) ? i - 1 : 0;
            // 找到立即返回
            break;
        }
    }
    // 如果时间大于最后的歌词时间，则让他一直保持在最后一句
    if (time > [[self.lyrics lastObject] time]) {
        index = self.lyrics.count - 1;
    }
    return index;
}

-(NSMutableArray *)lyrics{
    if (!_lyrics) {
        _lyrics = [NSMutableArray new];
    }
    return _lyrics;
}

-(NSArray *)allLyric{
    return self.lyrics;
}

@end
