//
//  ItemCell.m
//  OffLineCache
//
//  Created by Shelin on 15/11/19.
//  Copyright © 2015年 GreatGate. All rights reserved.
//

#import "ItemCell.h"
#import "Item.h"
#import "UIImageView+WebCache.h"

@interface ItemCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *textView;

@end

@implementation ItemCell

+ (ItemCell *)itemCellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"item";
    
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ItemCell" owner:nil options:nil].lastObject;
    }
    return cell;
}

- (void)setItem:(Item *)item {
    
    _item = item;
    
    NSString *imageUrl = [NSString stringWithFormat:@"https://spic-108tian-com.alikunlun.com/pic/%@",self.item.headImg];
    
    //NSLog(@"%@",imageUrl);
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    
    self.textView.text = item.name;
    //NSLog(@"%@",item.name);
    
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
