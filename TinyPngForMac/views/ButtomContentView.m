//
//  ButtomContentView.m
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/25.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import "ButtomContentView.h"
#import "LFSettingManager.h"
@interface ButtomContentView ()
{
    LFSettingManager *_manager;
}
@end

@implementation ButtomContentView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _manager = [LFSettingManager share];
    
    if ([_manager getAPIKey]) {
       _apiKeyInputTextField.stringValue = [_manager getAPIKey];
    }
    
    if ([_manager getSaveImagePath]) {
        _saveImagePathInputTextField.stringValue = [_manager getSaveImagePath];
    }
    
    if ([_manager getCompressionCount]) {
        _compressionCountText.stringValue = [NSString stringWithFormat:@"%@/500",[_manager getCompressionCount]];
    }
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"compression-count" object:nil];
    
    
}
-(void)receiveNotification:(NSNotification *)infoNotification {
    NSDictionary *dic = [infoNotification userInfo];
    NSString *count = [dic objectForKey:@"count"];
    _compressionCountText.stringValue = [NSString stringWithFormat:@"%@/500",count];
    [_manager saveCompressionCount:count];
}

- (IBAction)selectSaveImagePath:(id)sender {
    
     NSOpenPanel* panel = [NSOpenPanel openPanel];
     //是否可以创建文件夹
     panel.canCreateDirectories = YES;
     //是否可以选择文件夹
     panel.canChooseDirectories = YES;
     //是否可以选择文件
     panel.canChooseFiles = NO;
     
     //是否可以多选
     [panel setAllowsMultipleSelection:NO];
     
     //显示
     [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
     
     //是否点击open 按钮
     if (result == NSModalResponseOK) {
     //NSURL *pathUrl = [panel URL];
         NSString *pathString = [panel.URLs.firstObject path];
         NSLog(@"%@",pathString);
         _saveImagePathInputTextField.stringValue = pathString;
         [_manager setSaveImagePath:pathString];
         //存储沙盒以外的文件夹读写权限
         [_manager  saveBookmarkDataToUserDefaultWithURL:[panel URL]];
         
     }
     
     
     }];
     
}
- (IBAction)apiKeyInput:(id)sender {
    NSLog(@"%@",((NSTextField *)sender).stringValue);
    NSString *api = ((NSTextField *)sender).stringValue;
    [_manager setAPIKey:api];
}
- (IBAction)savePathInput:(id)sender {
    NSLog(@"%@",((NSTextField *)sender).stringValue);
    NSString *path = ((NSTextField *)sender).stringValue;
    [_manager setSaveImagePath:path];
}
- (IBAction)applyNewApiKey:(id)sender {
    NSWorkspace *workspace = [[NSWorkspace alloc]init];
    [workspace openURL:[NSURL URLWithString:@"https://tinypng.com/developers"]];
}

@end
