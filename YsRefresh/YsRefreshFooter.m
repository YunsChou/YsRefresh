//
//  YsRefreshFooter.m
//  YsRefresh
//
//  Created by weiying on 16/2/3.
//  Copyright © 2016年 Yuns. All rights reserved.
//

#import "YsRefreshFooter.h"

@implementation YsRefreshFooter
{
    CGFloat _scrollContentHeight;
    CGFloat _scrollFrameHeight;
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
        refreshView.hidden = YES;
        refreshView.backgroundColor = [UIColor yellowColor];
        [scrollView addSubview:refreshView];
        _refreshView = refreshView;
        
        UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake((refreshViewW - refreshLabelW)/2, 0, refreshLabelW, refreshLabelH)];
        refreshLabel.text = labelTextUp;
        refreshLabel.textAlignment = NSTextAlignmentCenter;
        [refreshView addSubview:refreshLabel];
        _refreshLabel = refreshLabel;
        
        UIImageView *refreshImgV = [[UIImageView alloc] initWithFrame:CGRectMake((refreshViewW - refreshLabelW)/2 - refreshImgVWH, 0, refreshImgVWH, refreshImgVWH)];
        refreshImgV.contentMode = UIViewContentModeCenter;
        refreshImgV.image = [UIImage imageNamed:@"YsRefreshArrow"];
        refreshImgV.transform = CGAffineTransformMakeRotation(M_PI);
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

/**上拉加载业务逻辑（默认触发上拉加载高度为刷新头部高度==40，上拉加载偏移量Y的值为正数）
 //一、正在拖拽 --
 //A、当前scroll的content高度 小于 scroll的frame高度
 * 1、将refreshview的Y值设为scroll的frame底部
 * 2、Y <= 0：这时refreshview还没出现，提示“上拉加载”状态
 * 3、0 < Y <= 40：这时refreshview出现一部分，提示“上拉加载”状态
 * 4、Y > 40：这时refreshview全部出现，提示“松开刷新”状态
 //B、当前scroll的content高度 大于 scroll的frame高度
 * 1、将refreshview的Y值设为scroll的content底部
 * 2、Y <= scroll的content高度 - scroll的frame高度：这时refreshview还没出现，提示“上拉加载”状态
 * 3、scroll的content高度 - scroll的frame高度 < Y <= scroll的content高度 - scroll的frame高度 + 40：这时refreshview出现一部分，提示“上拉加载”状态
 * 4、Y > scroll的content高度 - scroll的frame高度 + 40：这时refreshview全部出现，提示“松开刷新”状态
  *****综合2、3、4，如果不是“松开刷新”状态，就是“上拉加载”状态*****
 //二、正在刷新 --
 * 5、如果是“正在刷新...”状态，不触发2、3、4
 //三、停止拖拽 --
 * 6、停止拖拽，判断label上的文字，如果是“松开刷新”，触发刷新事件
 //注意：开始刷新时_scrollView.contentInset也搞根据条件进行设置
 */

//当属性的值发生变化时，自动调用此方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([@"contentOffset" isEqualToString:keyPath]) {
        if (_scrollView.isDragging) {
            if (!_isRefreshing) {
                _refreshView.hidden = NO;
                _scrollFrameHeight = _scrollView.frame.size.height;
                _scrollContentHeight = _scrollView.contentSize.height;
                CGFloat scrollViewW = _scrollView.frame.size.width;
                CGFloat currentPostionY = _scrollView.contentOffset.y;
                
                if (_scrollContentHeight < _scrollFrameHeight) {
                    _refreshView.frame = CGRectMake(0, _scrollFrameHeight, scrollViewW, refreshViewHeight);
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        if (currentPostionY > refreshViewHeight) {
                            _refreshLabel.text = labelTextLosen;
                            _refreshImgV.transform = CGAffineTransformMakeRotation(M_PI);
                        }else{
                            _refreshLabel.text = labelTextUp;
                        }
                    }];
                }else{
                    _refreshView.frame = CGRectMake(0, _scrollContentHeight, scrollViewW, refreshViewHeight);
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        if (currentPostionY > _scrollContentHeight - _scrollFrameHeight + refreshViewHeight) {
                            _refreshLabel.text = labelTextLosen;
                            _refreshImgV.transform = CGAffineTransformMakeRotation(M_PI);
                        }else{
                            _refreshLabel.text = labelTextUp;
                        }
                    }];
                }
            }
        }else{
            if ([_refreshLabel.text isEqualToString:labelTextLosen]) {
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
            if (_scrollContentHeight < _scrollFrameHeight) {
                _scrollView.contentInset = UIEdgeInsetsMake(- refreshViewHeight, 0, 0, 0);
            }else{
                _scrollView.contentInset = UIEdgeInsetsMake(0, 0, refreshViewHeight, 0);
            }
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
        _refreshView.hidden = YES;
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _refreshLabel.text = labelTextUp;
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
