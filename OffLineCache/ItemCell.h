//
//  ItemCell.h
//  OffLineCache
//
//  Created by Shelin on 15/11/19.
//  Copyright © 2015年 GreatGate. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Item;
@interface ItemCell : UITableViewCell
@property (nonatomic, strong) Item *item;

+ (ItemCell *)itemCellWithTableView:(UITableView *)tableView;
@end
