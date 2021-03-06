
//
//  HYHomePageController.m
//  无法修盖
//
//  Created by HelloWorld on 15/8/8.
//  Copyright (c) 2015年 SearchPrefect. All rights reserved.
//

#import "HYHomePageController.h"
#import "DropDownMenu.h"
#import "NavTitleBtn.h"
#import "HYTAccountTool.h"
#import "UIImageView+WebCache.h"
#import "HYTStatusFrame.h"
#import "HYTStatusCell.h"
#import "MJExtension.h"
#import "HYTFooterRefreshView.h"

@interface HYHomePageController () <DropDownMenuDelegate>

/** 微博模型属性 */
@property (nonatomic, strong) NSMutableArray *statusFrames;

@end

@implementation HYHomePageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:HYTCOLOR(239, 239, 239)];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.statusFrames = [NSMutableArray array];
    
    [self setupNavInfo];
    
    [self setupNavTitle];
    
    //集成上拉、下拉组件
    [self setupDragDownRefresh];
    [self setupDragUpRefresh];
    
    //开启自定调度，检测未读数
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(loadRequestUnreadInfo) userInfo:nil repeats:YES];
    //将timer加入到消息循环中（指定NSRunLoopCommonModes）
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark - 集成上拉、下拉刷新组件
- (void)setupDragDownRefresh {
    
    UIRefreshControl *downRefresh = [[UIRefreshControl alloc] init];
    [downRefresh setBackgroundColor:[UIColor redColor]];
    [downRefresh addTarget:self action:@selector(refreshNewStatus:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:downRefresh];
    
    //一开始就进入到刷新状态
    [downRefresh beginRefreshing];
    [self refreshNewStatus:downRefresh];
}
- (void)setupDragUpRefresh {
    
    HYTFooterRefreshView *footerRefreshView = [HYTFooterRefreshView footerRefreshView];
    [footerRefreshView setHidden:YES];
    self.tableView.tableFooterView = footerRefreshView;
}

#pragma mark - 下拉刷新
- (void)refreshNewStatus:(UIRefreshControl *)refreshControl {
    
    HYTStatusFrame *statusFrame = [self.statusFrames firstObject];
    HYTStatus *status = statusFrame.status;
    HYTAccount *account = [HYTAccountTool accountInfo];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"access_token"] = account.accessToken;
    if (status.statusID) {
        parameters[@"since_id"] = status.statusID;
    }
    [HYTHttpTool get:@"https://api.weibo.com/2/statuses/friends_timeline.json"
          parameters:parameters
             success:^(id responseObject) {
                 
                 [refreshControl endRefreshing];
                 
                 //将字典数组转化为模型数组
                 NSArray *statuses = [HYTStatus mj_objectArrayWithKeyValuesArray:responseObject[@"statuses"]];
                 
                 //提醒新的微博数量
                 [self alertuNewsStatusCount:statuses.count];
                 
                 //插入到模型数组中
                 NSIndexSet *statusesIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statuses.count)];
                 [self.statusFrames insertObjects:[self statusFramesWithStatuses:statuses] atIndexes:statusesIndexSet];
                 
                 //刷新表格
                 [self.tableView reloadData];
             } failure:^(NSError *error) {
                 
             }
     ];
    
}
#pragma mark - 上拉加载更多数据
- (void)loadMoreStatus {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    HYTAccount *account = [HYTAccountTool accountInfo];
    parameters[@"access_token"] = account.accessToken;
    
    //若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
    HYTStatusFrame *statusFrame = [self.statusFrames lastObject];
    HYTStatus *status = statusFrame.status;
    if (status) {
        long long maxID = [status.statusID longLongValue] - 1;
        parameters[@"max_id"] = @(maxID);    //max_id返回的是
    }
    
    [HYTHttpTool get:@"https://api.weibo.com/2/statuses/friends_timeline.json"
          parameters:parameters
             success:^(id responseObject) {
                 //将字典数组转化为模型数组
                 NSArray *oldStatuses = [HYTStatus mj_objectArrayWithKeyValuesArray:responseObject[@"statuses"]];
                 [self.statusFrames addObjectsFromArray:[self statusFramesWithStatuses:oldStatuses]];
                 
                 //刷新表格
                 [self.tableView reloadData];
                 self.tableView.tableFooterView.hidden = YES;
             } failure:^(NSError *error) {
                 
             }
     ];
}

#pragma mark - 提醒新微博数量
- (void)alertuNewsStatusCount:(NSUInteger)statusCount {
    
    //只要刷新成功后清除未读提醒
    self.tabBarItem.badgeValue = nil;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if (statusCount == 0) return;
    UILabel *alertLabel = [[UILabel alloc] init];
    [alertLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline_new_status_background"]]];
    [alertLabel setText:[NSString stringWithFormat:@"%li 条新微薄", statusCount]];
    [alertLabel setTextAlignment:NSTextAlignmentCenter];
    [alertLabel setTextColor:[UIColor whiteColor]];
    [alertLabel setSize:CGSizeMake(SCREEN_WIDTH, 30)];
    [alertLabel setOrigin:CGPointMake(0, self.navigationController.navigationBar.bottomY-alertLabel.height)];
    [self.navigationController.view insertSubview:alertLabel belowSubview:self.navigationController.navigationBar];
    
    CGFloat duration = 1.0f;
    CGFloat delay = 1.0f;
    [UIView animateWithDuration:duration
                     animations:^{
                         [alertLabel setTransform:CGAffineTransformMakeTranslation(0, alertLabel.x + alertLabel.height)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration
                                               delay:delay
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              [alertLabel setTransform:CGAffineTransformIdentity];
                                          }
                                          completion:^(BOOL finished) {
                                              [alertLabel removeFromSuperview];
                                          }];
    }];
    
}

#pragma mark - 加载未查看信息
- (void)loadRequestUnreadInfo {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    HYTAccount *account = [HYTAccountTool accountInfo];
    parameters[@"access_token"] = account.accessToken;
    parameters[@"uid"] = account.accountID;
    
    [HYTHttpTool get:@"https://rm.api.weibo.com/2/remind/unread_count.json"
          parameters:parameters
             success:^(id responseObject) {
                 NSString *unreadStutasCount = responseObject[@"status"];
                 unreadStutasCount = unreadStutasCount.description;
                 if (unreadStutasCount.integerValue) {
                     self.tabBarItem.badgeValue = unreadStutasCount;
                     //设置AppIcon提醒数字
                     [UIApplication sharedApplication].applicationIconBadgeNumber = unreadStutasCount.integerValue;
                 } else {
                     self.tabBarItem.badgeValue = nil;
                     [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                 }

             } failure:^(NSError *error) {
                 
             }
     ];
}

#pragma mark - 设置导航栏信息
- (void)setupNavInfo {
    //导航栏左侧按钮
    [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem itemWithTarget:self
                                                                     selector:@selector(friendSearch)
                                                                    imageName:@"navigationbar_friendsearch"
                                                         highlightedImageName:@"navigationbar_friendsearch_highlighted"]];
    
    //导航栏右侧按钮
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithTarget:self
                                                                      selector:@selector(pop)
                                                                     imageName:@"navigationbar_pop"
                                                          highlightedImageName:@"navigationbar_pop_highlighted"]];
    
    //导航标题View
    NSString *screenName = [HYTAccountTool accountInfo].accountScreenName;
    
    NavTitleBtn *customBtn = [NavTitleBtn buttonWithType:UIButtonTypeCustom];
    [customBtn setImage:[UIImage imageNamed:@"navigationbar_arrow_down"] forState:UIControlStateNormal];
    [customBtn setImage:[UIImage imageNamed:@"navigationbar_arrow_up"] forState:UIControlStateSelected];
    [customBtn setTitle:screenName ? screenName : @"首页" forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [customBtn setFrame:CGRectMake(0, 0, 200, 40)];
    [customBtn addTarget:self action:@selector(dropMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setTitleView:customBtn];
}
#pragma mark - 设置导航标题
- (void)setupNavTitle {
    
    HYTAccount *account = [HYTAccountTool accountInfo];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"access_token"] = account.accessToken;
    parameters[@"uid"] = account.accountID;
    
    [HYTHttpTool get:@"https://api.weibo.com/2/users/show.json"
          parameters:parameters
             success:^(id responseObject) {
                 HYTUser *user = [HYTUser mj_objectWithKeyValues:responseObject];
                 
                 //与上次昵称相同则直接返回
                 if ([user.name isEqualToString:account.accountScreenName]) return;
                 
                 account.accountScreenName = user.name;
                 NavTitleBtn *navTitle = (NavTitleBtn *)self.navigationItem.titleView;
                 [navTitle setTitle:account.accountScreenName forState:UIControlStateNormal];
                 [HYTAccountTool saveAccountInfo:account];
             } failure:^(NSError *error) {
                 
             }
     ];
}

- (NSMutableArray *)statusFramesWithStatuses:(NSArray *)statuses {
    
    NSMutableArray *statusFrames = [NSMutableArray array];
    for (HYTStatus *status in statuses) {
        [statusFrames addObject:[HYTStatusFrame statusFrameWithStatus:status]];
    }
    return statusFrames;
}

#pragma mark - 弹出下拉菜单
- (void)dropMenu:(UIButton *)btn {
    
    DropDownMenu *menu = [DropDownMenu menu];
    menu.delegate = self;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    [contentView setBackgroundColor:[UIColor redColor]];
    [menu setContentView:contentView];
    [menu showFromView:btn];
}

#pragma mark - DropDownMenuDelegate
- (void)dropDownMenuDidShowMenu:(DropDownMenu *)menu {
    
    UIButton *navTitleBtn = (UIButton *)self.navigationItem.titleView;
    [navTitleBtn setSelected:YES];
}
- (void)dropDownMenuDidDismissMenu:(DropDownMenu *)menu {
    UIButton *navTitleBtn = (UIButton *)self.navigationItem.titleView;
    [navTitleBtn setSelected:NO];
}

#pragma mark - 导航栏左右、按钮点击事件
- (void)friendSearch {
    
    NSLog(@"%@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}
- (void)pop {
    NSLog(@"%@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.statusFrames.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HYTStatusFrame *statusFrame = self.statusFrames[indexPath.row];
    
    HYTStatusCell *cell = [HYTStatusCell statusCellWithTableView:tableView];
    cell.statusFrame = statusFrame;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYTStatusFrame *statusFrame = self.statusFrames[indexPath.row];
    return statusFrame.cellTotalHeight;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.statusFrames.count==0 || self.tableView.tableFooterView.isHidden == NO) return;
    CGFloat offsetY = scrollView.contentOffset.y;
    
    //scrollView.contentInset (top = 64, left = 0, bottom = 49, right = 0)
    CGFloat footerViewY = scrollView.contentSize.height - scrollView.height - scrollView.contentInset.top + self.tableView.tableFooterView.height;
    //最后一个Cell是否完全显示出来
    if (offsetY >= footerViewY) {
        NSLog(@"---------上拉加载------");
        
        self.tableView.tableFooterView.hidden = NO;
        [self loadMoreStatus];
    }
}

@end
