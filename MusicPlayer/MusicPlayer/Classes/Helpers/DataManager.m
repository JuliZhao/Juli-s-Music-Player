//
//  DataManager.m
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "DataManager.h"
#import "Music.h"

@implementation DataManager

static DataManager *dataManager = nil;
+(DataManager *)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [DataManager new];
        [dataManager requestData];
    });
    return dataManager;
}

-(void)requestData{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [NSURL URLWithString:kURL];
        NSArray *array = [NSArray arrayWithContentsOfURL:url];
        for (NSDictionary *dic in array) {
            Music *music = [Music new];
            [music setValuesForKeysWithDictionary:dic];
            [_musicArray addObject:music];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!_myUpdate) {
                NSLog(@"error:没有block");
            }else{
                _myUpdate();
            }
        });
    });
}

-(Music *)selectMusicWithIndex:(NSUInteger)index{
    return _musicArray[index];
}

-(NSMutableArray *)musicArray{
    if (!_musicArray) {
        _musicArray = [NSMutableArray array];
    }
    return _musicArray;
}
-(Music *)selectMusicWithName:(NSString *)name{
    for (Music *music in self.musicArray) {
        if ([music.name isEqualToString:name]) {
            return music;
        }
    }
    return nil;
}

-(NSInteger)returnIndexWithMusicName:(NSString *)name{
    NSInteger i = -1;
    for (Music *music in self.musicArray) {
        i ++;
        if ([music.name isEqualToString:name]) {
            return i;
        }
    }
    return i;
}

@end
