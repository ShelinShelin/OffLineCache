//
//  XLDataBase.h
//  XLNetwork
//
//  Created by Shelin on 15/11/18.
//  Copyright © 2015年 GreatGate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLDataBase : NSObject
+ (void)saveItemDict:(NSDictionary *)itemDict;
+ (NSArray *)list;
+ (NSArray *)listWithRange:(NSRange)range;
+ (BOOL)isExistWithId:(NSString *)idStr;
@end
