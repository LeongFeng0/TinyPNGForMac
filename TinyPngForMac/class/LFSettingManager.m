//
//  LFSettingManager.m
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/25.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import "LFSettingManager.h"

static LFSettingManager * _settingManager;

@implementation LFSettingManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_settingManager == nil) {
            _settingManager = [super allocWithZone:zone];
        }
    });
    return _settingManager;
}
+ (instancetype)share{
    
    return  [[self alloc] init];
}
-(void)setAPIKey:(NSString *)key{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:key forKey:@"api_key"];
    [userDefault synchronize];
    NSLog(@"saveApiKey_success:%@",key);
}
-(NSString *)getAPIKey{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefault objectForKey:@"api_key"];
    NSLog(@"getApiKey_success:%@",apiKey);
    return apiKey;
}
-(void)setSaveImagePath:(NSString *)path {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:path forKey:@"save_path"];
    [userDefault synchronize];
    NSLog(@"savePath_success:%@",path);
}
-(NSString *)getSaveImagePath{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString * path = [userDefault objectForKey:@"save_path"];
    NSLog(@"getSavePath_success:%@",path);
    return path;
}
-(void)saveCompressionCount:(NSString *)count{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:count forKey:@"compressionCount"];
}
-(NSString *)getCompressionCount{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return  [userDefault objectForKey:@"compressionCount"];
}
 //开启保存图片文件夹的读写权限
-(void)getDownloadDirectorySecurityScoped{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"bookmarkData"]) {
        NSData * bookmarkData=[userDefault objectForKey:@"bookmarkData"];
        BOOL bookmarkDataIsStale = YES;
        NSURL *allowedUrl = [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithSecurityScope|NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:&bookmarkDataIsStale error:nil];
        [allowedUrl startAccessingSecurityScopedResource];
    }
}
-(void)saveBookmarkDataToUserDefaultWithURL:(NSURL *)url{
    NSData *bookmarkData = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:@[NSURLIsDirectoryKey] relativeToURL:nil error:nil];
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:bookmarkData forKey:@"bookmarkData"];
}

@end
