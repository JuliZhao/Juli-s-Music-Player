//
//  PlayingViewController.m
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "PlayingViewController.h"
#import "PlayerManager.h"
#import "DataManager.h"
#import "Music.h"
#import "LyricManager.h"
#import "LyricModel.h"

@interface PlayingViewController ()<PlayerManagerDelegate, UITableViewDelegate, UITableViewDataSource>
// 记录一下当前播放的音乐的索引
@property (nonatomic, assign) NSInteger currentIndex;
// 记录当前正在播放的音乐
@property (nonatomic, strong) Music *currentMusic;
// 属性cell
@property (nonatomic, strong) UITableViewCell *myCell;
// 颜色数组
@property (nonatomic, strong) NSArray *colorArray;
#pragma mark --- 控件
@property (strong, nonatomic) IBOutlet UILabel *songName;
@property (strong, nonatomic) IBOutlet UILabel *singerName;
@property (strong, nonatomic) IBOutlet UIImageView *img4Pic;
@property (strong, nonatomic) IBOutlet UILabel *label4PlayedTime;
@property (strong, nonatomic) IBOutlet UILabel *label4LastTime;
@property (strong, nonatomic) IBOutlet UISlider *slider4Time;
@property (strong, nonatomic) IBOutlet UISlider *slider4Volume;
@property (strong, nonatomic) IBOutlet UIButton *playOrPause;
@property (strong, nonatomic) IBOutlet UIButton *playStyle;
@property (strong, nonatomic) IBOutlet UITableView *tableView4Lyric;
@property (strong, nonatomic) IBOutlet UIImageView *img4PicBackground;
@property (strong, nonatomic) IBOutlet UIButton *cellTextColor;
@property (strong, nonatomic) IBOutlet UIButton *cellSelectColor;
@property (strong, nonatomic) IBOutlet UIButton *prevButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
#pragma mark --- 控制事件
- (IBAction)action4Prev:(UIButton *)sender;
- (IBAction)action4PlayOrPause:(UIButton *)sender;
- (IBAction)action4Next:(UIButton *)sender;
- (IBAction)action4ChangeTime:(UISlider *)sender;
- (IBAction)action4ChangeVolume:(UISlider *)sender;
- (IBAction)changeCellTextColor:(UIButton *)sender;
- (IBAction)changeSelectedCell:(UIButton *)sender;


@end

@implementation PlayingViewController

static PlayingViewController *playingVC = nil;
+(instancetype)sharedPlayingVC{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        playingVC = [sb instantiateViewControllerWithIdentifier:@"playingVC"];
    });
    return playingVC;
}

- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (_index == _currentIndex) {
        return;
    }
    _currentIndex = _index;
    [self startPlay];
    // 后台
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

-(void)startPlay{
    [[PlayerManager sharedPlayerManager] playWithUrlString:self.currentMusic.mp3Url];
    [self buildUI];
}
#pragma mark --- getter
-(Music *)currentMusic{
    Music *music = [DataManager sharedManager].musicArray[_currentIndex];
    return music;
}

-(void)buildUI{
    _songName.text = self.currentMusic.name;
    _singerName.text = self.currentMusic.singer;
    // 更改button
    [_playOrPause setImage:[UIImage imageNamed:@"暂停"] forState:(UIControlStateNormal)];
    // 改变进度条的最大值
    self.slider4Time.maximumValue = [self.currentMusic.duration integerValue]/1000;
    // 把进度条初值设为0
    self.slider4Time.value = 0;
    // 添加照片
    [self.img4Pic sd_setImageWithURL:[NSURL URLWithString:self.currentMusic.picUrl]];
    // 添加毛玻璃图片
    [self.img4PicBackground sd_setImageWithURL:[NSURL URLWithString:self.currentMusic.blurPicUrl ]];
    // 更改旋转的角度,归位
    self.img4Pic.transform = CGAffineTransformMakeRotation(0);
    // 解析歌词
    [[LyricManager sharedLyricManager] loadLyricWith:self.currentMusic.lyric];
    [self.tableView4Lyric reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentIndex = -1;
    // 设置自己作为播放器的代理，帮播放器做一些事情
    [PlayerManager sharedPlayerManager].delegate = self;
    // 切圆角
    _img4Pic.layer.masksToBounds = YES;
    
    _img4Pic.layer.cornerRadius =self.view.frame.size.width * 0.7 / 2.0;
    // 注册cell
    [self.tableView4Lyric registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    // 改变音量最大值
    self.slider4Volume.maximumValue = 10.0f;
    // 给slider4Vloume初值
    self.slider4Volume.value = [[PlayerManager sharedPlayerManager] volume];
    [self.playStyle setImage:[UIImage imageNamed:@"循环播放"] forState:(UIControlStateNormal)];
}
static int i = 0;
- (IBAction)playStyleAction:(UIButton *)sender {
    i ++;
    NSArray *array = @[@"循环播放",@"单曲循环",@"随机播放"];
    int j = i % 3;
//    [_playStyle setTitle:array[j] forState:(UIControlStateNormal)];
    [self.playStyle setImage:[UIImage imageNamed:array[j]] forState:(UIControlStateNormal)];
}

#pragma mark --- PlayerManagerDelegate
// 播放器播放结束，播放下一首
-(void)playerDidPlayEnd{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    if ([self.playStyle.imageView.image isEqual:[UIImage imageNamed:@"循环播放"]]) {
        [self action4Next:nil];
    }if([self.playStyle.imageView.image isEqual:[UIImage imageNamed:@"单曲循环"]]){
        [self startPlay];
    }else if ([self.playStyle.imageView.image isEqual:[UIImage imageNamed:@"随机播放"]]){
        _currentIndex = [self arc4random];
        _index = _currentIndex;
        [self startPlay];
    }
}

-(int)arc4random{
    int a = arc4random_uniform((int)[DataManager sharedManager].musicArray.count);
    if (a == 1) {
       a = [self arc4random];
    }
    return a;
}

// 播放器每0.1秒会让代理（也就是这个页面）执行以下这个事件
-(void)playerPlayingWithTime:(NSTimeInterval)time{
    self.slider4Time.value = time;
    // 播放时间
    self.label4PlayedTime.text = [self stringWithTime:time];
    // 剩余时间
    NSTimeInterval time2 = [self.currentMusic.duration integerValue]/1000 - time;
    self.label4LastTime.text = [self stringWithTime:time2];
    // 每0.1秒旋转1度
    self.img4Pic.transform = CGAffineTransformRotate(self.img4Pic.transform, M_PI/180);
    // 根据 当前播放时间获取到应该播放到哪句歌词
    NSInteger index = [[LyricManager sharedLyricManager]indexWith:time];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    // 让tableView选中我们找到的歌词
    [self.tableView4Lyric selectRowAtIndexPath:path animated:YES scrollPosition:(UITableViewScrollPositionMiddle)];
}

// 根据时间获取到字符串
-(NSString *)stringWithTime:(NSTimeInterval)time{
    NSInteger minutes = time/60;
    NSInteger seconds = (int)time%60;
    return [NSString stringWithFormat:@"%ld:%ld", (long)minutes, (long)seconds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)action4Prev:(UIButton *)sender {
    if ([_playStyle.imageView.image isEqual:[UIImage imageNamed:@"循环播放"]] || [_playStyle.imageView.image isEqual:[UIImage imageNamed:@"单曲循环"]]) {
        _currentIndex --;
        // 判断是不是第一首
        if (_currentIndex == -1) {
            _currentIndex = [DataManager sharedManager].musicArray.count - 1;
        }
        [self startPlay];
    }else if([_playStyle.imageView.image isEqual:[UIImage imageNamed:@"随机播放"]]){
        _currentIndex = [self arc4random];
        [self startPlay];
    }
    _index = _currentIndex;
}

- (IBAction)action4PlayOrPause:(UIButton *)sender {
    // 判断是否在播放
    if ([PlayerManager sharedPlayerManager].isPlaying) {
        // 如果正在播放，就让播放器暂停，同时改变button的title
        [[PlayerManager sharedPlayerManager] pause];
        [_playOrPause setImage:[UIImage imageNamed:@"播放"] forState:(UIControlStateNormal)];
    }else{
        [[PlayerManager sharedPlayerManager] play];
        [_playOrPause setImage:[UIImage imageNamed:@"暂停"] forState:(UIControlStateNormal)];
    }
}

- (IBAction)action4Next:(UIButton *)sender {
    if ([_playStyle.imageView.image isEqual:[UIImage imageNamed:@"循环播放"]] || [_playStyle.imageView.image isEqual:[UIImage imageNamed:@"单曲循环"]]) {
        _currentIndex ++;
        // 判断是不是最后一首
        if (_currentIndex == [DataManager sharedManager].musicArray.count) {
            _currentIndex = 0;
        }
        [self startPlay];
    }else if([_playStyle.imageView.image isEqual:[UIImage imageNamed:@"随机播放"]]){
        _currentIndex = [self arc4random];
        [self startPlay];
    }
    _index = _currentIndex;
}

- (IBAction)action4ChangeTime:(UISlider *)sender {
    // 调用接口
    [[PlayerManager sharedPlayerManager] seekToTime:sender.value];
}

- (IBAction)action4ChangeVolume:(UISlider *)sender {
    self.block(sender.value);
}
-(NSArray *)colorArray{
    UIColor *color1 = [UIColor blackColor];
    UIColor *color2 = [UIColor whiteColor];
    UIColor *color3 = [UIColor redColor];
    UIColor *color4 = [UIColor yellowColor];
    UIColor *color5 = [UIColor cyanColor];
    self.colorArray = @[color1, color2, color3, color4, color5];
    return _colorArray;
}
static NSInteger click1 = 0;
- (IBAction)changeCellTextColor:(UIButton *)sender {
    click1 ++;
    int j = click1 % 5;
    _cellTextColor.backgroundColor = self.colorArray[j];
    [self.tableView4Lyric reloadData];
}
static NSInteger click2 = 1;
- (IBAction)changeSelectedCell:(UIButton *)sender {
    click2 ++;
    int j = click2 % 5;
    _cellSelectColor.backgroundColor = self.colorArray[j];
    [self.tableView4Lyric reloadData];
}
#pragma mark --- 自适应高度
// 计算字符串大小的frame，需传入字符串 和 字体大小
-(CGFloat)textHeight:(NSString *)string font:(CGFloat)font{
    CGRect rect = [string boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, 10000) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    // 返回计算好的高度
    return rect.size.height;
}
#pragma mark --- UITableViewDataSource
// 设置cell的个数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [LyricManager sharedLyricManager].allLyric.count;
}
// 设置cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    LyricModel *lyric = [LyricManager sharedLyricManager].allLyric[indexPath.row];
    UIView *aView = [[UIView alloc]init];
    aView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = aView;
    // 显示歌词
    cell.textLabel.text = lyric.lyricContent;
    // 多行
    cell.textLabel.numberOfLines = 0;
    // 设置透明，显示出背景的图片
    cell.backgroundColor = [UIColor clearColor];
    // 设置居中
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    // 设置歌词颜色
    cell.textLabel.textColor = self.cellTextColor.backgroundColor;
    // 设置选中的歌词的颜色
    cell.selectedTextColor = self.cellSelectColor.backgroundColor;
    self.myCell = cell;
    return _myCell;
}

// cell自适应高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self textHeight:[[LyricManager sharedLyricManager].allLyric[indexPath.row] lyricContent] font:17] + 20;
}
// 点击歌词，播放到当前点击的歌词部分
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSTimeInterval time = [[LyricManager sharedLyricManager].allLyric[indexPath.row] time];
    [[PlayerManager sharedPlayerManager] seekToTime:time];
    self.slider4Time.value = time;
}

#pragma mark --- playBackground

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
//重写父类方法，接受外部事件的处理
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self action4PlayOrPause:self.playOrPause];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self action4Prev:self.prevButton];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self action4Next:self.nextButton];
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [self action4PlayOrPause:self.playOrPause];
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [self action4PlayOrPause:self.playOrPause];
                break;
                
            default:
                break;
        }
    }
}


/*
 
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
