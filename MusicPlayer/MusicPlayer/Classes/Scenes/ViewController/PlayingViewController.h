//
//  PlayingViewController.h
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Slider4Vloum) (CGFloat);

@interface PlayingViewController : UIViewController

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) Slider4Vloum block;


+(instancetype)sharedPlayingVC;

@end
