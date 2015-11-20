//
//  XLDataService.h
//  XLNetwork
//
//  Created by Shelin on 15/11/10.
//  Copyright © 2015年 GreatGate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLNetworkRequest.h"
#import "MJExtension.h"

@interface XLDataService : NSObject

/**
 GET请求转模型
 */
+ (void)getWithUrl:(NSString *)url param:(id)param modelClass:(Class)modelClass responseBlock:(responseBlock)responseDataBlock;

/**
 POST请求转模型
 */
+ (void)postWithUrl:(NSString *)url param:(id)param modelClass:(Class)modelClass responseBlock:(responseBlock)responseDataBlock;


+ (void)putWithUrl:(NSString *)url param:(id)param modelClass:(Class)modelClass responseBlock:(responseBlock)responseDataBlock;

+ (void)deleteWithUrl:(NSString *)url param:(id)param modelClass:(Class)modelClass responseBlock:(responseBlock)responseDataBlock;

/**
 数组、字典转模型，提供给子类的接口
 */
+ (id)modelTransformationWithResponseObj:(id)responseObj modelClass:(Class)modelClass;

@end
