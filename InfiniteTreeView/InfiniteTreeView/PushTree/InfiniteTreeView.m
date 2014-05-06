//
//  PushTreeView.m
//  RongXin
//
//  Created by Sword on 14-4-8.
//  Copyright (c) 2014年 KSY. All rights reserved.
//

#import "InfiniteTreeView.h"
#import "InfiniteTreeBaseCell.h"
#import "InfiniteTreeTableView.h"

//#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define SAME_INDEXPATH(i1, i2) (i1.section == i2.section && i1.row == i2.row)

@interface InfiniteTreeView()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL            _animating;
    BOOL            _animated;
    NSInteger       _selectedLevel;
    NSInteger       _currentReloadDataLevel;
    NSIndexPath     *_selectedIndexPath;
    NSIndexPath     *_previousIndexPath;
    NSMutableSet    *_tableViews;
    NSMutableSet    *_recyleTableViews;
    UIView          *_lineView;
    NSMutableDictionary *_selectedLevelIndexDic;
}
@end

@implementation InfiniteTreeView

- (void)dealloc
{
    _dataSource = nil;
    _delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _animated = TRUE;
        // Initialization code
        [self collectTableViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _animating = FALSE;
    _animated = TRUE;
    _level = 0;
    _selectedLevel = NSNotFound;
    _selectedIndexPath = nil;
    _currentReloadDataLevel = 0;
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(100, 0, 1, CGRectGetHeight(self.bounds))];
    _lineView.backgroundColor = RGBCOLOR(232, 232, 232);
    _lineView.hidden = TRUE;
    _selectedLevelIndexDic = [[NSMutableDictionary alloc] init];
    [self addSubview:_lineView];
    [self collectTableViews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _lineView.height = CGRectGetHeight(self.bounds);
}

#pragma mark - private methods
- (void)collectTableViews
{
    _tableViews = [[NSMutableSet alloc] init];
    _recyleTableViews = [[NSMutableSet alloc] init];
    NSInteger index = 0;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[InfiniteTreeTableView class]]) {
            InfiniteTreeTableView *treeTableView = (InfiniteTreeTableView*)subview;
            if (0 == index) {
                treeTableView.hidden = FALSE;
                treeTableView.level = 0;
                [_tableViews addObject:treeTableView];
            }
            else {
                treeTableView.dataSource = nil;
                treeTableView.delegate = nil;
                treeTableView.level = NSNotFound;
                treeTableView.hidden = TRUE;
                [_recyleTableViews addObject:treeTableView];
            }
            index++;
        }
    }
}

- (InfiniteTreeTableView*)dequeueTableView
{
    InfiniteTreeTableView *tableView = [_recyleTableViews anyObject];
    if (tableView) {
        [_recyleTableViews removeObject:tableView];
    }
    tableView.dataSource = self;
    tableView.delegate = self;
    return tableView;
}

- (InfiniteTreeTableView*)tableViewWithLevel:(NSInteger)level
{
    InfiniteTreeTableView *foundTableView = nil;
    for (InfiniteTreeTableView *tableView in _tableViews) {
        if (tableView.level == level) {
            foundTableView = tableView;
            break;
        }
    }
    foundTableView.dataSource = self;
    foundTableView.delegate = self;
    return foundTableView;
}

- (void)updateLineView
{
    NSInteger visibleCount = [_tableViews count];
    if (visibleCount > 1) {
        _lineView.hidden = FALSE;
        [self bringSubviewToFront:_lineView];
    }
    else {
        _lineView.hidden = TRUE;
    }
}

- (void)recyleTableViews:(BOOL)push
{
    InfiniteTreeTableView *recyleTableView = nil;
    if (push) {
        if (_level >= 2) {
            recyleTableView = [self tableViewWithLevel:_level - 2];
        }
    }
    else {
        recyleTableView = [self tableViewWithLevel:_level + 1];
    }
    if (recyleTableView) {
        recyleTableView.level = NSNotFound;
        recyleTableView.hidden = TRUE;
        recyleTableView.dataSource = nil;
        recyleTableView.delegate = nil;
        [_recyleTableViews addObject:recyleTableView];
        [_tableViews removeObject:recyleTableView];
    }
    [self updateLineView];
}

- (void)applyNextAnimation:(InfiniteTreeTableView*)tableView currentLevel:(NSInteger)currentLevel
{
    CGRect frame = tableView.frame;
    frame.origin.x = 320;
    tableView.frame = frame;
    tableView.hidden = FALSE;
    
    frame.origin.x = 100;
    frame.size.width = 220;
    InfiniteTreeTableView *currentTableView = [self tableViewWithLevel:currentLevel];
    if (_animated) {
        [UIView animateWithDuration:0.3 animations:^{
            _lineView.left = 0;
            currentTableView.left = 0;
            tableView.frame = frame;
        } completion:^(BOOL finished){
            if (finished) {
                _animating = FALSE;
                _lineView.left = 100;
                [self recyleTableViews:TRUE];
            }
        }];
    }
    else {
        _animating = FALSE;
        _animated = TRUE;
        currentTableView.left = 0;
        tableView.frame = frame;
        _lineView.left = 100;
        [self recyleTableViews:TRUE];
    }
}

- (void)applyBackAnimation:(InfiniteTreeTableView*)tableView currentLevel:(NSInteger)currentLevel
{
    tableView.hidden = FALSE;
    InfiniteTreeTableView *lastTableView = [self tableViewWithLevel:currentLevel];
    if (currentLevel >= 2) {
        InfiniteTreeTableView *secondLastTableView = [self tableViewWithLevel:currentLevel - 1];
        CGRect secondFrame = secondLastTableView.frame;
        secondFrame.origin.x = 100;
        secondFrame.size.width = 220;
        [UIView animateWithDuration:0.3 animations:^{
            _lineView.left = 320;
            lastTableView.left = 320;
            secondLastTableView.frame = secondFrame;
        } completion:^(BOOL finished){
            if (finished) {
                _animating = FALSE;
                _lineView.left = 100;
                [self recyleTableViews:FALSE];
            }
        }];
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            _lineView.left = 320;
            lastTableView.left = 320;
        } completion:^(BOOL finished){
            if (finished) {
                _animating = FALSE;
                [self recyleTableViews:FALSE];
            }
        }];
    }
}

- (void)back
{
    if (!_animating) {
        
        _animating = TRUE;
        
        [self removeSelectedIndex:_level];
        NSInteger lastLevel = _level;
        NSInteger needReloadDataLevel = _level - 2;
        if (needReloadDataLevel >= 0) {
        }
        else {
            needReloadDataLevel = 0;
        }
        _currentReloadDataLevel = needReloadDataLevel;
        _level--;
        InfiniteTreeTableView *tableView = [self tableViewWithLevel:needReloadDataLevel];
        if (!tableView) {
            tableView = [self dequeueTableView];
        }
        tableView.level = needReloadDataLevel;
        NSAssert(tableView != nil, @"nil table view");
        if ([_delegate respondsToSelector:@selector(pushTreeViewWillReloadAtLevel:currentLevel:level:indexPath:)]) {
            [_delegate pushTreeViewWillReloadAtLevel:self currentLevel:lastLevel level:_currentReloadDataLevel indexPath:nil];
            
            [tableView reloadData];
            [_tableViews addObject:tableView];
            if (needReloadDataLevel <= 0) {
                tableView.frame = self.bounds;
            }
            else {
                tableView.frame = CGRectMake(0, 0, 220, CGRectGetHeight(self.bounds));
            }
            [self addSubview:tableView];
            [self sendSubviewToBack:tableView];
            [self applyBackAnimation:tableView currentLevel:lastLevel];
        }
        else {
            NSAssert(TRUE, @"pushTreeViewWillReload:previousLevel:level: not implemented");
        }
    }
}

- (void)reloadData
{
    for (InfiniteTreeTableView *pushTreeTableView in _tableViews) {
        [pushTreeTableView reloadData];
    }
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    InfiniteTreeTableView *treeTableView = [self tableViewWithLevel:_currentReloadDataLevel];
    [treeTableView deselectRowAtIndexPath:indexPath animated:animated];
}

- (void)selectedAtLevel:(NSInteger)level indexPath:(NSIndexPath*)indexPath animated:(BOOL)animated
{
    _animated = animated;
    InfiniteTreeTableView *treeTableView = [self tableViewWithLevel:_currentReloadDataLevel];
    [treeTableView.delegate tableView:treeTableView didSelectRowAtIndexPath:indexPath];
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier level:(NSInteger)level
{
    InfiniteTreeTableView *treeTableView = [self tableViewWithLevel:level];
    [treeTableView registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    InfiniteTreeTableView *treeTableView = [self tableViewWithLevel:_currentReloadDataLevel];
    return [treeTableView numberOfRowsInSection:section];
}

- (InfiniteTreeBaseCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier
{
    InfiniteTreeTableView *treeTableView = [self tableViewWithLevel:_currentReloadDataLevel];
    return [treeTableView dequeueReusableCellWithIdentifier:identifier];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    InfiniteTreeTableView *treeTableView = (InfiniteTreeTableView*)tableView;
    return [_dataSource numberOfSectionsInLevel:treeTableView.level];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    InfiniteTreeTableView *treeTableView = (InfiniteTreeTableView*)tableView;
    return [_dataSource numberOfRowsInLevel:treeTableView.level section:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InfiniteTreeTableView *treeTableView = (InfiniteTreeTableView*)tableView;
    InfiniteTreeBaseCell *cell = [_dataSource pushTreeView:self level:treeTableView.level indexPath:indexPath];
    if (_level == 0) {
        cell.width = 320;
    }
    else {
        cell.width = 220;
    }
    [cell setNeedsLayout];
    if ([self indexSelected:treeTableView.level indexPath:indexPath]) {
        [treeTableView selectRowAtIndexPath:indexPath animated:FALSE scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    InfiniteTreeTableView *treeTableView = (InfiniteTreeTableView*)tableView;
    if (_delegate && [_delegate respondsToSelector:@selector(pushTreeView:level:heightForHeaderInSection:)]) {
        return [_delegate pushTreeView:self level:treeTableView.level heightForHeaderInSection:section];
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InfiniteTreeTableView *treeTableView = (InfiniteTreeTableView*)tableView;
    if (_delegate && [_delegate respondsToSelector:@selector(pushTreeView:level:heightForRowAtIndexPath:)]) {
        return [_delegate pushTreeView:self level:treeTableView.level heightForRowAtIndexPath:indexPath];
    }
    return 55;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    InfiniteTreeTableView *treeTableView = (InfiniteTreeTableView*)tableView;
    return [_delegate pushTreeView:self level:treeTableView.level viewForHeaderInSection:section];
}

- (void)setSeletedIndexForLevel:(NSInteger)level indexPath:(NSIndexPath*)indexPath
{
    NSString *key = [NSString stringWithFormat:@"LEVEL%ld", level];
    _selectedLevelIndexDic[key] = indexPath;
}

- (void)removeSelectedIndexAfterLevel:(NSInteger)level
{
    for (NSInteger i = level + 1; i <= _level; i++) {
        [self removeSelectedIndex:i];
    }
}

- (void)removeSelectedIndex:(NSInteger)level
{
    NSString *key = [NSString stringWithFormat:@"LEVEL%ld", level];
    [_selectedLevelIndexDic removeObjectForKey:key];
}

- (BOOL)indexSelected:(NSInteger)level indexPath:(NSIndexPath*)indexPath
{
    NSString *key = [NSString stringWithFormat:@"LEVEL%ld", level];
    NSIndexPath *selectedIndexPath = _selectedLevelIndexDic[key];
    if (selectedIndexPath && selectedIndexPath.section == indexPath.section &&
        selectedIndexPath.row == indexPath.row) {
        return TRUE;
    }
    return FALSE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InfiniteTreeTableView *treeTableView = (InfiniteTreeTableView*)tableView;
    if (_delegate && [_delegate respondsToSelector:@selector(pushTreeView:didSelectedLevel:indexPath:)]) {
        [_delegate pushTreeView:self didSelectedLevel:treeTableView.level indexPath:indexPath];
    }
    [self setSeletedIndexForLevel:treeTableView.level indexPath:indexPath];
    BOOL hasNext = FALSE;
    if (_delegate && [_delegate respondsToSelector:@selector(pushTreeViewHasNextLevel:currentLevel:indexPath:)]) {
        hasNext = [_delegate pushTreeViewHasNextLevel:self currentLevel:treeTableView.level indexPath:indexPath];
    }
    if (hasNext) {
        
        _animating = TRUE;
        
        NSInteger currentNeedReloadLevel = treeTableView.level;
        if ([_delegate respondsToSelector:@selector(pushTreeViewWillReloadAtLevel:currentLevel:level:indexPath:)]) {
            [self removeSelectedIndexAfterLevel:currentNeedReloadLevel];            
            if (_selectedLevel == currentNeedReloadLevel) {
                if (!SAME_INDEXPATH(_selectedIndexPath, indexPath)) {
                    _currentReloadDataLevel = treeTableView.level + 1;
                    [_delegate pushTreeViewWillReloadAtLevel:self currentLevel:treeTableView.level level:_currentReloadDataLevel indexPath:indexPath];
                    InfiniteTreeTableView *tableView = [self tableViewWithLevel:_currentReloadDataLevel];
                    [tableView reloadData];
                    if (!tableView) {
                        _level++;
                        tableView = [self dequeueTableView];
                        tableView.level = _currentReloadDataLevel;
                        [tableView reloadData];
                        [_tableViews addObject:tableView];
                        tableView.frame = CGRectMake(0, 0, 220, CGRectGetHeight(self.bounds));
                        [self applyNextAnimation:tableView currentLevel:_currentReloadDataLevel - 1];
                    }
                }
                else {
                    _currentReloadDataLevel = treeTableView.level + 1;
                    [_delegate pushTreeViewWillReloadAtLevel:self currentLevel:treeTableView.level level:_currentReloadDataLevel indexPath:indexPath];
                    InfiniteTreeTableView *tableView = [self tableViewWithLevel:_currentReloadDataLevel];
                    if (!tableView) {
                        _level++;
                        tableView = [self dequeueTableView];
                        NSAssert(tableView != nil, @"nil table view");                        
                        tableView.level = _currentReloadDataLevel;
                        [tableView reloadData];
                        [_tableViews addObject:tableView];
                        tableView.frame = CGRectMake(0, 0, 220, CGRectGetHeight(self.bounds));
                        [self addSubview:tableView];
                        [self applyNextAnimation:tableView currentLevel:_level - 1];
                    }
                }
            }
            else {
                if (currentNeedReloadLevel > _selectedLevel || _selectedLevel == NSNotFound) {
                    _level++;
                    _currentReloadDataLevel = treeTableView.level + 1;
                    NSInteger currentLevel = _selectedLevel;
                    if (_selectedLevel == NSNotFound) {
                        currentLevel = 0;
                    }
                    [_delegate pushTreeViewWillReloadAtLevel:self currentLevel:treeTableView.level level:_currentReloadDataLevel indexPath:indexPath];
                    InfiniteTreeTableView *tableView = [self tableViewWithLevel:_currentReloadDataLevel];
                    if (!tableView) {
                        tableView = [self dequeueTableView];
                    }
                    NSAssert(tableView != nil, @"nil table view");
                    tableView.level = _currentReloadDataLevel;
                    [tableView reloadData];
                    [_tableViews addObject:tableView];
                    [self addSubview:tableView];
                    [self applyNextAnimation:tableView currentLevel:_currentReloadDataLevel - 1];
                }
                else {
                    _currentReloadDataLevel = treeTableView.level + 1;
                    [_delegate pushTreeViewWillReloadAtLevel:self currentLevel:treeTableView.level level:_currentReloadDataLevel indexPath:indexPath];
                    InfiniteTreeTableView *tableView = [self tableViewWithLevel:_currentReloadDataLevel];
                    [tableView reloadData];
                    if (!tableView) {
                        _level++;
                        tableView = [self dequeueTableView];
                        tableView.level = _currentReloadDataLevel;
                        [tableView reloadData];
                        [_tableViews addObject:tableView];
                        tableView.frame = CGRectMake(0, 0, 220, CGRectGetHeight(self.bounds));
                        [self applyNextAnimation:tableView currentLevel:_currentReloadDataLevel - 1];
                    }
                    NSAssert(tableView != nil, @"nil table view");
                }
            }
            _selectedIndexPath = indexPath;
            _selectedLevel = treeTableView.level;
        }
        else {
            NSAssert(TRUE, @"pushTreeViewWillReload:previousLevel:level: not implemented");
        }
    }
}
@end
