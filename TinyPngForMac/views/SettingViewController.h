//
//  SettingViewController.h
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/27.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingViewController : NSViewController
@property (weak) IBOutlet NSTextField *apiInputTextField;
@property (weak) IBOutlet NSTextField *savePathIntpuTextField;
@property (weak) IBOutlet NSButton *helpButton;

@end
