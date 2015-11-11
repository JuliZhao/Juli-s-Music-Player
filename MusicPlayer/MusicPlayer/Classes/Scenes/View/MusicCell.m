//
//  MusicCell.m
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "MusicCell.h"
#import "Music.h"

@implementation MusicCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMusic:(Music *)music{
    _music = music;
    _songName.text = music.name;
    _singerName.text = music.singer;
    [_img sd_setImageWithURL:[NSURL URLWithString:music.picUrl]];
}

@end
