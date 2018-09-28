//
//  DragDropImageView.h
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/17.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol DragDropImageViewDelegate;

@interface DragDropImageView : NSImageView
@property (nonatomic, weak) id<DragDropImageViewDelegate> delegate;
@end

@protocol DragDropImageViewDelegate <NSObject>
-(void)dragDropViewFileList:(NSArray*)fileList;
@end
