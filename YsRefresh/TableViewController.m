//
//  TableViewController.m
//  YsRefresh
//
//  Created by weiying on 16/2/3.
//  Copyright © 2016年 Yuns. All rights reserved.
//

#import "TableViewController.h"
#import "YsRefresh.h"

@interface TableViewController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) YsRefreshHeader *ysHeader;
@property (nonatomic, strong) YsRefreshFooter *ysFooter;
@end

@implementation TableViewController
{
    BOOL _isDownRefresh;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.dataSource = [NSMutableArray array];
    [self setupRefresh];
}

- (void)setupRefresh
{
    __weak typeof(self) weakSelf = self;
    self.ysHeader = [[YsRefreshHeader alloc] initWithScrollView:self.tableView refreshBlock:^{
        [weakSelf loadNewData];
    }];
    [self.ysHeader beginRefresh];
    
    self.ysFooter = [[YsRefreshFooter alloc] initWithScrollView:self.tableView refreshBlock:^{
        [self loadMoreData];
    }];
}

- (void)loadNewData
{
    _isDownRefresh = YES;
    [self getData];
}

- (void)loadMoreData
{
    _isDownRefresh = NO;
    [self getData];
}

- (void)getData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *refreshText = _isDownRefresh ? @"这是下拉数据" : @"这是上拉数据";
        for (NSInteger i = 0; i < 3; i ++) {
            if (self.dataSource.count > 0) {
                if (_isDownRefresh) {
                    [self.dataSource insertObject:refreshText atIndex:0];
                }else{
                    [self.dataSource addObject:refreshText];
                }
            }else{
                [self.dataSource addObject:refreshText];
            }
        }
        [self.ysHeader endRefresh];
        [self.ysFooter endRefresh];
        [self.tableView reloadData];
        
    });
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    NSString *refreshText = self.dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ -- %zd",refreshText,indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
