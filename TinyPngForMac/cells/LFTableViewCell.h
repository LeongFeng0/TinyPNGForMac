//
//  LFTableViewCell.h
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/17.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LFTableViewCell : NSView
@property (nonatomic, strong) NSString *saveFilePath;
-(id)initWithFrame:(NSRect)frame withImagePath:(NSString *)path;
@end
