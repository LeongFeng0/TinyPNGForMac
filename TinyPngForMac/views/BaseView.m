//
//  BaseView.m
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/25.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
//改变坐标系方向
-(BOOL)isFlipped{
    return YES;
}

@end
