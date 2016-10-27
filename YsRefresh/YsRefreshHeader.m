//
//  YsRefreshHeader.m
//  YsRefresh
//
//  Created by weiying on 16/2/3.
//  Copyright © 2016年 Yuns. All rights reserved.
//

#import "YsRefreshHeader.h"

@implementation YsRefreshHeader
{
    refreshBlock _refreshBlock;
    BOOL _isRefreshing;
    UIScrollView *_scrollView;
    UIView *_refreshView;
    UILabel *_refreshLabel;
    UIImageView *_refreshImgV;
    UIActivityIndicatorView *_activityView;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView refreshBlock:(refreshBlock)refreshBlock
{
    self = [super init];
    if (self) {
        //初始化
        _refreshBlock = refreshBlock;
        _isRefreshing = NO;
        _scrollView = scrollView;
        
        CGFloat scrollViewW = scrollView.frame.size.width;
        CGFloat refreshViewW = scrollViewW;
        CGFloat refreshViewH = refreshViewHeight;
        CGFloat refreshLabelW = refreshLabelWidth;
        CGFloat refreshLabelH = refreshViewH;
        CGFloat refreshImgVWH = refreshViewH;
        
        //添加头部刷新视图
        UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, - refreshViewH, refreshViewW, refreshViewH)];
        refreshView.backgroundColor = [UIColor cyanColor];
        [scrollView addSubview:refreshView];
        _refreshView = refreshView;
        
        UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake((refreshViewW - refreshLabelW)/2, 0, refreshLabelW, refreshLabelH)];
        refreshLabel.text = labelTextDown;
        refreshLabel.textAlignment = NSTextAlignmentCenter;
        [refreshView addSubview:refreshLabel];
        _refreshLabel = refreshLabel;
        
        UIImageView *refreshImgV = [[UIImageView alloc] initWithFrame:CGRectMake((refreshViewW - refreshLabelW)/2 - refreshImgVWH, 0, refreshImgVWH, refreshImgVWH)];
        refreshImgV.contentMode = UIViewContentModeCenter;
        refreshImgV.image = [UIImage imageNamed:@"YsRefreshArrow"];
        [refreshView addSubview:refreshImgV];
        _refreshImgV = refreshImgV;
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake((refreshViewW - refreshLabelW)/2 - refreshImgVWH, 0, refreshImgVWH, refreshImgVWH);
        [refreshView addSubview:activityView];
        _activityView = activityView;
        
        //添加scrollView观察者
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

/**下拉刷新业务逻辑（默认触发下拉刷新高度为刷新头部高度==40，下拉刷新偏移量Y的值为负数）
 //一、正在拖拽 --
 * 1、Y >= 0：这时refreshview还没出现，提示“下拉刷新”状态
 * 2、-40 < Y < 0：这时refreshview出现一部分，提示“下拉刷新”状态
 * 3、Y < -40：这时refreshview全部出现，提示“松开刷新”状态
 *****综合1、2、3，如果不是“松开刷新”状态，就是“下拉刷新”状态*****
 //二、正在刷新 --
 * 4、如果是“正在刷新...”状态，不触发1、2、3
 //三、停止拖拽 --
 * 5、停止拖拽，判断label上的文字，如果是“松开刷新”，触发刷新事件
 */

//当属性的值发生变化时，自动调用此方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([@"contentOffset" isEqualToString:keyPath]) {
        if (_scrollView.isDragging) {//一
            if (!_isRefreshing) {//二 （！4）
                CGFloat currentPostionY = _scrollView.contentOffset.y;
                [UIView animateWithDuration:0.3 animations:^{
                    if (currentPostionY < - refreshViewHeight) {//3
                        _refreshLabel.text = labelTextLosen;
                        _refreshImgV.transform = CGAffineTransformMakeRotation(M_PI);
                    }else{//1、2
                        _refreshLabel.text = labelTextDown;
                        _refreshImgV.transform = CGAffineTransformMakeRotation(M_PI * 2);
                    }
                }];
            }
        }else{//三
            if ([_refreshLabel.text isEqualToString:labelTextLosen]) {//5
                [self beginRefresh];
            }
        }
    }
}

//开始刷新，如果正在刷新不做操作
- (void)beginRefresh
{
    if (!_isRefreshing) {
        _isRefreshing = YES;
        _refreshLabel.text = labelTextRefresh;
        _refreshImgV.hidden = YES;
        [_activityView startAnimating];

        [UIView animateWithDuration:0.3 animations:^{
            _scrollView.contentInset = UIEdgeInsetsMake(refreshViewHeight, 0, 0, 0);
        }];

        if (_refreshBlock) {
            _refreshBlock();
        }
    }
}

//关闭刷新操作
- (void)endRefresh
{
    [UIView animateWithDuration:0.3 animations:^{
        _isRefreshing = NO;
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _refreshLabel.text = labelTextDown;
        _refreshImgV.transform = CGAffineTransformMakeRotation(M_PI * 2);
        _refreshImgV.hidden = NO;
        [_activityView stopAnimating];
    }];
}

- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

@end
