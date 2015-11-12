//
//  MusicListController.m
//  MusicPlayer
//
//  Created by lanou3g on 15/11/7.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "MusicListController.h"
#import "DataManager.h"
#import "Music.h"
#import "MusicCell.h"
#import "PlayingViewController.h"

@interface MusicListController ()<MBProgressHUDDelegate, UISearchResultsUpdating,UISearchBarDelegate>
// 小菊花
@property (nonatomic, retain) MBProgressHUD *HUD;
// 存放所有歌名的数组
@property (nonatomic, retain) NSMutableArray *items;
// 存放搜索到歌的数组
@property (nonatomic, retain) NSMutableArray *searchResult;
// 搜索框
@property (nonatomic, retain) UISearchController *searchController;


@end

@implementation MusicListController

static NSString *identifier = @"cell";
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"MusicCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:identifier];
    [DataManager sharedManager].myUpdate = ^(){
        [self.tableView reloadData];
    };
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.backgroundColor = [UIColor redColor];
    _HUD.labelText = @"加载";
    _HUD.delegate = self;
    _HUD.detailsLabelText = @"努力加载中";
    _HUD.dimBackground = YES;
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    //        NSLog(@"%@", NSStringFromCGRect(self.searchController.searchBar.frame));
    // 设置搜索框搜索到内容的背景颜色
    _searchController.dimsBackgroundDuringPresentation = NO;
    // 搜索时候更新
    _searchController.searchBar.delegate = self;
    _searchController.searchResultsUpdater = self;
    [self.searchController setHidesNavigationBarDuringPresentation:NO];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([DataManager sharedManager].musicArray.count != 0) {
        [self.HUD hide:YES];
    }
    if (self.searchController.active == YES) {
        return self.searchResult.count;
    }else{
        return [DataManager sharedManager].musicArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (self.searchController.active == YES) {
        cell.music = [[DataManager sharedManager] selectMusicWithName:self.searchResult[indexPath.row]];
    }else{
        cell.music = [[DataManager sharedManager] selectMusicWithIndex:indexPath.row];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PlayingViewController *playingVC = [PlayingViewController sharedPlayingVC];
    if (self.searchController.active == YES) {
        playingVC.index = [[DataManager sharedManager] returnIndexWithMusicName:self.searchResult[indexPath.row]];
    }else{
        playingVC.index = indexPath.row;
    }
    [self showDetailViewController:playingVC sender:nil];
}
- (IBAction)showPlayingView:(UIButton *)sender {
    PlayingViewController *playingVC = [PlayingViewController sharedPlayingVC];
    if (playingVC.index < 0) {
        playingVC.index = 0;
    }
    [self showDetailViewController:playingVC sender:nil];
}

- (IBAction)searchBar:(UIButton *)sender {
//    NSIndexPath *index = [NSIndexPath indexPathWithIndex:0];
//    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:(UITableViewScrollPositionTop) animated:YES];
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    [self.searchController.searchBar becomeFirstResponder];
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated{
    
}
- (void)scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchController.searchBar resignFirstResponder];
    [self.navigationController.navigationBar setHidden:NO];
}
#pragma mark --- UISearchResultsUpdating  必须实现
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    [self.searchResult removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[cd]%@", self.searchController.searchBar.text];
    self.searchResult = [self.items filteredArrayUsingPredicate:predicate].mutableCopy;
    [self.tableView reloadData];
}

-(NSMutableArray *)items{
    self.items = [NSMutableArray array];
    for (Music *music in [DataManager sharedManager].musicArray) {
        [_items addObject:music.name];
    }
    return _items;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
