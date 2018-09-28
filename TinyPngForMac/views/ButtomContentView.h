//
//  ButtomContentView.h
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/25.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ButtomContentView : NSViewController
@property (weak) IBOutlet NSTextField *apiKeyInputTextField;
@property (weak) IBOutlet NSTextField *saveImagePathInputTextField;
@property (weak) IBOutlet NSTextField *compressionCountText;

@end
