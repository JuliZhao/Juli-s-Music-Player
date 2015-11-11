//
//  Music.h
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Music : NSObject

@property (nonatomic, strong) NSString *mp3Url;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *picUrl;
@property (nonatomic, strong) NSString *blurPicUrl;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSString *singer;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *artists_name;
@property (nonatomic, strong) NSString *lyric;

@end
