//
//  XLNetworkRequest.h
//  XLNetwork
//
//  Created by Shelin on 15/11/10.
//  Copyright © 2015年 GreatGate. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XLFileConfig;

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


#ifdef DEBUG
#define XLLog(...) NSLog(__VA_ARGS__)
#else
#define XLLog(...)
#endif

@interface XLNetworkRequest : NSObject

/**
 GET请求
 */
+ (void)getRequest:(NSString *)url params:(NSDictionary *)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler;

/**
 POST请求
 */
+ (void)postRequest:(NSString *)url params:(NSDictionary *)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler;

/**
 PUT请求
 */
+ (void)putRequest:(NSString *)url params:(NSDictionary *)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler;

/**
 DELETE请求
 */
+ (void)deleteRequest:(NSString *)url params:(NSDictionary *)params success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler;

/**
 下载文件，监听下载进度
 */
+ (void)downloadRequest:(NSString *)url successAndProgress:(progressBlock)progressHandler complete:(responseBlock)completionHandler;

/**
 文件上传
 */
+ (void)updateRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(XLFileConfig *)fileConfig success:(requestSuccessBlock)successHandler failure:(requestFailureBlock)failureHandler;

/**
 文件上传，监听上传进度
 */
+ (void)updateRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(XLFileConfig *)fileConfig successAndProgress:(progressBlock)progressHandler complete:(responseBlock)completionHandler;

@end






/**
 *  用来封装上文件数据的模型类
 */
@interface XLFileConfig : NSObject
/**
 *  文件数据
 */
@property (nonatomic, strong) NSData *fileData;

/**
 *  服务器接收参数名
 */
@property (nonatomic, copy) NSString *name;

/**
 *  文件名
 */
@property (nonatomic, copy) NSString *fileName;

/**
 *  文件类型
 */
@property (nonatomic, copy) NSString *mimeType;

+ (instancetype)fileConfigWithfileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

- (instancetype)initWithfileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;
@end
