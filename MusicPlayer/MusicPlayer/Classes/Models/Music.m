//
//  Music.m
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "Music.h"

@implementation Music

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        _Id = value;
    }else{
        NSLog(@"error : key:%@---value:%@", key, value);
    }
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@%@", _name, _singer];
}

@end
