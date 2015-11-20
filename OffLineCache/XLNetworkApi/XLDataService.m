//
//  XLDataService.m
//  XLNetwork
//
//  Created by Shelin on 15/11/10.
//  Copyright © 2015年 GreatGate. All rights reserved.
//

#import "XLDataService.h"
#import "AFNetworking.h"

static id dataObj;

@implementation XLDataService

+ (void)getWithUrl:(NSString *)url param:(id)param modelClass:(Class)modelClass responseBlock:(responseBlock)responseDataBlock {
        [XLNetworkRequest getRequest:url params:param success:^(id responseObj) {
        //数组、字典转化为模型数组
           
        dataObj = [self modelTransformationWithResponseObj:responseObj modelClass:modelClass];
        responseDataBlock(dataObj, nil);
        
    } failure:^(NSError *error) {
        
        responseDataBlock(nil, error);
    }];
}

+ (void)postWithUrl:(NSString *)url param:(id)param modelClass:(Class)modelClass responseBlock:(responseBlock)responseDataBlock {
    
       [XLNetworkRequest postRequest:url params:param success:^(id responseObj) {
        
        dataObj = [self modelTransformationWithResponseObj:responseObj modelClass:modelClass];
        responseDataBlock(dataObj, nil);
    } failure:^(NSError *error) {
        
        responseDataBlock(nil, error);
    }];
}

+ (void)putWithUrl:(NSString *)url param:(id)param modelClass:(Class)modelClass responseBlock:(responseBlock)responseDataBlock {

        [XLNetworkRequest putRequest:url params:param success:^(id responseObj) {
        
        dataObj = [self modelTransformationWithResponseObj:responseObj modelClass:modelClass];
        responseDataBlock(dataObj, nil);
    } failure:^(NSError *error) {
        
        responseDataBlock(nil, error);
    }];
}

+ (void)deleteWithUrl:(NSString *)url param:(id)param modelClass:(Class)modelClass responseBlock:(responseBlock)responseDataBlock {
    
        [XLNetworkRequest deleteRequest:url params:param success:^(id responseObj) {
        
        dataObj = [self modelTransformationWithResponseObj:responseObj modelClass:modelClass];
        responseDataBlock(dataObj, nil);
    } failure:^(NSError *error) {
        
        responseDataBlock(nil, error);
    }];
}

/**
 数组、字典转化为模型
 */
+ (id)modelTransformationWithResponseObj:(id)responseObj modelClass:(Class)modelClass {
        
    return nil;
}



@end
