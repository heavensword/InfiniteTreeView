//
//  DemoCell.m
//  InfiniteTreeView
//
//  Created by Sword on 14-5-6.
//  Copyright (c) 2014年 Sword. All rights reserved.
//

#import "UserInfoCell.h"
#import "User.h"

@interface UserInfoCell()

@property (weak, nonatomic) IBOutlet UILabel *myTextLabel;

@end

@implementation UserInfoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.myTextLabel.text = self.user.name;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
