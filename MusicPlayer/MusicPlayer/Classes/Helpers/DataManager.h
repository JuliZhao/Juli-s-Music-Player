//
//  DataManager.h
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Music;

typedef void(^UpdateUI)();

@interface DataManager : NSObject

@property (nonatomic, copy) UpdateUI myUpdate;

@property (nonatomic, strong) NSMutableArray *musicArray;


+(DataManager *)sharedManager;

-(Music *)selectMusicWithIndex:(NSUInteger)index;

-(Music *)selectMusicWithName:(NSString *)name;

-(NSInteger)returnIndexWithMusicName:(NSString *)name;

@end
