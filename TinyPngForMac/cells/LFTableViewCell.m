//
//  LFTableViewCell.m
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/17.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import "LFTableViewCell.h"
#import "AFNetworking.h"
#import "LFSettingManager.h"
@implementation LFTableViewCell
{
    NSProgressIndicator * _progressBar;
    NSText * _sizeText;
    NSText * _compressedSize;
    NSText * _percentageText;
    NSDictionary * _output;
    NSButton * _retryBtn;
    LFSettingManager *_manager;
    NSString *_path;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(id)initWithFrame:(NSRect)frame withImagePath:(NSString *)path{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUIWithImagePath:path];
    }
    return self;
}
-(void)createUIWithImagePath:(NSString *)path{
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor clearColor].CGColor;
    NSImageView *img = [[NSImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
    img.image = [[NSImage alloc]initWithContentsOfFile:path];
    
    //根据路径获取图片文件名
    NSText *name = [[NSText alloc]initWithFrame:CGRectMake(75, 45, 250, 15)];
    NSString *str = [[path componentsSeparatedByString:@"/"] lastObject];
    if (str.length > 23) {
      str = [NSString stringWithFormat:@"%@...",[str substringToIndex:22]];
    }
    name.string = str;
    name.font = [NSFont systemFontOfSize:15];
    name.backgroundColor = [NSColor clearColor];
    name.textColor = [NSColor whiteColor];
    name.editable = NO;
    
    
    //统计
    _manager = [LFSettingManager share];
    _manager.tasksCount += 1;

    //图片大小
    NSText * sizeText = [[NSText alloc]initWithFrame:CGRectMake(75, 20, 70, 12)];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        float size = [[fileManager attributesOfItemAtPath:path error:nil] fileSize]/1000.0;
        _manager.allTasksOfSize += size/1000.0;
        
        if (size > 1000.0) {
          sizeText.string =[NSString stringWithFormat:@"%.1f MB",size/1000.0];
        }else {
          sizeText.string =[NSString stringWithFormat:@"%.1f KB",size];
        }
    }
    sizeText.font = [NSFont systemFontOfSize:12];
    sizeText.textColor = DefaultTextColor;
    sizeText.backgroundColor  = [NSColor clearColor];
    sizeText.editable = NO;
    _sizeText = sizeText;

    
    //压缩后的大小
    NSText *compressedSize = [[NSText alloc]initWithFrame:CGRectMake(255, 20, 90, 12)];
    compressedSize.string = @"uploading";
    compressedSize.textColor = DefaultTextColor;
    compressedSize.font = [NSFont systemFontOfSize:12];
    compressedSize.backgroundColor = [NSColor clearColor];
    compressedSize.editable = NO;
    _compressedSize = compressedSize;
    
    //进度条
    NSProgressIndicator *progressBar = [[NSProgressIndicator alloc]initWithFrame:CGRectMake(145, 17, 100, 20)];
    progressBar.style = NSProgressIndicatorBarStyle;
    [progressBar setUsesThreadedAnimation:YES];
    progressBar.indeterminate = NO;
    progressBar.minValue = 0.0;
    progressBar.maxValue = 1.0;
    [progressBar setDoubleValue:0.0];
    [progressBar startAnimation: nil];
    _progressBar = progressBar;
    
    //百分比
    NSText * percentageText = [[NSText alloc]initWithFrame:CGRectMake(275, 47, 85, 16)];
    percentageText.string = @"";
    percentageText.font = [NSFont systemFontOfSize:16 weight:700];
    percentageText.editable = NO;
    percentageText.backgroundColor = [NSColor clearColor];
    _percentageText = percentageText;
    
    [self addSubview:progressBar];
    [self addSubview:compressedSize];
    [self addSubview:sizeText];
    [self addSubview:name];
    [self addSubview:img];
    [self addSubview:percentageText];
    
    //上传图片压缩
    [self upLoadImageWith:path withName:[[path componentsSeparatedByString:@"/"] lastObject]];
}
/***
 上传图片压缩处理
 ***/
-(void)upLoadImageWith:(NSString *)path withName:(NSString *)name{
    _path = path;
    AFHTTPRequestSerializer * serializer = [AFHTTPRequestSerializer serializer];
   
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:BaseURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //[formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"file" fileName:name mimeType:@"image/jpeg" error:nil];
    } error:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [request setHTTPBody:data];
    
    //设置HTTPHeader中Content-Type的值
    [request setValue:@"multipart/form-data"
   forHTTPHeaderField:@"Content-Type"];
    
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[data length]]
   forHTTPHeaderField:@"Content-Length"];
    
    // 设置Authorization的方法设置header
    _manager = [LFSettingManager share];
    NSString *api =  [_manager getAPIKey];
    NSString * apikey =[NSString stringWithFormat:@"api:%@",api];
    NSData *encodeData = [apikey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
    NSString * authorization = [NSString stringWithFormat:@"Basic %@",base64String];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          NSLog(@"%f",uploadProgress.fractionCompleted);
                          [_progressBar setDoubleValue:uploadProgress.fractionCompleted];
                          if (uploadProgress.fractionCompleted == 1.000000) {
                              _compressedSize.string = @"compressing";
                          }
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                          _compressedSize.string = @"failed";
                          _compressedSize.textColor = [NSColor redColor];
                          [self taskError];
                      } else {
                          [_progressBar setDoubleValue:1.0];
                          _compressedSize.string = @"compressing";
                          //获取API 已经使用次数
                          NSLog(@"%@",[(NSHTTPURLResponse *)response allHeaderFields][@"compression-count"]);
                         
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"compression-count" object:nil userInfo:@{@"count":[(NSHTTPURLResponse *)response allHeaderFields][@"compression-count"]}];
                          
                          //图片压缩后的信息
                          NSLog(@"%@", responseObject);
                          NSDictionary * output = responseObject[@"output"];
                          _output = output;
                          NSDictionary * input = responseObject[@"input"];
                          _manager.compressionOfSize += [output[@"size"] floatValue]/1000.0;
                          double percent = ([input[@"size"] doubleValue] - [output[@"size"] doubleValue])*100/[input[@"size"] doubleValue] ;
                          _percentageText.string = [NSString stringWithFormat:@"-%.1lf%%",percent];
                          [self downLoadImageWithURLString:_output[@"url"] withFileName:name];
                      }
                      
                  }];

    [uploadTask resume];
    
    
}
/***
 下载图片
 ***/
-(void)downLoadImageWithURLString:(NSString *)url withFileName:(NSString *)name{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            NSLog(@"%f",downloadProgress.fractionCompleted);
            [_progressBar setDoubleValue:downloadProgress.fractionCompleted];
            if (downloadProgress.fractionCompleted == 1.000000) {
                
                if ([_output[@"size"] doubleValue] > 1000.0) {
                    _compressedSize.string =[NSString stringWithFormat:@"%.1f KB",[_output[@"size"] doubleValue]/1000.0];
                }
                
            }else {
                _compressedSize.string = @"downloading";
            }
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //保存到指定位置
        // NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL * documentsDirectoryURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_saveFilePath]];
        
        return [documentsDirectoryURL URLByAppendingPathComponent:name];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
       
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
}
/***
 失败重试
 ***/
-(void)taskError{
    _retryBtn = [NSButton buttonWithTitle:@"Retry" target:self action:@selector(taskRetry)];
    _retryBtn.frame = CGRectMake(280, 40, 60, 25);
    [self addSubview:_retryBtn];
}

-(void)taskRetry{
    NSLog(@"任务重试");
    _compressedSize.string = @"uploading";
    _compressedSize.textColor = DefaultTextColor;
    [_retryBtn removeFromSuperview];
    _retryBtn = nil;
    [self upLoadImageWith:_path withName:[[_path componentsSeparatedByString:@"/"] lastObject]];
}
@end
