//
//  SettingViewController.m
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/27.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import "SettingViewController.h"
#import "LFSettingManager.h"
#import "HelpViewController.h"
@interface SettingViewController ()
{
    LFSettingManager * _manager;
    NSString *_apiKey;
    NSString *_saveImagePath;
}
@property (nonatomic ,strong) HelpViewController * helpViewController;
@property(nonatomic,strong) NSPopover *popover;
@end
@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _manager = [LFSettingManager share];
    
    //输入监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(apiInputContextDidChange) name:NSControlTextDidChangeNotification object:_apiInputTextField];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(savePathContextDidChange) name:NSControlTextDidChangeNotification object:_savePathIntpuTextField];
  
}
/**
 选择图片保存路径
 ***/
- (IBAction)selectSaveImagesFolder:(id)sender {
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
            _savePathIntpuTextField.stringValue = pathString;
            _saveImagePath = pathString;
            [_manager setSaveImagePath:pathString];
            //存储沙盒以外的文件夹读写权限
            [_manager  saveBookmarkDataToUserDefaultWithURL:[panel URL]];
            
        }
        
    }];
    
}
//输入监听
-(void)savePathContextDidChange{
    NSLog(@"%@",_savePathIntpuTextField.stringValue);
    _saveImagePath = _savePathIntpuTextField.stringValue;
    [_manager setSaveImagePath:_saveImagePath];
}
-(void)apiInputContextDidChange{
    NSLog(@"%@",_apiInputTextField.stringValue);
    _apiKey = _apiInputTextField.stringValue;
    [_manager setAPIKey:_apiKey];
}

/***
 跳转到官方网站申请API
 ***/
- (IBAction)applyApiButton:(id)sender {
    NSWorkspace *workspace = [[NSWorkspace alloc]init];
    [workspace openURL:[NSURL URLWithString:@"https://tinypng.com/developers"]];
}
- (IBAction)showHelpView:(id)sender {
    [self.popover showRelativeToRect:[_helpButton bounds] ofView:_helpButton preferredEdge:NSRectEdgeMaxY];
}

- (IBAction)finishedSettingButton:(id)sender {
    if (_apiKey == nil || _saveImagePath == nil || [_apiKey isEqualToString: @""] || [_saveImagePath isEqualToString: @""]) {
        NSLog(@"api or path is nil:%@--%@",_apiKey,_saveImagePath);
        return;
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:1.5];
    [[self.view animator] removeFromSuperview];
    [NSAnimationContext endGrouping];
    [self removeFromParentViewController];
}
/***
 懒加载
 ***/
- (NSPopover *)popover
{
    if(!_popover)
    {
        _popover=[[NSPopover alloc]init];
        _popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        _popover.contentViewController = self.helpViewController;
        _popover.behavior = NSPopoverBehaviorTransient;
        
    }
    return _popover;
}

- (HelpViewController *)helpViewController
{
    if(!_helpViewController)
    {
        _helpViewController=[[HelpViewController alloc]init];
    }
    return _helpViewController;
}

@end
