//
//  ViewController.m
//  InfiniteTreeView
//
//  Created by Sword on 14-5-6.
//  Copyright (c) 2014年 Sword. All rights reserved.
//

#import "ViewController.h"
#import "InfiniteTreeView.h"
#import "UserInfoCell.h"
#import "User.h"

@interface ViewController ()<PushTreeViewDataSource, PushTreeViewDelegate>
{
    InfiniteTreeView *_pushTreeView;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _pushTreeView = [InfiniteTreeView loadFromXib];
    _pushTreeView.frame = self.containerView.bounds;
    _pushTreeView.dataSource = self;
    _pushTreeView.delegate = self;
    [self.containerView addSubview:_pushTreeView];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PushTreeViewDataSource
- (NSInteger)numberOfSectionsInLevel:(NSInteger)level
{
    return 2 * level + 1;
}

- (NSInteger)numberOfRowsInLevel:(NSInteger)level section:(NSInteger)section
{
    return level * section + 1;
}

- (InfiniteTreeBaseCell *)pushTreeView:(InfiniteTreeView *)pushTreeView level:(NSInteger)level indexPath:(NSIndexPath*)indexPath
{
    static NSString *identifier = @"UserInfoCell";
    UserInfoCell *cell = (UserInfoCell*)[pushTreeView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [UserInfoCell cellFromNib];
    }
    cell.user = [self userFromSectionAndLevel:indexPath level:level];
    return cell;
}

#pragma mark - PushTreeViewDelegate
- (void)pushTreeView:(InfiniteTreeView *)pushTreeView didSelectedLevel:(NSInteger)level indexPath:(NSIndexPath*)indexPath
{

}

- (UIView *)pushTreeView:(InfiniteTreeView *)pushTreeView level:(NSInteger)level viewForHeaderInSection:(NSInteger)section
{
    CGFloat headerHeight = 24;
    UIView *headerview = nil;
    headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, headerHeight)];
    headerview.backgroundColor = RGBCOLOR(233, 238, 247);
    UILabel *titL = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, headerHeight)];
    titL.text = [NSString stringWithFormat:@"Section%ld", section];
    titL.textColor = RGBCOLOR(104, 104, 104);
    titL.backgroundColor = [UIColor clearColor];
    titL.font = [UIFont boldSystemFontOfSize:12];
    [headerview addSubview:titL];
    return headerview;
}

- (CGFloat)pushTreeView:(InfiniteTreeView *)pushTreeView level:(NSInteger)level heightForHeaderInSection:(NSInteger)section
{
    return 24;
}

- (CGFloat)pushTreeView:(InfiniteTreeView *)pushTreeView level:(NSInteger)level heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (BOOL)pushTreeViewHasNextLevel:(InfiniteTreeView *)pushTreeView currentLevel:(NSInteger)level indexPath:(NSIndexPath*)indexPath
{
    BOOL next = TRUE;
    if (level == 2 && indexPath.section == 1) {
        next = FALSE;
    }
    return next;
}

- (void)pushTreeViewWillReloadAtLevel:(InfiniteTreeView*)pushTreeView currentLevel:(NSInteger)currentLevel level:(NSInteger)level                            indexPath:(NSIndexPath*)indexPath
{
    NSLog(@"current level %ld level %ld", currentLevel, level);
}

#pragma mark - private methods
- (User*)userFromSectionAndLevel:(NSIndexPath*)indexPath level:(NSInteger)level
{
    User *user = [[User alloc] init];
    user.name = [NSString stringWithFormat:@"L%ldS%ldR%ld%d", level, indexPath.section, indexPath.row, rand() % 10];
//    user.name = [@(rand() % 1000) stringValue];
    return user;
}

#pragma mark - IBAction methods
- (IBAction)onBackBtnTouched:(id)sender
{
    if (_pushTreeView.level >= 1) {
        [_pushTreeView back];
    }
}

@end
