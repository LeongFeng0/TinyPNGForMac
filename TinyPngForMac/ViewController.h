//
//  ViewController.h
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/17.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragDropImageView.h"
@interface ViewController : NSViewController <DragDropImageViewDelegate>

@property (nonatomic, strong) DragDropImageView * dragDropIamgeView;
@property (weak) IBOutlet NSButton *settingButton;
@property (weak) IBOutlet NSButton *openFolderButton;
@property (weak) IBOutlet NSTextField *tasksDetailTextField;

@end

