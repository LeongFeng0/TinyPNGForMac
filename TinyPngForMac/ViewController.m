//
//  ViewController.m
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/17.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import "ViewController.h"
#import "LFTableViewCell.h"
#import "ButtomContentView.h"
#import "LFSettingManager.h"
#import "SettingViewController.h"
@interface ViewController()<NSTableViewDelegate,NSTableViewDataSource>

@end
@implementation ViewController
{
    NSTableView * _tableView;
    NSMutableArray * _dataArray;
    NSString * _saveFilePath;
    ButtomContentView * _buttomView;
    LFSettingManager *_manager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = DefaultBackgroundColor_CG;
    // Do any additional setup after loading the view.
    //接收拖拽的视图
    self.dragDropIamgeView = [[DragDropImageView alloc]init];
    self.dragDropIamgeView.wantsLayer = YES;
    self.dragDropIamgeView.layer.backgroundColor = DefaultColor;
    self.dragDropIamgeView.frame = CGRectMake(0, 0, 350, 350);
    self.dragDropIamgeView.delegate = self;
    [self.view addSubview:self.dragDropIamgeView];
   
    //底部工具栏
    NSView * toolBar = [[NSView alloc]initWithFrame:CGRectMake(0, 300, 350, 50)];
    toolBar.wantsLayer = YES;
    toolBar.layer.backgroundColor = DefaultColor;
    [self.view addSubview:toolBar];
    [toolBar addSubview:_settingButton];
    [toolBar addSubview:_openFolderButton];
    [toolBar addSubview:_tasksDetailTextField];
    NSShadow *shadow = [[NSShadow alloc]init];
    shadow.shadowBlurRadius = 2.0;
    [shadow setShadowOffset:NSMakeSize(0, -8)];
    [toolBar setShadow:shadow];
    
    //开启保存图片文件夹的读写权限
    _manager = [LFSettingManager share];
    [_manager getDownloadDirectorySecurityScoped];
    
    //如果没有API 和保存路径则显示
    if ([_manager getSaveImagePath] ==nil || [_manager getAPIKey] ==nil || [[_manager getSaveImagePath] isEqualToString:@""] || [[_manager getAPIKey] isEqualToString:@""]) {
        SettingViewController *settingView = [[SettingViewController alloc]init];
        settingView.view.frame = CGRectMake(0, 0, 350, 350);
        [self addChildViewController:settingView];
        [self.view addSubview: settingView.view];
    
    }
    
    //KVO
    [_manager addObserver:self forKeyPath:@"allTasksOfSize" options:NSKeyValueObservingOptionNew context:nil];
    [_manager addObserver:self forKeyPath:@"compressionOfSize" options:NSKeyValueObservingOptionNew context:nil];
    
}

//当key路径对应的属性值发生改变时
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)contex{
    NSLog(@"keyPath:%@---new:%@",keyPath,[change objectForKey:@"new"]);
    if ([keyPath isEqualToString:@"allTasksOfSize"]) {
        _tasksDetailTextField.stringValue = [NSString stringWithFormat:@"%ld个任务，共%.2fM，压缩后0M",(long)_manager.tasksCount,_manager.allTasksOfSize];
    }
    if ([keyPath isEqualToString:@"compressionOfSize"]) {
        _tasksDetailTextField.stringValue = [NSString stringWithFormat:@"%ld个任务，共%.2fM，压缩后%.2fM",_manager.tasksCount,_manager.allTasksOfSize,_manager.compressionOfSize/1000.0];
    }
}


//settingbutton click
- (IBAction)buttomBarSettingButtonClick:(id)sender {
    [self showButtomContentView];
}
//open download path
- (IBAction)openDownloadImagesFolder:(id)sender {
    NSString *path = [_manager getSaveImagePath];
    NSWorkspace *workspace = [[NSWorkspace alloc]init];
    [workspace openFile:path];
}


/***
 创建底部视图
 ***/
-(void)showButtomContentView{
    if (self.view.window.frame.size.height == 450) {
         [self.view.window setFrame:CGRectMake(self.view.window.frame.origin.x, self.view.window.frame.origin.y+100, 350, 350) display:NO animate:YES];
        [_buttomView.view removeFromSuperview];
    }else {
         [self.view.window setFrame:CGRectMake(self.view.window.frame.origin.x, self.view.window.frame.origin.y-100, 350, 450) display:NO animate:YES];
        
        if (_buttomView == nil) {
            _buttomView = [[ButtomContentView alloc]init];
        }
        _buttomView.view.frame = CGRectMake(0, 350, 350, 100);
        [self.view addSubview:_buttomView.view positioned:NSWindowBelow relativeTo:self.dragDropIamgeView];
    }
    
}
/***
 实现dragdropview的代理函数，如果有数据返回就会触发这个函数
 ***/
-(void)dragDropViewFileList:(NSArray *)fileList{
    
    if(!fileList || [fileList count] <= 0)return;
    //输出所有的链接
    for (int n = 0 ; n < [fileList count] ; n++) {
        NSLog(@">>> %@",[fileList objectAtIndex:n]);
    }
    
    //创建列表
    [self createPicturesTableView:fileList];
    

}

-(void)createPicturesTableView:(NSArray *)fileList{
    if (_tableView != nil) {
        [_dataArray addObjectsFromArray:fileList];
        [_tableView reloadData];
        return ;
    }
    
    NSView *content = [[NSView alloc]initWithFrame:CGRectMake(0, 0, 350, 22)];
    content.wantsLayer = YES;
    content.layer.backgroundColor = DefaultColor;
    [self.view addSubview:content];
    _dataArray = [NSMutableArray array];
    [_dataArray addObjectsFromArray:fileList];
    NSScrollView *scrollView = [[NSScrollView alloc]init];
    scrollView.frame = CGRectMake(0, 22, 350, 300-10);
    scrollView.hasVerticalScroller = NO;
    scrollView.hasHorizontalRuler = NO;
    [self.view addSubview:scrollView];
    _tableView = [[NSTableView alloc]init];
    _tableView.frame = CGRectMake(0, 0, 350, 300-10);
    _tableView.backgroundColor = DefaultColor_CG;
    NSTableColumn * column = [[NSTableColumn alloc]initWithIdentifier:@"tableColumn"];
    column.width =self.view.bounds.size.width-10;
    _tableView.headerView = [[NSTableHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    [_tableView addTableColumn:column];
    
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView reloadData];
    scrollView.contentView.documentView = _tableView;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    return NO;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _dataArray.count;
}

//设置元素的具体视图
- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row{
    //根据ID取视图
    LFTableViewCell * view = [tableView makeViewWithIdentifier:@"cellId" owner:self];
    if (view==nil) {
        //自定义单元格
        view = [[LFTableViewCell alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 70) withImagePath:_dataArray[row]];
        view.identifier = @"cellId";
        //保存路径
        _saveFilePath = [_manager getSaveImagePath];
        view.saveFilePath = _saveFilePath;
    }
    return view;
}
-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 70;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
