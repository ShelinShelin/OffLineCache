//
//  XLNetworkRequest.m
//  XLNetwork
//
//  Created by Shelin on 15/11/10.
//  Copyright © 2015年 GreatGate. All rights reserved.
//  http://mp.weixin.qq.com/s?__biz=MzAxMzE2Mjc2Ng==&mid=400521774&idx=2&sn=cf4fdcd3f3ac9a92a60729be6151f708&scene=0#wechat_redirect
/*
 * XLNetworkApi的一些功能和说明：
 
 1. 使用XLNetworkRequest做一些GET、POST、PUT、DELETE请求，与业务逻辑对接部分直接以数组或者字典的形式返回。
 2. 网络下载、上传文件，以block的形式返回实时的下载、上传进度，上传文件参数通过模型XLFileConfig去存取。
 3. 通过继承于XLDataService来将一些数据处理，模型转化封装起来，于业务逻辑对接返回的是对应的模型，减少Controllor处理数据处理逻辑的压力。
 4. 自定义一些回调的block
 */

#import "XLNetworkRequest.h"
#import "AFNetworking.h"

@implementation XLNetworkRequest

+ (void)getRequest:(NSString *)url params:(NSDictionary *)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler {
    
    //网络不可用
    if (![self checkNetworkStatus]) {
        successHandler(nil);
        failureHandler(nil);
        return;
    }

    AFHTTPRequestOperationManager *manager = [self getRequstManager];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        successHandler(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        XLLog(@"------请求失败-------%@",error);
        failureHandler(error);
    }];
}


+ (void)postRequest:(NSString *)url params:(NSDictionary *)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler {
    
    if (![self checkNetworkStatus]) {
        successHandler(nil);
        failureHandler(nil);
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [self getRequstManager];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        successHandler(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        XLLog(@"------请求失败-------%@",error);
        failureHandler(error);
    }];
}

+ (void)putRequest:(NSString *)url params:(NSDictionary *)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler {
    
    if (![self checkNetworkStatus]) {
        successHandler(nil);
        failureHandler(nil);
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [self getRequstManager];
    
    [manager PUT:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        successHandler(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        XLLog(@"------请求失败-------%@",error);
        failureHandler(error);
    }];
}

+ (void)deleteRequest:(NSString *)url params:(NSDictionary *)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler {
    
    if (![self checkNetworkStatus]) {
        successHandler(nil);
        failureHandler(nil);
        return;
    }

    AFHTTPRequestOperationManager *manager = [self getRequstManager];
    
    [manager DELETE:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        successHandler(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        XLLog(@"------请求失败-------%@",error);
        failureHandler(error);
    }];
}

/**
 下载文件，监听下载进度
 */
+ (void)downloadRequest:(NSString *)url successAndProgress:(progressBlock)progressHandler complete:(responseBlock)completionHandler {
    
    if (![self checkNetworkStatus]) {
        progressHandler(0, 0, 0);
        completionHandler(nil, nil);
        return;
    }
    
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



/**
 *  发送一个POST请求
 *  @param fileConfig 文件相关参数模型
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 *  无上传进度监听
 */
+ (void)updateRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(XLFileConfig *)fileConfig success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler {
    
    if (![self checkNetworkStatus]) {
        successHandler(nil);
        failureHandler(nil);
        return;
    }

    AFHTTPRequestOperationManager *manager = [self getRequstManager];
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:fileConfig.fileData name:fileConfig.name fileName:fileConfig.fileName mimeType:fileConfig.mimeType];
        
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        XLLog(@"------上传失败-------%@",error);
        failureHandler(error);
    }];
}


/**
 上传文件，监听上传进度
 */
+ (void)updateRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(XLFileConfig *)fileConfig successAndProgress:(progressBlock)progressHandler complete:(responseBlock)completionHandler {

    if (![self checkNetworkStatus]) {
        progressHandler(0, 0, 0);
        completionHandler(nil, nil);
        return;
    }
    
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

+ (AFHTTPRequestOperationManager *)getRequstManager {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 请求超时设定
    manager.requestSerializer.timeoutInterval = 10;
//    manager.securityPolicy.allowInvalidCertificates = YES;
    
    return manager;
}


/**
 监控网络状态
 */
+ (BOOL)checkNetworkStatus {
    
    __block BOOL isNetworkUse = YES;
    
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown) {
            isNetworkUse = YES;
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            isNetworkUse = YES;
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            isNetworkUse = YES;
        } else if (status == AFNetworkReachabilityStatusNotReachable){
            // 网络异常操作
            isNetworkUse = NO;
            XLLog(@"网络异常,请检查网络是否可用！");
        }
    }];
    [reachabilityManager startMonitoring];
    return isNetworkUse;
}

@end





/**
 *  用来封装上传参数
 */
@implementation XLFileConfig

+ (instancetype)fileConfigWithfileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    return [[self alloc] initWithfileData:fileData name:name fileName:fileName mimeType:mimeType];
}

- (instancetype)initWithfileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    if (self = [super init]) {
    
        _fileData = fileData;
        _name = name;
        _fileName = fileName;
        _mimeType = mimeType;
    }
    return self;
}

@end

