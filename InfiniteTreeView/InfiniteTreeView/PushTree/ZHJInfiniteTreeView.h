//
//  PushTreeView.h
//  Sword
//
//  Created by Sword on 14-4-8.
//  Copyright (c) 2014年 Sword. All rights reserved.
//

#import "ZHJXibView.h"
#import "ZHJInfiniteTreeTableView.h"

@protocol PushTreeViewDataSource;
@protocol PushTreeViewDelegate;
@class ZHJInfiniteTreeBaseCell;

@interface ZHJInfiniteTreeView : ZHJXibView
{
}

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, assign) id<PushTreeViewDataSource>dataSource;
@property (nonatomic, assign) id<PushTreeViewDelegate>delegate;

- (void)back;

- (void)reloadData;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (ZHJInfiniteTreeBaseCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)selectedAtLevel:(NSInteger)level indexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier level:(NSInteger)level NS_AVAILABLE_IOS(6_0);

@end

@protocol PushTreeViewDataSource <NSObject>
@required
- (NSInteger)numberOfSectionsInLevel:(NSInteger)level;
- (NSInteger)numberOfRowsInLevel:(NSInteger)level section:(NSInteger)section;
- (ZHJInfiniteTreeBaseCell *)pushTreeView:(ZHJInfiniteTreeView *)pushTreeView level:(NSInteger)level indexPath:(NSIndexPath*)indexPath;

@end

@protocol PushTreeViewDelegate <NSObject>
@required
- (void)pushTreeViewWillReloadAtLevel:(ZHJInfiniteTreeView*)pushTreeView currentLevel:(NSInteger)currentLevel level:(NSInteger)level indexPath:(NSIndexPath*)indexPath;

@optional
- (void)pushTreeView:(ZHJInfiniteTreeView *)pushTreeView didSelectedLevel:(NSInteger)level indexPath:(NSIndexPath*)indexPath;
- (BOOL)pushTreeViewHasNextLevel:(ZHJInfiniteTreeView *)pushTreeView currentLevel:(NSInteger)level indexPath:(NSIndexPath*)indexPath;
- (UIView *)pushTreeView:(ZHJInfiniteTreeView *)pushTreeView level:(NSInteger)level viewForHeaderInSection:(NSInteger)section;
- (CGFloat)pushTreeView:(ZHJInfiniteTreeView *)pushTreeView level:(NSInteger)level heightForHeaderInSection:(NSInteger)section;
- (CGFloat)pushTreeView:(ZHJInfiniteTreeView *)pushTreeView level:(NSInteger)level heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
