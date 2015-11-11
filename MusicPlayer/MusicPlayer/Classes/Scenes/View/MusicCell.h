//
//  MusicCell.h
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Music;

@interface MusicCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *img;

@property (strong, nonatomic) IBOutlet UILabel *songName;

@property (strong, nonatomic) IBOutlet UILabel *singerName;

@property (nonatomic, strong) Music *music;


@end
