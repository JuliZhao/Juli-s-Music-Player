//
//  LyricModel.h
//  MusicPlayer
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyricModel : NSObject

// 播放时间
@property (nonatomic, assign) NSTimeInterval time;
// 歌词内容
@property (nonatomic, strong) NSString *lyricContent;

-(instancetype)initWithTime:(NSTimeInterval)time
                      lyric:(NSString *)lyricContent;

@end
