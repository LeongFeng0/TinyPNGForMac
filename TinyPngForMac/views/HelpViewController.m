//
//  HelpViewController.m
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/27.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)openTintPNGWeb:(id)sender {
    NSWorkspace *workspace = [[NSWorkspace alloc]init];
    [workspace openURL:[NSURL URLWithString:@"https://tinypng.com"]];
}

@end
