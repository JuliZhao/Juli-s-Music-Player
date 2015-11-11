//
//  LyricModel.m
//  MusicPlayer
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "LyricModel.h"

@implementation LyricModel

-(instancetype)initWithTime:(NSTimeInterval)time lyric:(NSString *)lyricContent{
    if (self = [super init]) {
        _time = time;
        _lyricContent = lyricContent;
    }
    return self;
}

@end
