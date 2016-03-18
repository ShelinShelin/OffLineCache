# OffLineCache
关于数据库离线缓存思路，以及AFN的再次封装，离线状态时从数据库加载数据以及加载更多
About Offline caching ideas and The use of AFN
http://www.jianshu.com/p/f2e59e98ab86

一直想总结一下关于iOS的离线数据缓存的方面的问题，然后最近也简单的对AFN进行了再次封装，所有想把这两个结合起来写一下。数据展示型的页面做离线缓存可以有更好的用户体验，用户在离线环境下仍然可以获取一些数据，这里的数据缓存首选肯定是SQLite，轻量级，对数据的存储读取相对于其他几种方式有优势，这里对AFN的封装没有涉及太多业务逻辑层面的需求，主要还是对一些方法再次封装方便使用，解除项目对第三方的耦合性，能够简单的快速的更换底层使用的网络请求代码。这篇主要写离线缓存思路，对AFN的封装只做简单的介绍。
#####关于XLNetworkApi
XLNetworkApi的一些功能和说明：
- 使用XLNetworkRequest做一些GET、POST、PUT、DELETE请求，与业务逻辑对接部分直接以数组或者字典的形式返回。
- 以及网络下载、上传文件，以block的形式返回实时的下载、上传进度，上传文件参数通过模型XLFileConfig去存取。
- 通过继承于XLDataService来将一些数据处理，模型转化封装起来，于业务逻辑对接返回的是对应的模型，减少Controllor处理数据处理逻辑的压力。

- 自定义一些回调的block
```
/**
 请求成功block
 */
typedef void (^requestSuccessBlock)(id responseObj);
/**
 请求失败block
 */
typedef void (^requestFailureBlock) (NSError *error);
/**
 请求响应block
 */
typedef void (^responseBlock)(id dataObj, NSError *error);
/**
 监听进度响应block
 */
typedef void (^progressBlock)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
 ```
- XLNetworkRequest.m部分实现
```
#import "XLNetworkRequest.h"
#import "AFNetworking.h"
@implementation XLNetworkRequest
 + (void)getRequest:(NSString *)url params:(NSDictionary *)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler {

    AFHTTPRequestOperationManager *manager = [self getRequstManager];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        successHandler(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        XLLog(@"------请求失败-------%@",error);
        failureHandler(error);
    }];
}
  ```
- 下载部分代码
```
 //下载文件，监听下载进度
 + (void)downloadRequest:(NSString *)url successAndProgress:(progressBlock)progressHandler complete:(responseBlock)completionHandler {
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSProgress *kProgress = nil;
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&kProgress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSURL *documentUrl = [[NSFileManager defaultManager] URLForDirectory :NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        return [documentUrl URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error){
        if (error) {
            XLLog(@"------下载失败-------%@",error);
        }
        completionHandler(response, error);
    }];
    
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        progressHandler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        
    }];
    [downloadTask resume];
}
  ```
- 上传部分代码
```
 //上传文件，监听上传进度
  + (void)updateRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(XLFileConfig *)fileConfig successAndProgress:(progressBlock)progressHandler complete:(responseBlock)completionHandler {

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:fileConfig.fileData name:fileConfig.name fileName:fileConfig.fileName mimeType:fileConfig.mimeType];
        
    } error:nil];
    
    //获取上传进度
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        progressHandler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completionHandler(responseObject, nil);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        completionHandler(nil, error);
        if (error) {
            XLLog(@"------上传失败-------%@",error);
        }
    }];
    
    [operation start];
}

  ```
- XLDataService.m部分实现
```
  + (void)getWithUrl:(NSString *)url param:(id)param modelClass:(Class)modelClass responseBlock:(responseBlock)responseDataBlock {
        [XLNetworkRequest getRequest:url params:param success:^(id responseObj) {
        //数组、字典转化为模型数组
           
        dataObj = [self modelTransformationWithResponseObj:responseObj modelClass:modelClass];
        responseDataBlock(dataObj, nil);
        
    } failure:^(NSError *error) {
        responseDataBlock(nil, error);
    }];
}
  ```
- （关键）下面这个方法提供给继承XLDataService的子类重写，将转化为模型的代码写在这里，相似业务的网络数据请求都可以用这个子类去请求数据，直接返回对应的模型数组。
```
/**
 数组、字典转化为模型
 */
  + (id)modelTransformationWithResponseObj:(id)responseObj modelClass:(Class)modelClass {
       return nil;
}
  ```
#####关于离线数据缓存
当用户进入程序的展示页面，有三个情况下可能涉及到数据库存取操作，简单画了个图来理解，思路比较简单，主要是一些存取的细节处理。
- 进入展示页面

  ![进入页面.png](http://upload-images.jianshu.io/upload_images/1121012-2856dc868aace48a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- 下拉刷新最新数据
![下拉刷新.png](http://upload-images.jianshu.io/upload_images/1121012-fa735bfc25e2e5a8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 上拉加载更多数据
![上拉加载更多.png](http://upload-images.jianshu.io/upload_images/1121012-8caa1332483dbe56.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- 需要注意的是，上拉加载更多的时候，每次从数据库返回一定数量的数据，而不是一次性将数据全部加载，否则会有内存问题，直到数据库中没有更多数据时再发生网络请求，再次将新数据存入数据库。这里存储数据的方式是将服务器返回每组数据的字典归档成二进制作为数据库字段直接存储，这样存储在模型属性比较多的情况下更有优势，避免每一个属性作为一个字段，另外增加了一个idStr字段用来判断数据的唯一性，避免重复存储。
首先定义一个工具类XLDataBase来做数据库相关的操作，这里用的是第三方的FMDB。

```
#import "XLDataBase.h"
#import "FMDatabase.h"
#import "Item.h"
#import "MJExtension.h"

@implementation XLDataBase

static FMDatabase *_db;

+ (void)initialize {
    
    NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/Data.db",NSHomeDirectory()];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_item (id integer PRIMARY KEY, itemDict blob NOT NULL, idStr text NOT NULL)"];
}

//存入数据库
+ (void)saveItemDict:(NSDictionary *)itemDict {
    //此处把字典归档成二进制数据直接存入数据库，避免添加过多的数据库字段
    NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:itemDict];
    
    [_db executeUpdateWithFormat:@"INSERT INTO t_item (itemDict, idStr) VALUES (%@, %@)",dictData, itemDict[@"id"]];
}

//返回全部数据
+ (NSArray *)list {

    FMResultSet *set = [_db executeQuery:@"SELECT * FROM t_item"];
    NSMutableArray *list = [NSMutableArray array];
    
    while (set.next) {
        // 获得当前所指向的数据
        
        NSData *dictData = [set objectForColumnName:@"itemDict"];
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:dictData];
        [list addObject:[Item mj_objectWithKeyValues:dict]];
    }
    return list;
}

//取出某个范围内的数据
+ (NSArray *)listWithRange:(NSRange)range {
    
    NSString *SQL = [NSString stringWithFormat:@"SELECT * FROM t_item LIMIT %lu, %lu",range.location, range.length];
    FMResultSet *set = [_db executeQuery:SQL];
    NSMutableArray *list = [NSMutableArray array];
    
    while (set.next) {
        NSData *dictData = [set objectForColumnName:@"itemDict"];
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:dictData];
        [list addObject:[Item mj_objectWithKeyValues:dict]];
    }
    return list;
}

//通过一组数据的唯一标识判断数据是否存在
+ (BOOL)isExistWithId:(NSString *)idStr
{
    BOOL isExist = NO;
    
    FMResultSet *resultSet= [_db executeQuery:@"SELECT * FROM t_item where idStr = ?",idStr];
    while ([resultSet next]) {
        if([resultSet stringForColumn:@"idStr"]) {
            isExist = YES;
        }else{
            isExist = NO;
        }
    }
    return isExist;
}
@end

  ```
- 一些继承于XLDataService的子类的数据库存储和模型转换的逻辑代码

```
#import "GetTableViewData.h"
#import "XLDataBase.h"

@implementation GetTableViewData

//重写父类方法
+ (id)modelTransformationWithResponseObj:(id)responseObj modelClass:(Class)modelClass {
    NSArray *lists = responseObj[@"data"][@"list"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in lists) {
        [modelClass mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{ @"ID" : @"id" };
        }];
        [array addObject:[modelClass mj_objectWithKeyValues:dict]];
        
        //通过idStr先判断数据是否存储过，如果没有，网络请求新数据存入数据库
        if (![XLDataBase isExistWithId:dict[@"id"]]) {
            //存数据库
            NSLog(@"存入数据库");
            [XLDataBase saveItemDict:dict];
        }
    }
    return array;
}

  ```

- 下面是一些控制器的代码实现：

```
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
    NSInteger _currentPage;//当前数据对应的page
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

  ```

