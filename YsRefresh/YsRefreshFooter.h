//
//  YsRefreshFooter.h
//  YsRefresh
//
//  Created by weiying on 16/2/3.
//  Copyright © 2016年 Yuns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YsRefresh.h"

typedef void(^refreshBlock)();

@interface YsRefreshFooter : UIView

- (instancetype)initWithScrollView:(UIScrollView *)scrollView refreshBlock:(refreshBlock)refreshBlock;

//开始刷新，如果正在刷新不做操作
- (void)beginRefresh;
//关闭刷新操作
- (void)endRefresh;

@end
