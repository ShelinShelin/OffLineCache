//
//  ViewController.m
//  OffLineCache
//
//  Created by Shelin on 15/11/19.
//  Copyright © 2015年 GreatGate. All rights reserved.
//

#import "ViewController.h"
#import "GetTableViewData.h"
#import "Item.h"
#import "XLDataBase.h"
#import "ItemCell.h"
#import "MJRefresh.h"

#define URL_TABLEVIEW @"https://api.108tian.com/mobile/v3/EventList?cityId=1&step=10&theme=0&page=%lu"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_dataArray;
    UITableView *_tableView;
    NSInteger _currentPage;
}
@end

@implementation ViewController

#pragma mark Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createTableView];
    _dataArray = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSRange range = NSMakeRange(0, 10);
    //如果数据库有数据则读取，不发送网络请求
    if ([[XLDataBase listWithRange:range] count]) {
        [_dataArray addObjectsFromArray:[XLDataBase listWithRange:range]];
        NSLog(@"从数据库加载");
    }else{
        [self getTableViewDataWithPage:0];
    }
}

#pragma mark UI
- (void)createTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 100.0;
    [self.view addSubview:_tableView];
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadNewData];
    }];
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
}

#pragma mark GetDataSoure
//字典转模型
- (void)getTableViewDataWithPage:(NSInteger)page {
    NSLog(@"发送网络请求！");
    NSString *url = [NSString stringWithFormat:URL_TABLEVIEW, page];
    [GetTableViewData getWithUrl:url param:nil modelClass:[Item class] responseBlock:^(id dataObj, NSError *error) {
        [_dataArray addObjectsFromArray:dataObj];
        [_tableView reloadData];
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
    }];
}

- (void)loadNewData {
    NSLog(@"下拉刷新");
    _currentPage = 0;
    [_dataArray removeAllObjects];
    [self getTableViewDataWithPage:_currentPage];
}

- (void)loadMoreData {
    NSLog(@"上拉加载");
    _currentPage ++;
    NSRange range = NSMakeRange(_currentPage * 10, 10);
    if ([[XLDataBase listWithRange:range] count]) {
        [_dataArray addObjectsFromArray:[XLDataBase listWithRange:range]];
        [_tableView reloadData];
        [_tableView.mj_footer endRefreshing];
        NSLog(@"数据库加载%lu条更多数据",[[XLDataBase listWithRange:range] count]);
    }else{
        //数据库没更多数据时再网络请求
        [self getTableViewDataWithPage:_currentPage];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCell *cell = [ItemCell itemCellWithTableView:tableView];
    cell.item = _dataArray[indexPath.row];
    return cell;
}


@end
