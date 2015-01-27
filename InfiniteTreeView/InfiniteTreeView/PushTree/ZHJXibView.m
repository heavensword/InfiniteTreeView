//
//  ITTXibView.m
//  Sword
//
//  Created by Sword on 3/9/12.
//  Copyright (c) 2012 Sword. All rights reserved.
//

#import "ZHJXibView.h"

@implementation ZHJXibView

- (void)dealloc
{
    NSLog(@"%@ is dealloced!", [self class]);
}

+ (id)loadFromXib
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    if (array && [array count]) {
        return array[0];
    }else {
        return nil;
    }
}
@end
